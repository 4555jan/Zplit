import 'dart:async';
import 'dart:math';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

const String kZplitWifiServiceName = 'ZplitWifiDirect';

sealed class ZplitWifiEvent {}

class WifiSearching extends ZplitWifiEvent {}

class WifiConnected extends ZplitWifiEvent {
  final String peerId;
  final String peerName;
  WifiConnected(this.peerId, this.peerName);
}

class WifiDisconnected extends ZplitWifiEvent {
  final String peerId;
  WifiDisconnected(this.peerId);
}

class WifiConnectionError extends ZplitWifiEvent {
  final String message;
  WifiConnectionError(this.message);
}

class WifiPayloadReceived extends ZplitWifiEvent {
  final String fromPeerId;
  final String jsonPayload;
  WifiPayloadReceived(this.fromPeerId, this.jsonPayload);
}

class WifiDirectTransportService {
  final _controller = StreamController<ZplitWifiEvent>.broadcast();
  Stream<ZplitWifiEvent> get events => _controller.stream;

  FlutterP2pHost? _host;
  FlutterP2pClient? _client;

  bool _enabled = false;
  bool _isHost = false;
  String? _connectedPeerId;

  StreamSubscription? _scanSub;
  StreamSubscription? _hotspotStateSub;
  StreamSubscription? _clientListSub;
  StreamSubscription? _receivedTextSub;

  Future<bool> ensurePermissions() async {
    final probe = FlutterP2pHost();
    if (!await probe.checkStoragePermission()) {
      await probe.askStoragePermission();
    }
    if (!await probe.checkP2pPermissions()) {
      await probe.askP2pPermissions();
    }
    if (!await probe.checkBluetoothPermissions()) {
      await probe.askBluetoothPermissions();
    }
    final ok =
        await probe.checkP2pPermissions() &&
        await probe.checkBluetoothPermissions();
    return ok;
  }

  Future<void> ensureServicesEnabled() async {
    final probe = FlutterP2pHost();
    if (!await probe.checkWifiEnabled()) await probe.enableWifiServices();
    if (!await probe.checkLocationEnabled()) {
      await probe.enableLocationServices();
    }
    if (!await probe.checkBluetoothEnabled()) {
      await probe.enableBluetoothServices();
    }
  }

  Future<void> enable(String myDisplayName) async {
    if (_enabled) return;
    _enabled = true;
    _controller.add(WifiSearching());
    await _attemptScanThenHost(myDisplayName);
  }

  Future<void> _attemptScanThenHost(String myDisplayName) async {
    final client = FlutterP2pClient();
    await client.initialize();
    _client = client;

    final jitterMs = 3000 + Random().nextInt(1000);
    BleDiscoveredDevice? found;

    final completer = Completer<void>();
    final sub = await client.startScan((devices) {
      for (final d in devices) {
        print(
          '[WiFiDirect] discovered: "${d.deviceName}" (${d.deviceAddress})',
        );
      }
      if (devices.isNotEmpty && !completer.isCompleted) {
        found = devices.first;
        completer.complete();
      }
    });
    _scanSub = sub;

    await Future.any([
      completer.future,
      Future.delayed(Duration(milliseconds: jitterMs)),
    ]);

    await client.stopScan();

    if (found != null) {
      await _becomeClient(client, found!);
    } else {
      await client.dispose();
      _client = null;
      await _becomeHost(myDisplayName);
    }
  }

  Future<void> _becomeClient(
    FlutterP2pClient client,
    BleDiscoveredDevice device,
  ) async {
    _isHost = false;
    try {
      await client.connectWithDevice(device);
    } catch (e) {
      _controller.add(WifiConnectionError('Connect failed: $e'));
      return;
    }

    if (_connectedPeerId == null) {
      _connectedPeerId = 'host';
      _controller.add(WifiConnected('host', 'Host'));
    }

    _hotspotStateSub = client.streamHotspotState().listen((state) {
      if (!state.isActive && _connectedPeerId != null) {
        final id = _connectedPeerId!;
        _connectedPeerId = null;
        _controller.add(WifiDisconnected(id));
      }
    });

    _receivedTextSub = client.streamReceivedTexts().listen((text) {
      if (_connectedPeerId == null) {
        _connectedPeerId = 'host';
        _controller.add(WifiConnected('host', 'Host'));
      }
      _controller.add(WifiPayloadReceived('host', text));
    });
  }

  Future<void> _becomeHost(String myDisplayName) async {
    _isHost = true;
    final host = FlutterP2pHost();
    await host.initialize();
    _host = host;

    // host.createGroup() has occasionally been observed to throw a raw
    // "Bad state: No element" exception — an internal race in the
    // plugin between its own hotspot-state wait logic and the native
    // hotspot actually starting. Left unhandled, this crashes the
    // whole WifiBloc (visible as an unhandled exception + onError in
    // the bloc observer). The native hotspot typically comes up
    // moments later regardless, so we surface this as a normal
    // WifiConnectionError instead of letting it propagate.
    HotspotHostState state;
    try {
      state = await host.createGroup(advertise: true);
    } catch (e) {
      _controller.add(WifiConnectionError('Could not create group: $e'));
      return;
    }

    if (state.failureReason != null) {
      _controller.add(
        WifiConnectionError('Could not create group: ${state.failureReason}'),
      );
      return;
    }

    _clientListSub = host.streamClientList().listen((clients) {
      if (clients.isNotEmpty && _connectedPeerId == null) {
        final c = clients.first;
        _connectedPeerId = c.id;
        _controller.add(WifiConnected(c.id, c.username));
      } else if (clients.isEmpty && _connectedPeerId != null) {
        final id = _connectedPeerId!;
        _connectedPeerId = null;
        _controller.add(WifiDisconnected(id));
      }
    });

    _receivedTextSub = host.streamReceivedTexts().listen((text) {
      _controller.add(WifiPayloadReceived(_connectedPeerId ?? 'client', text));
    });
  }

  Future<void> sendPayload(String jsonPayload) async {
    if (_isHost) {
      if (_connectedPeerId == null) {
        throw StateError('No connected peer to send to');
      }
      final ok = await _host!.sendTextToClient(jsonPayload, _connectedPeerId!);
      if (!ok) throw StateError('Send failed');
    } else {
      await _client!.broadcastText(jsonPayload);
    }
  }

  Future<void> _teardownHost() async {
    await _clientListSub?.cancel();
    await _receivedTextSub?.cancel();
    await _host?.removeGroup();
    await _host?.dispose();
    _host = null;
    _connectedPeerId = null;
  }

  Future<void> disable() async {
    if (!_enabled) return;
    _enabled = false;
    await _scanSub?.cancel();
    await _hotspotStateSub?.cancel();
    await _clientListSub?.cancel();
    await _receivedTextSub?.cancel();

    if (_isHost) {
      await _host?.removeGroup();
      await _host?.dispose();
      _host = null;
    } else {
      await _client?.disconnect();
      await _client?.dispose();
      _client = null;
    }
    _connectedPeerId = null;
  }

  void dispose() {
    _controller.close();
  }
}
