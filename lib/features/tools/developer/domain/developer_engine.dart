import 'dart:convert';

import '../../date_time/domain/date_time_engine.dart';

/// Structured result for Number Base Conversion
class NumberBaseResult {
  final String originalValue;
  final int sourceBase;
  final int targetBase;
  final String convertedValue;
  final String binary;
  final String octal;
  final String decimal;
  final String hex;

  const NumberBaseResult({
    required this.originalValue,
    required this.sourceBase,
    required this.targetBase,
    required this.convertedValue,
    required this.binary,
    required this.octal,
    required this.decimal,
    required this.hex,
  });
}

/// Structured result for Bitwise Calculations
class BitwiseResult {
  final BigInt a;
  final BigInt? b;
  final String operation;
  final int bitWidth;
  final BigInt result;
  final String binaryBreakdown;
  final String hexResult;
  final String binaryResult;
  final String decimalResult;

  const BitwiseResult({
    required this.a,
    this.b,
    required this.operation,
    required this.bitWidth,
    required this.result,
    required this.binaryBreakdown,
    required this.hexResult,
    required this.binaryResult,
    required this.decimalResult,
  });

  String get decimal => decimalResult;
  String get hex => hexResult;
  String get hexadecimal => hexResult;
  String get binary => binaryResult;
  String get breakdown => binaryBreakdown;
  String get octal => DeveloperEngine._bigIntToRadix(result, 8);
}

/// Structured result for Data Transfer Time Calculation
class DataTransferResult {
  final double fileSizeBytes;
  final double transferSpeedBps; // bits per second
  final double totalSeconds;
  final String formattedTime;
  final String totalBitsFormatted;
  final String totalBytesFormatted;
  final double hours;
  final double minutes;
  final double days;

  const DataTransferResult({
    required this.fileSizeBytes,
    required this.transferSpeedBps,
    required this.totalSeconds,
    required this.formattedTime,
    required this.totalBitsFormatted,
    required this.totalBytesFormatted,
    required this.hours,
    required this.minutes,
    required this.days,
  });

  String get formattedDuration => formattedTime;
  double get totalBytes => fileSizeBytes;
}

/// Structured result for Color Conversion
class ColorConversionResult {
  final int r;
  final int g;
  final int b;
  final double a; // 0.0 to 1.0
  final String hex; // #RRGGBB or #RRGGBBAA
  final String rgbString; // rgb(r, g, b)
  final String rgbaString; // rgba(r, g, b, a)

  const ColorConversionResult({
    required this.r,
    required this.g,
    required this.b,
    required this.a,
    required this.hex,
    required this.rgbString,
    required this.rgbaString,
  });
}

/// Pure Dart Computer Science and Developer calculations engine
class DeveloperEngine {
  DeveloperEngine._();

  // ----------------------------------------------------
  // 1. Number Base Conversion (Bases 2 through 36)
  // ----------------------------------------------------
  static NumberBaseResult convertNumberBase({
    required String value,
    required int sourceBase,
    required int targetBase,
  }) {
    if (sourceBase < 2 || sourceBase > 36) {
      throw ArgumentError('Source base must be between 2 and 36');
    }
    if (targetBase < 2 || targetBase > 36) {
      throw ArgumentError('Target base must be between 2 and 36');
    }
    final clean = value.trim();
    if (clean.isEmpty) {
      throw ArgumentError('Input value cannot be empty');
    }

    final bool isNegative = clean.startsWith('-');
    final digits = isNegative ? clean.substring(1) : clean;
    if (digits.isEmpty) throw ArgumentError('Invalid numeric format');

    final BigInt parsedNumber;
    try {
      parsedNumber = _parseBigIntWithRadix(digits, sourceBase);
    } catch (_) {
      throw ArgumentError(
        'Invalid characters in base-$sourceBase representation: "$clean"',
      );
    }

    final BigInt fullNumber = isNegative ? -parsedNumber : parsedNumber;

    final String converted =
        (isNegative ? '-' : '') +
        _bigIntToRadix(parsedNumber, targetBase).toUpperCase();
    final String bin =
        (isNegative ? '-' : '') + _bigIntToRadix(parsedNumber, 2);
    final String oct =
        (isNegative ? '-' : '') + _bigIntToRadix(parsedNumber, 8);
    final String dec = fullNumber.toString();
    final String hex =
        (isNegative ? '-' : '') +
        _bigIntToRadix(parsedNumber, 16).toUpperCase();

    return NumberBaseResult(
      originalValue: clean,
      sourceBase: sourceBase,
      targetBase: targetBase,
      convertedValue: converted,
      binary: bin,
      octal: oct,
      decimal: dec,
      hex: hex,
    );
  }

