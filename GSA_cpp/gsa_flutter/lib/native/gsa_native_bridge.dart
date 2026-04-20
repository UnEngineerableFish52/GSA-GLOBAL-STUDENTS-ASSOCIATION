import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef _NativeBoolStr = Int32 Function(Pointer<Utf8>);
typedef _DartBoolStr = int Function(Pointer<Utf8>);

typedef _NativeBoolInt = Int32 Function(Int32, Int32);
typedef _DartBoolInt = int Function(int, int);

typedef _NativeScore = Int32 Function(Int32, Int32);
typedef _DartScore = int Function(int, int);

typedef _NativeFormat = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _DartFormat = Pointer<Utf8> Function(Pointer<Utf8>);

typedef _NativeFree = Void Function(Pointer<Utf8>);
typedef _DartFree = void Function(Pointer<Utf8>);

class GsaNativeBridge {
  GsaNativeBridge._();

  static DynamicLibrary? _lib;
  static _DartBoolStr? _isNonEmpty;
  static _DartBoolInt? _canSubmit;
  static _DartScore? _scorePercent;
  static _DartFormat? _formatTimestamp;
  static _DartFormat? _normalizeMembers;
  static _DartFree? _freeString;
  static bool _initialized = false;

  static void _ensureLoaded() {
    if (_initialized) return;
    _initialized = true;

    try {
      if (Platform.isAndroid || Platform.isLinux) {
        _lib = DynamicLibrary.open('libgsa_core.so');
      } else if (Platform.isMacOS || Platform.isIOS) {
        _lib = DynamicLibrary.process();
      } else if (Platform.isWindows) {
        _lib = DynamicLibrary.open('gsa_core.dll');
      }

      final lib = _lib;
      if (lib == null) return;

      _isNonEmpty = lib
          .lookup<NativeFunction<_NativeBoolStr>>('gsa_is_non_empty')
          .asFunction<_DartBoolStr>();
      _canSubmit = lib
          .lookup<NativeFunction<_NativeBoolInt>>('gsa_can_submit_exam')
          .asFunction<_DartBoolInt>();
      _scorePercent = lib
          .lookup<NativeFunction<_NativeScore>>('gsa_score_percent')
          .asFunction<_DartScore>();
      _formatTimestamp = lib
          .lookup<NativeFunction<_NativeFormat>>('gsa_format_timestamp_hhmm')
          .asFunction<_DartFormat>();
      _normalizeMembers = lib
          .lookup<NativeFunction<_NativeFormat>>('gsa_normalize_members_csv')
          .asFunction<_DartFormat>();
      _freeString = lib
          .lookup<NativeFunction<_NativeFree>>('gsa_free_string')
          .asFunction<_DartFree>();
    } catch (_) {
      _lib = null;
    }
  }

  static bool get isAvailable {
    _ensureLoaded();
    return _lib != null;
  }

  static bool isNonEmpty(String input) {
    _ensureLoaded();
    final native = _isNonEmpty;
    if (native == null) {
      return input.trim().isNotEmpty;
    }

    final ptr = input.toNativeUtf8();
    try {
      return native(ptr) == 1;
    } finally {
      malloc.free(ptr);
    }
  }

  static bool canSubmitExam(int answered, int total) {
    _ensureLoaded();
    final native = _canSubmit;
    if (native == null) {
      return total > 0 && answered == total;
    }
    return native(answered, total) == 1;
  }

  static int scorePercent(int correct, int total) {
    _ensureLoaded();
    final native = _scorePercent;
    if (native == null) {
      if (total <= 0) return 0;
      return ((correct / total) * 100).round();
    }
    return native(correct, total);
  }

  static String formatTimestamp(String timestamp) {
    _ensureLoaded();
    final native = _formatTimestamp;
    final free = _freeString;

    if (native == null || free == null) {
      try {
        final dt = DateTime.parse(timestamp);
        final minute = dt.minute.toString().padLeft(2, '0');
        return '${dt.hour}:$minute';
      } catch (_) {
        return timestamp;
      }
    }

    final ptr = timestamp.toNativeUtf8();
    try {
      final output = native(ptr);
      try {
        return output.toDartString();
      } finally {
        free(output);
      }
    } finally {
      malloc.free(ptr);
    }
  }

  static List<String> normalizeMembersCsv(String csv) {
    _ensureLoaded();
    final native = _normalizeMembers;
    final free = _freeString;

    if (native == null || free == null) {
      final seen = <String>{};
      final out = <String>[];
      for (final raw in csv.split(',')) {
        final value = raw.trim();
        if (value.isNotEmpty && seen.add(value)) {
          out.add(value);
        }
      }
      return out;
    }

    final ptr = csv.toNativeUtf8();
    try {
      final output = native(ptr);
      try {
        final normalized = output.toDartString();
        if (normalized.isEmpty) return const [];
        return normalized.split(',');
      } finally {
        free(output);
      }
    } finally {
      malloc.free(ptr);
    }
  }
}
