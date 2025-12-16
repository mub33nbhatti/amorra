import 'package:flutter/material.dart';

/// Text Formatter Utility
/// Parses markdown-like syntax and converts to TextSpan widgets
/// Supports: **bold**, *italic*, `code`, ~~strikethrough~~
class TextFormatter {
  /// Parse text with markdown-like formatting and return TextSpan
  /// 
  /// Supported formats:
  /// - `**text**` or `__text__` for bold
  /// - `*text*` or `_text_` for italic (single asterisk/underscore, not part of bold)
  /// - `` `text` `` for inline code
  /// - `~~text~~` for strikethrough
  static TextSpan parseMarkdown(
    String text, {
    required TextStyle baseStyle,
    TextStyle? boldStyle,
    TextStyle? italicStyle,
    TextStyle? codeStyle,
    TextStyle? strikethroughStyle,
  }) {
    // Default styles if not provided
    final bold = boldStyle ?? baseStyle.copyWith(fontWeight: FontWeight.bold);
    final italic = italicStyle ?? baseStyle.copyWith(fontStyle: FontStyle.italic);
    final code = codeStyle ?? baseStyle.copyWith(
      fontFamily: 'monospace',
      backgroundColor: baseStyle.color?.withOpacity(0.1),
    );
    final strikethrough = strikethroughStyle ?? baseStyle.copyWith(
      decoration: TextDecoration.lineThrough,
    );

    // Parse using a recursive approach to handle nested formatting
    return _parseText(text, baseStyle, bold, italic, code, strikethrough);
  }

