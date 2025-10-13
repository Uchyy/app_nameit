import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final void Function(String)? onKeyTyped;

  const CustomKeyboard({super.key, this.onKeyTyped});

  void _handleKeyPress(String letter) {
    final focused = FocusManager.instance.primaryFocus;
    if (focused != null) {
      final element = focused.context;
      if (element != null) {
        final editable = element.findAncestorWidgetOfExactType<EditableText>();
        if (editable != null) {
          editable.controller.text += letter;
          onKeyTyped?.call(letter);
        }
      }
    }
  }

  void _handleSpace() {
    final focused = FocusManager.instance.primaryFocus;
    if (focused != null) {
      final element = focused.context;
      if (element != null) {
        final editable = element.findAncestorWidgetOfExactType<EditableText>();
        if (editable != null) {
          editable.controller.text += " " ;
        }
      }
    }
  }

 void _handleBackspace() {
  final focused = FocusManager.instance.primaryFocus;
  if (focused != null) {
    final element = focused.context;
    if (element != null) {
      final editable = element.findAncestorWidgetOfExactType<EditableText>();
      if (editable != null) {
        final ctrl = editable.controller;
        final selection = ctrl.selection;
        final cursorPos = selection.baseOffset;

        if (cursorPos > 0) {
          final newText = ctrl.text.replaceRange(cursorPos - 1, cursorPos, '');
          ctrl.text = newText;
          ctrl.selection = TextSelection.collapsed(offset: cursorPos - 1);
        }
      }
    }
  }
}

  void _handleEnter() {
    final focused = FocusManager.instance.primaryFocus;
    if (focused != null) {
      FocusScope.of(focused.context!).nextFocus();
      // 👇 bring the newly focused field into view
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = FocusManager.instance.primaryFocus?.context;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext ctx) {
    const keys = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          for (var row in keys) 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((letter) {
                return _buildKey(letter, () => _handleKeyPress(letter));
              }).toList(),
            ),
          const SizedBox(height: 3,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKey("¬", _handleEnter, flex:1),
              const SizedBox(width: 3),
              _buildKey("Space", _handleSpace, flex: 2),
              const SizedBox(width: 3),
              _buildKey("⌫", _handleBackspace, flex: 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, VoidCallback? onPressed, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}