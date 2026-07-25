import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

const jsonCodeStyle = TextStyle(
  color: RikitColors.text,
  fontFamily: 'monospace',
  fontSize: 13,
  height: 1.55,
);

class JsonCodeEditorController {
  _JsonCodeEditorState? _state;

  void _attach(_JsonCodeEditorState state) => _state = state;

  void _detach(_JsonCodeEditorState state) {
    if (identical(_state, state)) _state = null;
  }

  void revealDiagnostic({required int offset, required int length}) {
    _state?.revealDiagnostic(offset: offset, length: length);
  }
}

class JsonCodeEditor extends StatefulWidget {
  const JsonCodeEditor({
    required this.textController,
    this.editorController,
    this.onChanged,
    this.readOnly = false,
    this.hintText,
    this.diagnosticOffset,
    super.key,
  });

  final TextEditingController textController;
  final JsonCodeEditorController? editorController;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final String? hintText;
  final int? diagnosticOffset;

  @override
  State<JsonCodeEditor> createState() => _JsonCodeEditorState();
}

class _JsonCodeEditorState extends State<JsonCodeEditor> {
  static const _lineExtent = 13 * 1.55;
  static const _verticalPadding = 18.0;

  final _verticalController = ScrollController();
  final _horizontalController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.editorController?._attach(this);
  }

  @override
  void didUpdateWidget(covariant JsonCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editorController != widget.editorController) {
      oldWidget.editorController?._detach(this);
      widget.editorController?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.editorController?._detach(this);
    _verticalController.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void revealDiagnostic({required int offset, required int length}) {
    final text = widget.textController.text;
    final safeOffset = offset.clamp(0, text.length);
    final safeEnd = (safeOffset + length).clamp(safeOffset, text.length);
    final before = text.substring(0, safeOffset);
    final line = '\n'.allMatches(before).length;
    final lineStart = before.lastIndexOf('\n') + 1;
    final columnText = text.substring(lineStart, safeOffset);
    final painter = TextPainter(
      text: TextSpan(text: columnText, style: jsonCodeStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    _focusNode.requestFocus();
    widget.textController.selection = TextSelection(
      baseOffset: safeOffset,
      extentOffset: safeEnd,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_verticalController.hasClients) {
        _verticalController.animateTo(
          (line * _lineExtent).clamp(
            0,
            _verticalController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
      if (_horizontalController.hasClients) {
        _horizontalController.animateTo(
          math
              .max(0.0, painter.width - 48)
              .clamp(0.0, _horizontalController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final text = widget.textController.text;
        final lines = text.split('\n');
        final lineCount = math.max(1, lines.length);
        final gutterWidth = 24.0 + lineCount.toString().length * 8;
        final glyphPainter = TextPainter(
          text: const TextSpan(text: 'M', style: jsonCodeStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final widestLineLength = lines.fold<int>(
          1,
          (length, line) => math.max(length, line.runes.length),
        );
        final widestLine = widestLineLength * glyphPainter.width;
        final editorViewportWidth = math.max(
          0.0,
          constraints.maxWidth - gutterWidth,
        );
        final contentWidth = math.max(editorViewportWidth, widestLine + 36);
        final contentHeight = math.max(
          constraints.maxHeight,
          lineCount * _lineExtent + _verticalPadding * 2,
        );
        final errorLine = widget.diagnosticOffset == null
            ? null
            : '\n'
                  .allMatches(
                    text.substring(
                      0,
                      widget.diagnosticOffset!.clamp(0, text.length),
                    ),
                  )
                  .length;

        return Scrollbar(
          controller: _verticalController,
          child: SingleChildScrollView(
            controller: _verticalController,
            child: SizedBox(
              height: contentHeight,
              width: constraints.maxWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    key: const ValueKey('json-line-number-gutter'),
                    width: gutterWidth,
                    color: RikitColors.surfaceRaised.withValues(alpha: .55),
                    child: CustomPaint(
                      painter: _LineNumberGutterPainter(
                        lineCount: lineCount,
                        errorLine: errorLine,
                        lineExtent: _lineExtent,
                        verticalPadding: _verticalPadding,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _horizontalController,
                      notificationPredicate: (notification) =>
                          notification.metrics.axis == Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: contentWidth,
                          height: contentHeight,
                          child: Stack(
                            children: [
                              if (errorLine != null)
                                Positioned(
                                  key: const ValueKey(
                                    'json-diagnostic-line-highlight',
                                  ),
                                  top:
                                      _verticalPadding +
                                      errorLine * _lineExtent,
                                  left: 0,
                                  right: 0,
                                  height: _lineExtent,
                                  child: Container(
                                    color: RikitColors.primary.withValues(
                                      alpha: .10,
                                    ),
                                  ),
                                ),
                              TextField(
                                key: ValueKey(
                                  widget.readOnly
                                      ? 'json-output'
                                      : 'json-input',
                                ),
                                controller: widget.textController,
                                focusNode: _focusNode,
                                onChanged: widget.onChanged,
                                readOnly: widget.readOnly,
                                maxLines: null,
                                minLines: null,
                                style: jsonCodeStyle,
                                cursorColor: RikitColors.primary,
                                selectionControls:
                                    materialTextSelectionControls,
                                decoration: InputDecoration(
                                  hintText: widget.hintText,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: const EdgeInsets.all(18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LineNumberGutterPainter extends CustomPainter {
  const _LineNumberGutterPainter({
    required this.lineCount,
    required this.errorLine,
    required this.lineExtent,
    required this.verticalPadding,
  });

  final int lineCount;
  final int? errorLine;
  final double lineExtent;
  final double verticalPadding;

  @override
  void paint(Canvas canvas, Size size) {
    final clip = canvas.getLocalClipBounds();
    final firstVisible = math.max(
      0,
      ((clip.top - verticalPadding) / lineExtent).floor(),
    );
    final lastVisible = math.min(
      lineCount - 1,
      ((clip.bottom - verticalPadding) / lineExtent).ceil(),
    );
    if (lastVisible < firstVisible) return;

    final error = errorLine;
    if (error != null && error >= firstVisible && error <= lastVisible) {
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          verticalPadding + error * lineExtent,
          size.width,
          lineExtent,
        ),
        Paint()..color = RikitColors.primary.withValues(alpha: .13),
      );
    }

    for (var index = firstVisible; index <= lastVisible; index++) {
      final painter = TextPainter(
        text: TextSpan(
          text: '${index + 1}',
          style: TextStyle(
            color: index == errorLine
                ? RikitColors.primary
                : RikitColors.textMuted,
            fontFamily: 'monospace',
            fontSize: 11,
            height: 13 / 11,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          size.width - painter.width - 9,
          verticalPadding + index * lineExtent,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineNumberGutterPainter oldDelegate) {
    return lineCount != oldDelegate.lineCount ||
        errorLine != oldDelegate.errorLine ||
        lineExtent != oldDelegate.lineExtent ||
        verticalPadding != oldDelegate.verticalPadding;
  }
}