  /// Internal recursive parser
  static TextSpan _parseText(
    String text,
    TextStyle baseStyle,
    TextStyle boldStyle,
    TextStyle italicStyle,
    TextStyle codeStyle,
    TextStyle strikethroughStyle,
  ) {
    final List<TextSpan> spans = [];
    int index = 0;

    while (index < text.length) {
      int? nextMatch;
      String? matchType;
      int matchLength = 0;

      // Find the earliest match among all formats
      // Check for bold **text** (priority: check before single *)
      final boldAsteriskMatch = text.indexOf('**', index);
      if (boldAsteriskMatch != -1) {
        final endIndex = text.indexOf('**', boldAsteriskMatch + 2);
        if (endIndex != -1) {
          if (nextMatch == null || boldAsteriskMatch < nextMatch) {
            nextMatch = boldAsteriskMatch;
            matchType = 'bold_asterisk';
            matchLength = endIndex - boldAsteriskMatch + 2;
          }
        }
      }

      // Check for bold __text__
      final boldUnderscoreMatch = text.indexOf('__', index);
      if (boldUnderscoreMatch != -1) {
        final endIndex = text.indexOf('__', boldUnderscoreMatch + 2);
        if (endIndex != -1) {
          if (nextMatch == null || boldUnderscoreMatch < nextMatch) {
            nextMatch = boldUnderscoreMatch;
            matchType = 'bold_underscore';
            matchLength = endIndex - boldUnderscoreMatch + 2;
          }
        }
      }

      // Check for strikethrough ~~text~~
      final strikethroughMatch = text.indexOf('~~', index);
      if (strikethroughMatch != -1) {
        final endIndex = text.indexOf('~~', strikethroughMatch + 2);
        if (endIndex != -1) {
          if (nextMatch == null || strikethroughMatch < nextMatch) {
            nextMatch = strikethroughMatch;
            matchType = 'strikethrough';
            matchLength = endIndex - strikethroughMatch + 2;
          }
        }
      }

      // Check for code `text`
      final codeMatch = text.indexOf('`', index);
      if (codeMatch != -1) {
        final endIndex = text.indexOf('`', codeMatch + 1);
        if (endIndex != -1) {
          if (nextMatch == null || codeMatch < nextMatch) {
            nextMatch = codeMatch;
            matchType = 'code';
            matchLength = endIndex - codeMatch + 1;
          }
        }
      }

      // Check for italic *text* (only if not part of **)
      final italicAsteriskMatch = text.indexOf('*', index);
      if (italicAsteriskMatch != -1) {
        // Make sure it's not part of ** (check before and after)
        final isNotBoldStart = italicAsteriskMatch == 0 || text[italicAsteriskMatch - 1] != '*';
        final isNotBoldEnd = italicAsteriskMatch >= text.length - 1 || text[italicAsteriskMatch + 1] != '*';
        
        if (isNotBoldStart && isNotBoldEnd) {
          final endIndex = text.indexOf('*', italicAsteriskMatch + 1);
          if (endIndex != -1) {
            // Make sure the closing * is not part of **
            final isNotBoldEndClose = endIndex >= text.length - 1 || text[endIndex + 1] != '*';
            if (isNotBoldEndClose) {
              if (nextMatch == null || italicAsteriskMatch < nextMatch) {
                nextMatch = italicAsteriskMatch;
                matchType = 'italic_asterisk';
                matchLength = endIndex - italicAsteriskMatch + 1;
              }
            }
          }
        }
      }

      // Check for italic _text_ (only if not part of __)
      final italicUnderscoreMatch = text.indexOf('_', index);
      if (italicUnderscoreMatch != -1) {
        // Make sure it's not part of __ (check before and after)
        final isNotBoldStart = italicUnderscoreMatch == 0 || text[italicUnderscoreMatch - 1] != '_';
        final isNotBoldEnd = italicUnderscoreMatch >= text.length - 1 || text[italicUnderscoreMatch + 1] != '_';
        
        if (isNotBoldStart && isNotBoldEnd) {
          final endIndex = text.indexOf('_', italicUnderscoreMatch + 1);
          if (endIndex != -1) {
            // Make sure the closing _ is not part of __
            final isNotBoldEndClose = endIndex >= text.length - 1 || text[endIndex + 1] != '_';
            if (isNotBoldEndClose) {
              if (nextMatch == null || italicUnderscoreMatch < nextMatch) {
                nextMatch = italicUnderscoreMatch;
                matchType = 'italic_underscore';
                matchLength = endIndex - italicUnderscoreMatch + 1;
              }
            }
          }
        }
      }

      if (nextMatch != null && matchType != null) {
        // Add text before the match
        if (nextMatch > index) {
          final beforeText = text.substring(index, nextMatch);
          spans.add(TextSpan(text: beforeText, style: baseStyle));
        }

        // Extract and parse the matched content
        String content;
        TextStyle style;
        
        switch (matchType) {
          case 'bold_asterisk':
            content = text.substring(nextMatch + 2, nextMatch + matchLength - 2);
            style = boldStyle;
            break;
          case 'bold_underscore':
            content = text.substring(nextMatch + 2, nextMatch + matchLength - 2);
            style = boldStyle;
            break;
          case 'strikethrough':
            content = text.substring(nextMatch + 2, nextMatch + matchLength - 2);
            style = strikethroughStyle;
            break;
          case 'code':
            content = text.substring(nextMatch + 1, nextMatch + matchLength - 1);
            style = codeStyle;
            break;
          case 'italic_asterisk':
            content = text.substring(nextMatch + 1, nextMatch + matchLength - 1);
            style = italicStyle;
            break;
          case 'italic_underscore':
            content = text.substring(nextMatch + 1, nextMatch + matchLength - 1);
            style = italicStyle;
            break;
          default:
            content = '';
            style = baseStyle;
        }

        // Recursively parse nested formatting
        // Use the matched style as base, but allow nested formatting
        final nestedSpan = _parseText(
          content, 
          style, // Use the matched style as base
          boldStyle.copyWith(color: style.color), // Preserve color from parent
          italicStyle.copyWith(color: style.color),
          codeStyle.copyWith(color: style.color),
          strikethroughStyle.copyWith(color: style.color),
        );
        spans.add(nestedSpan);

        index = nextMatch + matchLength;
      } else {
        // No more matches, add remaining text
        if (index < text.length) {
          spans.add(TextSpan(text: text.substring(index), style: baseStyle));
        }
        break;
      }
    }

    // If no formatting was found, return simple text span
    if (spans.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    // If only one span and it's plain text, return it directly
    if (spans.length == 1 && spans[0].style == baseStyle && spans[0].children == null) {
      return spans[0];
    }

    return TextSpan(children: spans);
  }
}

