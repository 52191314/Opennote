/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';

class AdaptiveLinearProgressIndicator extends LinearProgressIndicator {
  const AdaptiveLinearProgressIndicator({
    super.key,
    super.value,
    super.backgroundColor,
    super.color,
    super.valueColor,
    super.minHeight,
    super.semanticsLabel,
    super.semanticsValue,
    super.borderRadius,
    super.stopIndicatorColor,
    super.stopIndicatorRadius,
    super.trackGap,
  });

  @override
  State<AdaptiveLinearProgressIndicator> createState() =>
      _AdaptiveLinearProgressIndicatorState();
}

class _AdaptiveLinearProgressIndicatorState
    extends State<AdaptiveLinearProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: widget.value,
      backgroundColor: widget.backgroundColor,
      color: widget.color,
      valueColor: widget.valueColor,
      minHeight: widget.minHeight,
      semanticsLabel: widget.semanticsLabel,
      semanticsValue: widget.semanticsValue,
      borderRadius: widget.borderRadius,
      stopIndicatorColor: widget.stopIndicatorColor,
      stopIndicatorRadius: widget.stopIndicatorRadius,
      trackGap: widget.trackGap,
    );
  }
}