  static BigInt _parseBigIntWithRadix(String text, int radix) {
    BigInt result = BigInt.zero;
    final BigInt r = BigInt.from(radix);
    final validChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for (int i = 0; i < text.length; i++) {
      final char = text[i].toUpperCase();
      final digitValue = validChars.indexOf(char);
      if (digitValue == -1 || digitValue >= radix) {
        throw FormatException('Invalid digit $char for radix $radix');
      }
      result = result * r + BigInt.from(digitValue);
    }
    return result;
  }

  static String _bigIntToRadix(BigInt number, int radix) {
    if (number == BigInt.zero) return '0';
    final chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    final BigInt r = BigInt.from(radix);
    BigInt temp = number;
    final buffer = StringBuffer();

    while (temp > BigInt.zero) {
      final rem = (temp % r).toInt();
      buffer.write(chars[rem]);
      temp = temp ~/ r;
    }
    return buffer.toString().split('').reversed.join();
  }

  // ----------------------------------------------------
  // 2. Bitwise Operations (8, 16, 32, 64-bit width)
  // ----------------------------------------------------
  static BitwiseResult calculateBitwise({
    BigInt? a,
    BigInt? b,
    String? aString,
    String? bString,
    required String operation, // 'AND', 'OR', 'XOR', 'NOT', 'LSHIFT', 'RSHIFT'
    int? bitWidth, // 8, 16, 32, 64
    int? wordSize,
  }) {
    final effectiveBitWidth = bitWidth ?? wordSize ?? 32;
    if (![8, 16, 32, 64].contains(effectiveBitWidth)) {
      throw ArgumentError('Bit width must be 8, 16, 32, or 64 bits');
    }

    BigInt parseVal(dynamic v) {
      if (v is BigInt) return v;
      final s = v.toString().trim();
      if (s.startsWith('0x') || s.startsWith('0X')) {
        return BigInt.parse(s.substring(2), radix: 16);
      }
      return BigInt.parse(s);
    }

    final effectiveA = a ?? parseVal(aString ?? '0');
    final effectiveB = b ?? (bString != null ? parseVal(bString) : null);

    final BigInt mask = (BigInt.one << effectiveBitWidth) - BigInt.one;
    final BigInt maskedA = effectiveA & mask;
    BigInt? maskedB = effectiveB != null ? (effectiveB & mask) : null;
    BigInt res;
    String breakdown = '';

    final aBin = maskedA.toRadixString(2).padLeft(effectiveBitWidth, '0');
    final bBin = maskedB != null
        ? maskedB.toRadixString(2).padLeft(effectiveBitWidth, '0')
        : '';

    switch (operation.toUpperCase()) {
      case 'AND':
        if (effectiveB == null) throw ArgumentError('Operand B is required for AND');
        res = (maskedA & maskedB!) & mask;
        final resBin = res.toRadixString(2).padLeft(effectiveBitWidth, '0');
        breakdown = 'A:   $aBin\nB:   $bBin\nAND: $resBin';
        break;
      case 'OR':
        if (effectiveB == null) throw ArgumentError('Operand B is required for OR');
        res = (maskedA | maskedB!) & mask;
        final resBin = res.toRadixString(2).padLeft(effectiveBitWidth, '0');
        breakdown = 'A:  $aBin\nB:  $bBin\nOR: $resBin';
        break;
      case 'XOR':
        if (effectiveB == null) throw ArgumentError('Operand B is required for XOR');
        res = (maskedA ^ maskedB!) & mask;
        final resBin = res.toRadixString(2).padLeft(effectiveBitWidth, '0');
        breakdown = 'A:   $aBin\nB:   $bBin\nXOR: $resBin';
        break;
      case 'NOT':
        res = (~maskedA) & mask;
        final resBin = res.toRadixString(2).padLeft(effectiveBitWidth, '0');
        breakdown = 'A:   $aBin\nNOT: $resBin';
        break;
      case 'LSHIFT':
        if (effectiveB == null) {
          throw ArgumentError('Shift count B is required for LSHIFT');
        }
        final shift = effectiveB.toInt();
        if (shift < 0 || shift > effectiveBitWidth * 2) {
          throw ArgumentError('Invalid shift count: $shift');
        }
        res = (maskedA << shift) & mask;
        final resBin = res.toRadixString(2).padLeft(effectiveBitWidth, '0');
        breakdown = 'A:       $aBin\n<< $shift:   $resBin';
        break;
      case 'RSHIFT':
        if (effectiveB == null) {
          throw ArgumentError('Shift count B is required for RSHIFT');
        }
        final shift = effectiveB.toInt();
        if (shift < 0 || shift > effectiveBitWidth * 2) {
          throw ArgumentError('Invalid shift count: $shift');
        }
        res = (maskedA >> shift) & mask;
        final resBin = res.toRadixString(2).padLeft(effectiveBitWidth, '0');
        breakdown = 'A:       $aBin\n>> $shift:   $resBin';
        break;
      default:
        throw ArgumentError('Unknown bitwise operation: $operation');
    }

    final hexPad = (effectiveBitWidth / 4).ceil();
    final hexStr =
        '0x${res.toRadixString(16).toUpperCase().padLeft(hexPad, '0')}';
    final binStr = res.toRadixString(2).padLeft(effectiveBitWidth, '0');

    return BitwiseResult(
      a: effectiveA,
      b: effectiveB,
      operation: operation,
      bitWidth: effectiveBitWidth,
      result: res,
      binaryBreakdown: breakdown,
      hexResult: hexStr,
      binaryResult: binStr,
      decimalResult: res.toString(),
    );
  }

