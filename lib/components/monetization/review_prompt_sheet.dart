/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// Internal step of the two-step ASO rating funnel.
enum _ReviewPromptStep {
  sentimentCheck,
  positiveStoreReview,
  privateFeedback,
  feedbackSubmitted,
}

/// Callback signature for private constructive feedback submission.
typedef ReviewFeedbackCallback =
    void Function(String message, Set<String> selectedTopics);

/// Two-step ASO rating funnel bottom sheet.
///
/// Step 1 asks "How is Opennote working for you?".
/// - "Love it!" routes delighted users to the native Store Review prompt.
/// - "Could be better" routes users to a private feedback form so issues are
///   captured directly and resolved instead of becoming 1-star store reviews.
class ReviewPromptSheet extends StatefulWidget {
  /// Creates a [ReviewPromptSheet].
  const ReviewPromptSheet({
    super.key,
    this.onRequestStoreReview,
    this.onSubmitFeedback,
    this.onDismiss,
  });

  /// Invoked when a happy user confirms rating Opennote on the Store.
  final VoidCallback? onRequestStoreReview;

  /// Invoked when a user submits constructive private feedback.
  final ReviewFeedbackCallback? onSubmitFeedback;

  /// Invoked when the user dismisses the prompt.
  final VoidCallback? onDismiss;

  /// Presents [ReviewPromptSheet] as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onRequestStoreReview,
    ReviewFeedbackCallback? onSubmitFeedback,
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => ReviewPromptSheet(
        onRequestStoreReview: onRequestStoreReview,
        onSubmitFeedback: onSubmitFeedback,
        onDismiss: () {
          Navigator.of(sheetContext).maybePop();
          onDismiss?.call();
        },
      ),
    );
  }

  @override
  State<ReviewPromptSheet> createState() => _ReviewPromptSheetState();
}

class _ReviewPromptSheetState extends State<ReviewPromptSheet> {
  static const _feedbackTopics = <String>[
    'Drawing & Ink',
    'Templates',
    'Cloud Sync',
    'PDF / Export',
    'Performance',
  ];

  var _step = _ReviewPromptStep.sentimentCheck;
  final _feedbackController = TextEditingController();
  final _selectedTopics = <String>{};

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleLoveIt() {
    setState(() => _step = _ReviewPromptStep.positiveStoreReview);
    widget.onRequestStoreReview?.call();
  }

  void _handleCouldBeBetter() {
    setState(() => _step = _ReviewPromptStep.privateFeedback);
  }

  void _handleSubmitFeedback() {
    widget.onSubmitFeedback?.call(
      _feedbackController.text.trim(),
      Set<String>.unmodifiable(_selectedTopics),
    );
    setState(() => _step = _ReviewPromptStep.feedbackSubmitted);
  }

