/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';

class FaqListView extends StatelessWidget {
  const FaqListView({super.key, required this.items, this.shrinkWrap = false});

  final List<FaqItem> items;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: shrinkWrap,
      itemBuilder: (BuildContext context, int index) {
        return _FaqTile(item: items[index]);
      },
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    // ignore: unused_element_parameter
    super.key,
    required this.item,
  });

  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(item.question),
      childrenPadding: const .all(16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [SelectableText(item.answer)],
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem(this.question, this.answer);
}
