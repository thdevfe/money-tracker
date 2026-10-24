/// Calculator input for the amount keypad: whole numbers joined by
/// + − × ÷. Stored as tokens, never as a formatted string.
enum KeypadOp {
  add('+'),
  subtract('−'),
  multiply('×'),
  divide('÷');

  final String symbol;

  const KeypadOp(this.symbol);
}

class KeypadExpression {
  static const maxDigits = 13;

  /// Alternating numbers (digit strings) and operators; may end with an
  /// operator while the user is typing.
  final List<Object> tokens;

  const KeypadExpression._(this.tokens);

  const KeypadExpression.empty() : tokens = const [];

  factory KeypadExpression.fromAmount(int amountMinor) => amountMinor <= 0
      ? const KeypadExpression.empty()
      : KeypadExpression._(['$amountMinor']);

  bool get isEmpty => tokens.isEmpty;

  bool get hasOperator => tokens.any((t) => t is KeypadOp);

  String? get _lastNumber =>
      tokens.isNotEmpty && tokens.last is String ? tokens.last as String : null;

  KeypadExpression appendDigits(String digits) {
    final last = _lastNumber;
    final next = (last == null || last == '0') ? digits : last + digits;
    final trimmed = next.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (trimmed.length > maxDigits) return this;
    // Leading "000" on an empty number is just 0.
    final value = trimmed.isEmpty ? '0' : trimmed;
    return KeypadExpression._([
      if (last == null) ...tokens else ...tokens.sublist(0, tokens.length - 1),
      value,
    ]);
  }

  /// Adds an operator; replaces a trailing one. Ignored on an empty input.
  KeypadExpression appendOp(KeypadOp op) {
    if (tokens.isEmpty) return this;
    if (tokens.last is KeypadOp) {
      return KeypadExpression._([...tokens.sublist(0, tokens.length - 1), op]);
    }
    return KeypadExpression._([...tokens, op]);
  }

  KeypadExpression backspace() {
    if (tokens.isEmpty) return this;
    final last = tokens.last;
    final rest = tokens.sublist(0, tokens.length - 1);
    if (last is String && last.length > 1) {
      return KeypadExpression._([...rest, last.substring(0, last.length - 1)]);
    }
    return KeypadExpression._(rest);
  }

  /// Result in minor units, or null when empty. × and ÷ bind tighter than
  /// + and −; division rounds to the nearest đồng; a trailing operator is
  /// ignored. Division by zero yields null.
  int? evaluate() {
    final parts = [...tokens];
    if (parts.isNotEmpty && parts.last is KeypadOp) parts.removeLast();
    if (parts.isEmpty) return null;

    // First pass: × and ÷.
    final terms = <Object>[int.parse(parts.first as String)];
    for (var i = 1; i < parts.length; i += 2) {
      final op = parts[i] as KeypadOp;
      final value = int.parse(parts[i + 1] as String);
      if (op == KeypadOp.multiply || op == KeypadOp.divide) {
        final left = terms.removeLast() as int;
        if (op == KeypadOp.divide) {
          if (value == 0) return null;
          terms.add((left / value).round());
        } else {
          terms.add(left * value);
        }
      } else {
        terms
          ..add(op)
          ..add(value);
      }
    }

    // Second pass: + and −.
    var result = terms.first as int;
    for (var i = 1; i < terms.length; i += 2) {
      final value = terms[i + 1] as int;
      result = terms[i] == KeypadOp.add ? result + value : result - value;
    }
    return result;
  }

  /// Display text with locale digit grouping, e.g. "120.000 + 35.000".
  String format(String Function(int) groupDigits) => tokens
      .map(
        (t) => t is KeypadOp ? t.symbol : groupDigits(int.parse(t as String)),
      )
      .join(' ');
}