  // ----------------------------------------------------
  // 3. Unix Timestamp Converter (Delegates to pure DateTimeEngine)
  // ----------------------------------------------------
  static DateTime timestampToDateTime(
    int timestamp, {
    bool isMilliseconds = false,
  }) {
    final res = isMilliseconds
        ? DateTimeEngine.convertTimestamp(unixMilliseconds: timestamp)
        : DateTimeEngine.convertTimestamp(unixSeconds: timestamp);
    return res.utcDateTime;
  }

  static int dateTimeToTimestamp(
    DateTime dateTime, {
    bool isMilliseconds = false,
  }) {
    final res = DateTimeEngine.convertTimestamp(dateTime: dateTime);
    return isMilliseconds ? res.unixMilliseconds : res.unixSeconds;
  }

  // ----------------------------------------------------
  // 4. Data Transfer Time Calculator
  // ----------------------------------------------------
  static DataTransferResult calculateDataTransferTime({
    required double fileSize,
    required String fileUnit, // 'B', 'KB', 'MB', 'GB', 'TB'
    required double speed,
    required String
    speedUnit, // 'bps', 'Kbps', 'Mbps', 'Gbps', 'B/s', 'KB/s', 'MB/s', 'GB/s'
  }) {
    if (fileSize < 0 || speed <= 0) {
      throw ArgumentError(
        'File size must be non-negative and transfer speed must be positive',
      );
    }

    // Convert file size to bytes (using binary/standard prefixes)
    double bytes;
    switch (fileUnit.toUpperCase()) {
      case 'B':
        bytes = fileSize;
        break;
      case 'KB':
        bytes = fileSize * 1024;
        break;
      case 'MB':
        bytes = fileSize * 1024 * 1024;
        break;
      case 'GB':
        bytes = fileSize * 1024 * 1024 * 1024;
        break;
      case 'TB':
        bytes = fileSize * 1024 * 1024 * 1024 * 1024;
        break;
      default:
        throw ArgumentError('Unsupported file size unit: $fileUnit');
    }

    final double totalBits = bytes * 8.0;

    // Convert speed to bits per second (SI network standards: 1 Mbps = 1,000,000 bps)
    double bps;
    switch (speedUnit) {
      case 'bps':
        bps = speed;
        break;
      case 'Kbps':
        bps = speed * 1000;
        break;
      case 'Mbps':
        bps = speed * 1000000;
        break;
      case 'Gbps':
        bps = speed * 1000000000;
        break;
      case 'B/s':
        bps = speed * 8;
        break;
      case 'KB/s':
        bps = speed * 8 * 1000;
        break;
      case 'MB/s':
        bps = speed * 8 * 1000000;
        break;
      case 'GB/s':
        bps = speed * 8 * 1000000000;
        break;
      default:
        throw ArgumentError('Unsupported speed unit: $speedUnit');
    }

    final double totalSeconds = totalBits / bps;
    final double minutes = totalSeconds / 60.0;
    final double hours = totalSeconds / 3600.0;
    final double days = totalSeconds / 86400.0;

    // Human formatted time
    String formatted;
    if (totalSeconds < 60) {
      formatted = '${totalSeconds.toStringAsFixed(2)} seconds';
    } else if (totalSeconds < 3600) {
      final m = totalSeconds ~/ 60;
      final s = (totalSeconds % 60).round();
      formatted = '${m}m ${s}s';
    } else if (totalSeconds < 86400) {
      final h = totalSeconds ~/ 3600;
      final m = ((totalSeconds % 3600) / 60).round();
      formatted = '${h}h ${m}m';
    } else {
      final d = totalSeconds ~/ 86400;
      final h = ((totalSeconds % 86400) / 3600).round();
      formatted = '${d}d ${h}h';
    }

    return DataTransferResult(
      fileSizeBytes: bytes,
      transferSpeedBps: bps,
      totalSeconds: totalSeconds,
      formattedTime: formatted,
      totalBitsFormatted: '${totalBits.toStringAsExponential(2)} bits',
      totalBytesFormatted: '${bytes.toStringAsFixed(0)} bytes',
      hours: hours,
      minutes: minutes,
      days: days,
    );
  }

