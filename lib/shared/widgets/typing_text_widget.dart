import 'package:flutter/material.dart';
import 'dart:async';

class TypingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final bool showCursor;
  final Duration delay;

  const TypingTextWidget({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 30),
    this.showCursor = true,
    this.delay = Duration.zero,
  });

  @override
  State<TypingTextWidget> createState() => _TypingTextWidgetState();
}

class _TypingTextWidgetState extends State<TypingTextWidget> {
  String _displayedText = '';
  Timer? _timer;
  Timer? _delayTimer;
  int _currentIndex = 0;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    if (widget.showCursor) {
      _startCursorBlink();
    }
    if (widget.delay == Duration.zero) {
      _startTyping();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) {
          _startTyping();
        }
      });
    }
  }

  void _startTyping() {
    _currentIndex = 0;
    _displayedText = '';
    _timer?.cancel();
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startCursorBlink() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(TypingTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: widget.style ?? DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: _displayedText),
          if (widget.showCursor && _currentIndex < widget.text.length)
            TextSpan(
              text: _showCursor ? '▊' : '',
              style: TextStyle(
                color: widget.style?.color ?? DefaultTextStyle.of(context).style.color,
              ),
            ),
        ],
      ),
    );
  }
}