  void _handleClose() {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            OpennoteTokens.s5,
            OpennoteTokens.s3,
            OpennoteTokens.s5,
            OpennoteTokens.s5,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant.withValues(alpha: 0.55),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(OpennoteTokens.radiusPill),
                        ),
                      ),
                      child: const SizedBox(width: 36, height: 4),
                    ),
                  ),
                  const SizedBox(height: OpennoteTokens.s4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: switch (_step) {
                      _ReviewPromptStep.sentimentCheck => _buildSentimentStep(
                        context,
                      ),
                      _ReviewPromptStep.positiveStoreReview =>
                        _buildPositiveStep(context),
                      _ReviewPromptStep.privateFeedback =>
                        _buildPrivateFeedbackStep(context),
                      _ReviewPromptStep.feedbackSubmitted =>
                        _buildThankYouFeedbackStep(context),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSentimentStep(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF91A7FF) : OpennoteTokens.brandSeed;

    return Column(
      key: const ValueKey('review_step_sentiment'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.auto_awesome_rounded, color: accent, size: 28),
            ),
          ),
        ),
        const SizedBox(height: OpennoteTokens.s4),
        Text(
          'How is Opennote working for you?',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: OpennoteTokens.s2),
        Text(
          'Your honest feedback helps us build a sharper studio for engineers and note-takers.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: OpennoteTokens.s5),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            key: const Key('review_love_it_button'),
            onPressed: _handleLoveIt,
            style: FilledButton.styleFrom(
              backgroundColor: OpennoteTokens.brandSeed,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(OpennoteTokens.radiusMd),
                ),
              ),
            ),
            icon: const Icon(Icons.favorite_rounded, size: 18),
            label: const Text(
              'Love it!',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: OpennoteTokens.s2),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            key: const Key('review_could_be_better_button'),
            onPressed: _handleCouldBeBetter,
            style: OutlinedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(OpennoteTokens.radiusMd),
                ),
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text(
              'Could be better',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: OpennoteTokens.s1),
        TextButton(
          key: const Key('review_later_button'),
          onPressed: _handleClose,
          child: const Text('Maybe later'),
        ),
      ],
    );
  }

  Widget _buildPositiveStep(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final successColor = isDark
        ? const Color(0xFF8CE99A)
        : const Color(0xFF15803D);

    return Column(
      key: const ValueKey('review_step_positive'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.star_rounded, color: successColor, size: 30),
            ),
          ),
        ),
        const SizedBox(height: OpennoteTokens.s4),
        Text(
          'Thank you for supporting Opennote!',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: OpennoteTokens.s2),
        Text(
          'A quick rating on the App Store or Play Store helps other students and engineers discover Opennote.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: OpennoteTokens.s5),
        SizedBox(
          height: 48,
          child: FilledButton(
            key: const Key('review_done_button'),
            onPressed: _handleClose,
            style: FilledButton.styleFrom(
              backgroundColor: OpennoteTokens.brandSeed,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(OpennoteTokens.radiusMd),
                ),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivateFeedbackStep(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      key: const ValueKey('review_step_feedback'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How can we make Opennote better?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: OpennoteTokens.s2),
        Text(
          'Tell us what felt rough or missing — your note goes straight to our engineering team.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: OpennoteTokens.s4),
        Wrap(
          spacing: OpennoteTokens.s2,
          runSpacing: OpennoteTokens.s2,
          children: [
            for (final topic in _feedbackTopics)
              FilterChip(
                label: Text(topic),
                selected: _selectedTopics.contains(topic),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTopics.add(topic);
                    } else {
                      _selectedTopics.remove(topic);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: OpennoteTokens.s4),
        TextField(
          key: const Key('review_feedback_textfield'),
          controller: _feedbackController,
          maxLines: 3,
          minLines: 2,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'Share details or ideas (optional)...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(OpennoteTokens.radiusMd),
              ),
            ),
          ),
        ),
        const SizedBox(height: OpennoteTokens.s4),
        SizedBox(
          height: 48,
          child: FilledButton(
            key: const Key('review_send_feedback_button'),
            onPressed: _handleSubmitFeedback,
            style: FilledButton.styleFrom(
              backgroundColor: OpennoteTokens.brandSeed,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(OpennoteTokens.radiusMd),
                ),
              ),
            ),
            child: const Text(
              'Send Private Feedback',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: OpennoteTokens.s1),
        TextButton(
          onPressed: () =>
              setState(() => _step = _ReviewPromptStep.sentimentCheck),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Widget _buildThankYouFeedbackStep(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF91A7FF) : OpennoteTokens.brandSeed;

    return Column(
      key: const ValueKey('review_step_submitted'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.mark_email_read_rounded,
                color: accent,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: OpennoteTokens.s4),
        Text(
          'Thanks — we heard you!',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: OpennoteTokens.s2),
        Text(
          'Your feedback has been logged so we can prioritize improvements in upcoming releases.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: OpennoteTokens.s5),
        SizedBox(
          height: 48,
          child: FilledButton(
            key: const Key('review_feedback_done_button'),
            onPressed: _handleClose,
            style: FilledButton.styleFrom(
              backgroundColor: OpennoteTokens.brandSeed,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(OpennoteTokens.radiusMd),
                ),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
