import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/search_utils.dart';

/// Drop-in replacement for [Text] that highlights substring matches.
///
/// When [query] is empty, renders a plain [Text] (zero overhead).
/// Otherwise normalizes both [text] and [query] via [normalizeSearch]
/// (1:1 char mapping — lengths always match) and builds a [RichText]
/// with highlighted segments using a purple-tinted background.
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    super.key,
    this.query = '',
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || text.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final normalizedText = normalizeSearch(text);
    final normalizedQuery = normalizeSearch(query);

    if (normalizedQuery.isEmpty || !normalizedText.contains(normalizedQuery)) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final highlightBg = context.appColors.searchHighlight;
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final highlightStyle = baseStyle.copyWith(backgroundColor: highlightBg);

    final spans = <TextSpan>[];
    var start = 0;
    final qLen = normalizedQuery.length;

    while (start < normalizedText.length) {
      final idx = normalizedText.indexOf(normalizedQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + qLen),
        style: highlightStyle,
      ));
      start = idx + qLen;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
