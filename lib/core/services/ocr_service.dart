// lib/core/services/ocr_service.dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScanResult {
  final String? merchantName;
  final double? amount;
  final DateTime? date;
  final String rawText;

  const ReceiptScanResult({
    this.merchantName,
    this.amount,
    this.date,
    required this.rawText,
  });

  bool get isEmpty => merchantName == null && amount == null && date == null;
}

class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<ReceiptScanResult> scanReceipt(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _recognizer.processImage(inputImage);

    final lines = <String>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isNotEmpty) lines.add(text);
      }
    }

    return ReceiptScanResult(
      merchantName: _extractMerchantName(lines),
      amount: _extractAmount(lines),
      date: _extractDate(lines),
      rawText: recognized.text,
    );
  }

  static final _totalKeywords = RegExp(
    r'\b(total|grand\s*total|amount\s*due|balance\s*due|net\s*amount)\b',
    caseSensitive: false,
  );

  static final _amountPattern = RegExp(
    r'(?:₹|rs\.?|inr|\$)?\s*'
    r'([0-9OoQlI|SBZ]{1,3}(?:[,.\s][0-9OoQlI|SBZ]{3})*'
    r'(?:\.[0-9OoQlI|SBZ]{1,2})?)',
    caseSensitive: false,
  );

  double? _extractAmount(List<String> lines) {
    double? bestFromTotalLine;
    double? largestOverall;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isTotalLine = _totalKeywords.hasMatch(line);

      for (final match in _amountPattern.allMatches(line)) {
        final value = _parseAmount(match.group(1));
        if (value == null || value <= 0) continue;

        if (largestOverall == null || value > largestOverall) {
          largestOverall = value;
        }
        if (isTotalLine) {
          if (bestFromTotalLine == null || value > bestFromTotalLine) {
            bestFromTotalLine = value;
          }
        }
      }

      // If the keyword line itself had no number (e.g. "Total" on its
      // own line, amount on the next), check the next line too.
      if (isTotalLine && bestFromTotalLine == null && i + 1 < lines.length) {
        for (final match in _amountPattern.allMatches(lines[i + 1])) {
          final value = _parseAmount(match.group(1));
          if (value != null && value > 0) {
            bestFromTotalLine = value;
            break;
          }
        }
      }
    }

    return bestFromTotalLine ?? largestOverall;
  }

  static final _ocrZero = RegExp(r'[OoQ]');
  static final _ocrOne = RegExp(r'[lI|]');

  double? _parseAmount(String? raw) {
    if (raw == null) return null;

    // Strip thousands separators (commas or spaces) first.
    var cleaned = raw.replaceAll(RegExp(r'[,\s]'), '');

    // Fix common OCR digit misreads, e.g. "1OO.OO" -> "100.00",
    // "4O.5O" -> "40.50", "S0" -> "50".
    cleaned = cleaned
        .replaceAll(_ocrZero, '0')
        .replaceAll(_ocrOne, '1')
        .replaceAll('S', '5')
        .replaceAll('B', '8')
        .replaceAll('Z', '2');

    return double.tryParse(cleaned);
  }

  static final _numericDatePattern = RegExp(
    r'\b([0-3]?\d)[/\-.]([01]?\d)[/\-.](\d{2,4})\b',
  );
  static final _textDatePattern = RegExp(
    r'\b([0-3]?\d)\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{2,4})\b',
    caseSensitive: false,
  );

  static const _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  DateTime? _extractDate(List<String> lines) {
    final fullText = lines.join(' ');

    final numericMatch = _numericDatePattern.firstMatch(fullText);
    if (numericMatch != null) {
      final day = int.tryParse(numericMatch.group(1) ?? '');
      final month = int.tryParse(numericMatch.group(2) ?? '');
      var year = int.tryParse(numericMatch.group(3) ?? '');
      if (day != null &&
          month != null &&
          year != null &&
          day >= 1 &&
          day <= 31 &&
          month >= 1 &&
          month <= 12) {
        if (year < 100) year += 2000;
        try {
          final candidate = DateTime(year, month, day);
          if (_isPlausibleReceiptDate(candidate)) return candidate;
        } catch (_) {}
      }
    }

    final textMatch = _textDatePattern.firstMatch(fullText.toLowerCase());
    if (textMatch != null) {
      final day = int.tryParse(textMatch.group(1) ?? '');
      final monthAbbr = textMatch.group(2);
      var year = int.tryParse(textMatch.group(3) ?? '');
      final month = _months[monthAbbr];
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        try {
          final candidate = DateTime(year, month, day);
          if (_isPlausibleReceiptDate(candidate)) return candidate;
        } catch (_) {}
      }
    }

    return null;
  }

  bool _isPlausibleReceiptDate(DateTime date) {
    final now = DateTime.now();

    return date.isBefore(now.add(const Duration(days: 1))) &&
        date.isAfter(now.subtract(const Duration(days: 365 * 5)));
  }

  static final _phonePattern = RegExp(r'[\d\-\+\(\)\s]{7,}');
  static final _addressHints = RegExp(
    r'\b(road|street|st\.|ave|avenue|floor|block|sector|near|opp\.?)\b',
    caseSensitive: false,
  );

  String? _extractMerchantName(List<String> lines) {
    for (final line in lines.take(6)) {
      if (line.length < 2) continue;
      if (_totalKeywords.hasMatch(line)) continue;
      if (_numericDatePattern.hasMatch(line)) continue;
      if (_addressHints.hasMatch(line)) continue;
      // Skip lines that are basically just digits/punctuation (phone
      // numbers, receipt numbers, etc.)
      final digitRatio =
          line.replaceAll(RegExp(r'[^0-9]'), '').length / line.length;
      if (digitRatio > 0.5) continue;
      if (_phonePattern.hasMatch(line) && digitRatio > 0.3) continue;

      return line;
    }
    return null;
  }

  void dispose() {
    _recognizer.close();
  }
}
