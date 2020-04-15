import 'package:flutter/material.dart';

import '../async_redux.dart';

// Developed by Marcelo Glasberg (Apr 2020).
// For more info, see: https://pub.dartlang.org/packages/async_redux

// /////////////////////////////////////////////////////////////////////////////////////////////////

enum WaitOperation { add, remove, clear }

// /////////////////////////////////////////////////////////////////////////////////////////////////

@immutable
class Wait {
  final Map<Object, Set<Object>> _flags;

  static Wait _empty = Wait._({});

  factory Wait() => _empty;

  Wait._(Map<Object, Set<Object>> flags) : _flags = flags;

  Wait add({@required Object flag, Object ref}) {
    Map<Object, Set<Object>> newFlags = _deepCopy();

    Set<Object> refs = newFlags[flag];
    if (refs == null) {
      refs = {};
      newFlags[flag] = refs;
    }
    refs.add(ref);

    return Wait._(newFlags);
  }

  Wait remove({@required Object flag, Object ref}) {
    if (_flags == null || _flags.isEmpty)
      return this;
    else {
      Map<Object, Set<Object>> newFlags = _deepCopy();

      if (ref == null) {
        newFlags.remove(flag);
      } else {
        Set<Object> refs = newFlags[flag];
        refs.remove(ref);
        if (refs.isEmpty) newFlags.remove(flag);
      }

      if (newFlags.isEmpty)
        return _empty;
      else
        return Wait._(newFlags);
    }
  }

  Wait process(
    WaitOperation operation, {
    @required Object flag,
    Object ref,
  }) {
    if (operation == WaitOperation.add)
      return add(flag: flag, ref: ref);
    else if (operation == WaitOperation.remove)
      return remove(flag: flag, ref: ref);
    else if (operation == WaitOperation.clear)
      return clear(flag: flag);
    else
      throw AssertionError(operation);
  }

  bool get isWaiting => _flags.isNotEmpty;

  bool isWaitingFor(Object flag, {Object ref}) {
    Set refs = _flags[flag];

    if (ref == null)
      return refs != null && refs.isNotEmpty;
    else
      return refs != null && refs.contains(ref);
  }

  Wait clear({Object flag}) {
    if (flag == null)
      return _empty;
    else {
      Map<Object, Set<Object>> newFlags = _deepCopy();
      newFlags.remove(flag);
      return Wait._(newFlags);
    }
  }

  clearWhere(bool Function(Object flag, Set<Object> refs) test) => _flags.removeWhere(test);

  Map<Object, Set<Object>> _deepCopy() {
    Map<Object, Set<Object>> newFlags = {};

    for (MapEntry<Object, Set<Object>> flag in _flags.entries) {
      newFlags[flag.key] = Set.of(flag.value);
    }

    return newFlags;
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////