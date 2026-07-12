part of 'deep_link_bloc.dart';

sealed class DeepLinkEvent {
  const DeepLinkEvent();
}

class DeepLinkReceived extends DeepLinkEvent {
  final Uri uri;
  const DeepLinkReceived(this.uri);
}

class BluetoothInviteReceived extends DeepLinkEvent {
  final String jsonPayload;
  const BluetoothInviteReceived(this.jsonPayload);
}
