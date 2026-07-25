import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShortcutLabel extends StatelessWidget {
  const ShortcutLabel({required this.keys, super.key});

  final List<String> keys;

  factory ShortcutLabel.format({Key? key}) {
    final modifier = defaultTargetPlatform == TargetPlatform.macOS
        ? '⌘'
        : 'Ctrl';
    return ShortcutLabel(key: key, keys: [modifier, 'Enter']);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Keyboard shortcut: ${keys.join(' plus ')}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < keys.length; index++) ...[
            if (index > 0) const SizedBox(width: 4),
            Container(
              key: ValueKey('shortcut-key-${keys[index]}'),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3D45),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFF555963)),
              ),
              child: Text(
                keys[index],
                style: const TextStyle(
                  color: Color(0xFFD6D8DE),
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
