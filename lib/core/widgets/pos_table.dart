import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// PosColumn<T> — column definition
// ---------------------------------------------------------------------------

class PosColumn<T> {
  const PosColumn({
    required this.label,
    this.flex = 1,
    this.width,
    required this.cellBuilder,
    this.numeric = false,
    this.headerAlign,
  });

  final String label;
  final int flex;

  /// If set, uses [SizedBox] instead of [Expanded].
  final double? width;

  final Widget Function(T item) cellBuilder;

  /// Right-aligns the header text.
  final bool numeric;

  /// Explicit header alignment. When set, overrides [numeric].
  final TextAlign? headerAlign;
}

// ---------------------------------------------------------------------------
// PosTable<T> — header + list body + optional footer
// ---------------------------------------------------------------------------

class PosTable<T> extends StatelessWidget {
  const PosTable({
    super.key,
    required this.columns,
    required this.items,
    this.onRowTap,
    this.rowColor,
    this.emptyMessage,
    this.footer,
  });

  final List<PosColumn<T>> columns;
  final List<T> items;
  final void Function(T item)? onRowTap;
  final Color? Function(T item)? rowColor;
  final String? emptyMessage;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle =
        theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              for (final col in columns) _wrapColumn(col, _headerCell(col, headerStyle)),
            ],
          ),
        ),
        // Body
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    emptyMessage ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final color = rowColor?.call(item);
                    return InkWell(
                      onTap: onRowTap != null ? () => onRowTap!(item) : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: color,
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  theme.dividerColor.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            for (final col in columns)
                              _wrapColumn(col, col.cellBuilder(item)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Footer
        ?footer,
      ],
    );
  }

  Widget _headerCell(PosColumn<T> col, TextStyle? style) {
    return Text(
      col.label,
      style: style,
      textAlign: col.headerAlign ?? (col.numeric ? TextAlign.right : null),
    );
  }

  Widget _wrapColumn(PosColumn<T> col, Widget child) {
    final content = DefaultTextStyle.merge(
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: child,
    );
    if (col.width != null) {
      return SizedBox(width: col.width, child: content);
    }
    return Expanded(flex: col.flex, child: content);
  }
}

// ---------------------------------------------------------------------------
// PosTableToolbar — search + trailing actions
// ---------------------------------------------------------------------------

class PosTableToolbar extends StatelessWidget {
  const PosTableToolbar({
    super.key,
    this.searchController,
    this.searchHint,
    this.onSearchChanged,
    this.trailing = const [],
  });

  final TextEditingController? searchController;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (searchController != null) ...[
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController!.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            searchController!.clear();
                            onSearchChanged?.call('');
                          },
                        )
                      : null,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: onSearchChanged,
              ),
            ),
            if (trailing.isNotEmpty) const SizedBox(width: 16),
          ] else
            const Spacer(),
          ...trailing,
        ],
      ),
    );
  }
}