  // ----------------------------------------------------
  // 5. RGB <-> HEX Color Converter
  // ----------------------------------------------------
  static ColorConversionResult rgbToHex({
    required int r,
    required int g,
    required int b,
    double a = 1.0,
  }) {
    if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
      throw ArgumentError('RGB channels must be in range 0 - 255');
    }
    if (a < 0.0 || a > 1.0) {
      throw ArgumentError('Alpha channel must be between 0.0 and 1.0');
    }

    final rHex = r.toRadixString(16).padLeft(2, '0').toUpperCase();
    final gHex = g.toRadixString(16).padLeft(2, '0').toUpperCase();
    final bHex = b.toRadixString(16).padLeft(2, '0').toUpperCase();

    String hex;
    if (a >= 0.999) {
      hex = '#$rHex$gHex$bHex';
    } else {
      final aInt = (a * 255).round();
      final aHex = aInt.toRadixString(16).padLeft(2, '0').toUpperCase();
      hex = '#$rHex$gHex$bHex$aHex';
    }

    return ColorConversionResult(
      r: r,
      g: g,
      b: b,
      a: a,
      hex: hex,
      rgbString: 'rgb($r, $g, $b)',
      rgbaString: 'rgba($r, $g, $b, ${a.toStringAsFixed(2)})',
    );
  }

  static ColorConversionResult hexToRgb(String hexInput) {
    var hex = hexInput.trim().replaceAll('#', '');
    if (hex.isEmpty) throw FormatException('HEX input cannot be empty');

    // Handle shorthand 3-char (#RGB) or 4-char (#RGBA)
    if (hex.length == 3) {
      hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    } else if (hex.length == 4) {
      hex =
          '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}${hex[3]}${hex[3]}';
    }

    if (hex.length != 6 && hex.length != 8) {
      throw FormatException(
        'Invalid HEX color length. Must be #RGB, #RGBA, #RRGGBB, or #RRGGBBAA',
      );
    }

    try {
      final int r = int.parse(hex.substring(0, 2), radix: 16);
      final int g = int.parse(hex.substring(2, 4), radix: 16);
      final int b = int.parse(hex.substring(4, 6), radix: 16);
      double a = 1.0;

      if (hex.length == 8) {
        final int aInt = int.parse(hex.substring(6, 8), radix: 16);
        a = aInt / 255.0;
      }

      return rgbToHex(r: r, g: g, b: b, a: a);
    } catch (_) {
      throw FormatException('Invalid HEX color digits: "$hexInput"');
    }
  }

  // ----------------------------------------------------
  // 6. Developer Utilities (JSON, URL, Base64)
  // ----------------------------------------------------
  static String formatJson(String rawJson, {int indent = 2}) {
    if (rawJson.trim().isEmpty) throw ArgumentError('JSON string is empty');
    final parsed = jsonDecode(rawJson);
    final spaces = ' ' * indent;
    return JsonEncoder.withIndent(spaces).convert(parsed);
  }

  static String minifyJson(String rawJson) {
    if (rawJson.trim().isEmpty) throw ArgumentError('JSON string is empty');
    final parsed = jsonDecode(rawJson);
    return jsonEncode(parsed);
  }

  static String encodeUrl(String input) {
    return Uri.encodeComponent(input);
  }

  static String decodeUrl(String input) {
    return Uri.decodeComponent(input);
  }

  static String encodeBase64(String input) {
    final bytes = utf8.encode(input);
    return base64Encode(bytes);
  }

  static String decodeBase64(String input) {
    final bytes = base64Decode(input.trim());
    return utf8.decode(bytes);
  }
}
