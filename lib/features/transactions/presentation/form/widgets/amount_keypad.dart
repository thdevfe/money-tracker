import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../keypad_expression.dart';

/// Calculator keypad: C ÷ × ⌫ / 7 8 9 − / 4 5 6 + / 1 2 3 / 0 000, with a
/// tall Done key. Keys have `ValueKey('keypad_<label>')` for tests.
class AmountKeypad extends StatelessWidget {
  final ValueChanged<String> onDigits;
  final ValueChanged<KeypadOp> onOp;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback? onDone;
  final Color accent;

  const AmountKeypad({
    super.key,
    required this.onDigits,
    required this.onOp,
    required this.onClear,
    required this.onBackspace,
    required this.onDone,
    required this.accent,
  });

  static const double _gap = 8;
  static const double _keyHeight = 52;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final keyColor = colors.elevatedSurface;
    final opColor = accent.withValues(alpha: 0.16);

    Widget key(
      String id,
      Widget child, {
      required VoidCallback? onTap,
      Color? color,
      String? semanticsLabel,
      double height = _keyHeight,
    }) {
      return _Key(
        key: ValueKey('keypad_$id'),
        color: color ?? keyColor,
        height: height,
        semanticsLabel: semanticsLabel,
        onTap: onTap,
        child: child,
      );
    }

    Widget digit(String d) => key(
      d,
      Text(
        d,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
      ),
      onTap: () => onDigits(d),
    );

    Widget op(KeypadOp o) => key(
      o.name,
      Text(
        o.symbol,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
      color: opColor,
      onTap: () => onOp(o),
    );

    Widget row(List<Widget> children) => Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Expanded(child: children[i]),
        ],
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([
          key(
            'clear',
            Text(
              'C',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
            semanticsLabel: l10n.keypadClear,
            onTap: onClear,
          ),
          op(KeypadOp.divide),
          op(KeypadOp.multiply),
          key(
            'backspace',
            const Icon(Icons.backspace_outlined),
            semanticsLabel: l10n.keypadBackspace,
            onTap: onBackspace,
          ),
        ]),
        const SizedBox(height: _gap),
        row([digit('7'), digit('8'), digit('9'), op(KeypadOp.subtract)]),
        const SizedBox(height: _gap),
        row([digit('4'), digit('5'), digit('6'), op(KeypadOp.add)]),
        const SizedBox(height: _gap),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  row([digit('1'), digit('2'), digit('3')]),
                  const SizedBox(height: _gap),
                  Row(
                    children: [
                      Expanded(flex: 2, child: digit('0')),
                      const SizedBox(width: _gap),
                      Expanded(child: digit('000')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: _gap),
            Expanded(
              child: key(
                'done',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                    Text(
                      l10n.done,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                color: accent,
                height: _keyHeight * 2 + _gap,
                onTap: onDone,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  final Color color;
  final double height;
  final String? semanticsLabel;
  final VoidCallback? onTap;
  final Widget child;

  const _Key({
    super.key,
    required this.color,
    required this.height,
    required this.onTap,
    required this.child,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: onTap == null ? color.withValues(alpha: 0.4) : color,
        borderRadius: BorderRadius.circular(AppRadii.input),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.input),
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: SizedBox(
            height: height,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
