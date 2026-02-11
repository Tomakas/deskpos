import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

const _gridCols = 16;
const _gridRows = 10;

class FloorMapEditorTab extends ConsumerStatefulWidget {
  const FloorMapEditorTab({super.key});

  @override
  ConsumerState<FloorMapEditorTab> createState() => _FloorMapEditorTabState();
}

class _FloorMapEditorTabState extends ConsumerState<FloorMapEditorTab> {
  String? _selectedSectionId;
  String? _draggingTableId;

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<SectionModel>>(
      stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
      builder: (context, sectionSnap) {
        final sections = sectionSnap.data ?? [];
        if (sections.isEmpty) return const SizedBox.shrink();

        // Resolve effective section ID
        final sectionId = sections.any((s) => s.id == _selectedSectionId)
            ? _selectedSectionId!
            : sections.first.id;
        final selectedSection = sections.firstWhere((s) => s.id == sectionId);

        return StreamBuilder<List<TableModel>>(
          stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
          builder: (context, tableSnap) {
            final allTables = tableSnap.data ?? [];
            final placedTables = allTables.where((t) =>
                t.sectionId == sectionId &&
                t.gridRow >= 0 &&
                t.gridCol >= 0 &&
                t.gridRow < _gridRows &&
                t.gridCol < _gridCols).toList();

            return Column(
              children: [
                _buildSectionSelector(sections, sectionId),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cellW = constraints.maxWidth / _gridCols;
                        final cellH = constraints.maxHeight / _gridRows;

                        return Stack(
                          children: [
                            // Grid cells with DragTargets
                            for (int r = 0; r < _gridRows; r++)
                              for (int c = 0; c < _gridCols; c++)
                                Positioned(
                                  left: c * cellW,
                                  top: r * cellH,
                                  width: cellW,
                                  height: cellH,
                                  child: DragTarget<TableModel>(
                                    onWillAcceptWithDetails: (details) =>
                                        _canPlaceAt(details.data, r, c, placedTables),
                                    onAcceptWithDetails: (details) =>
                                        _moveTable(details.data, r, c),
                                    builder: (context, candidateData, rejectedData) {
                                      return _EmptyCell(
                                        highlighted: candidateData.isNotEmpty,
                                        onTap: () => _showPlaceTableDialog(
                                          context,
                                          selectedSection,
                                          allTables,
                                          placedTables,
                                          r,
                                          c,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            // Placed tables
                            for (final table in placedTables)
                              Positioned(
                                left: table.gridCol * cellW,
                                top: table.gridRow * cellH,
                                width: table.gridWidth * cellW,
                                height: table.gridHeight * cellH,
                                child: _draggingTableId == table.id
                                    ? IgnorePointer(
                                        child: Opacity(
                                          opacity: 0.3,
                                          child: _TableCell(
                                            table: table,
                                            section: selectedSection,
                                            onTap: () {},
                                          ),
                                        ),
                                      )
                                    : LongPressDraggable<TableModel>(
                                        data: table,
                                        delay: const Duration(milliseconds: 300),
                                        onDragStarted: () =>
                                            setState(() => _draggingTableId = table.id),
                                        onDragEnd: (_) =>
                                            setState(() => _draggingTableId = null),
                                        feedback: Material(
                                          elevation: 6,
                                          borderRadius: BorderRadius.circular(6),
                                          color: Colors.transparent,
                                          child: Opacity(
                                            opacity: 0.85,
                                            child: SizedBox(
                                              width: table.gridWidth * cellW,
                                              height: table.gridHeight * cellH,
                                              child: _TableCell(
                                                table: table,
                                                section: selectedSection,
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: _TableCell(
                                          table: table,
                                          section: selectedSection,
                                          onTap: () => _showEditTableDialog(
                                            context,
                                            allTables,
                                            placedTables,
                                            table,
                                          ),
                                        ),
                                      ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionSelector(List<SectionModel> sections, String activeSectionId) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilterChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(sections[i].name, textAlign: TextAlign.center),
                  ),
                  selected: sections[i].id == activeSectionId,
                  onSelected: (_) => setState(() => _selectedSectionId = sections[i].id),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canPlaceAt(TableModel table, int row, int col, List<TableModel> placedTables) {
    if (row + table.gridHeight > _gridRows) return false;
    if (col + table.gridWidth > _gridCols) return false;
    for (final other in placedTables) {
      if (other.id == table.id) continue;
      if (row < other.gridRow + other.gridHeight &&
          row + table.gridHeight > other.gridRow &&
          col < other.gridCol + other.gridWidth &&
          col + table.gridWidth > other.gridCol) {
        return false;
      }
    }
    return true;
  }

  Future<void> _moveTable(TableModel table, int row, int col) async {
    await ref.read(tableRepositoryProvider).update(
      table.copyWith(gridRow: row, gridCol: col),
    );
  }

  Future<void> _showPlaceTableDialog(
    BuildContext context,
    SectionModel section,
    List<TableModel> allTables,
    List<TableModel> placedTables,
    int row,
    int col,
  ) async {
    // Check if this cell is occupied by an existing table
    final occupying = placedTables.where((t) =>
        row >= t.gridRow &&
        row < t.gridRow + t.gridHeight &&
        col >= t.gridCol &&
        col < t.gridCol + t.gridWidth).firstOrNull;
    if (occupying != null) {
      _showEditTableDialog(context, allTables, placedTables, occupying);
      return;
    }

    final l = context.l10n;
    // Unplaced tables in this section
    final unplacedTables = allTables.where((t) =>
        t.sectionId == section.id &&
        (t.gridRow < 0 ||
         t.gridCol < 0 ||
         t.gridRow >= _gridRows ||
         t.gridCol >= _gridCols ||
         !placedTables.contains(t))).toList();

    String? selectedTableId;
    int width = 1;
    int height = 1;

    final result = await showDialog<_PlaceResult>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(l.floorMapAddTable),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String?>(
                    value: selectedTableId,
                    decoration: InputDecoration(labelText: l.floorMapSelectTable),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l.floorMapNewTable),
                      ),
                      ...unplacedTables.map((t) =>
                          DropdownMenuItem<String?>(value: t.id, child: Text(t.name))),
                    ],
                    onChanged: (v) => setDialogState(() => selectedTableId = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SpinnerField(
                          label: l.floorMapWidth,
                          value: width,
                          min: 1,
                          max: 4,
                          onChanged: (v) => setDialogState(() => width = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpinnerField(
                          label: l.floorMapHeight,
                          value: height,
                          min: 1,
                          max: 4,
                          onChanged: (v) => setDialogState(() => height = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, _PlaceResult(
                  tableId: selectedTableId,
                  width: width,
                  height: height,
                )),
                child: Text(l.actionSave),
              ),
            ],
          );
        },
      ),
    );

    if (result == null) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(tableRepositoryProvider);

    if (result.tableId != null) {
      // Update existing table position
      final table = allTables.firstWhere((t) => t.id == result.tableId);
      await repo.update(table.copyWith(
        gridRow: row,
        gridCol: col,
        gridWidth: result.width,
        gridHeight: result.height,
      ));
    } else {
      // Create new table in the selected section
      final now = DateTime.now();
      final tableCount = allTables.where((t) => t.sectionId == section.id).length;
      final tableName = '${section.name} ${tableCount + 1}';
      await repo.create(TableModel(
        id: const Uuid().v7(),
        companyId: company.id,
        name: tableName,
        sectionId: section.id,
        gridRow: row,
        gridCol: col,
        gridWidth: result.width,
        gridHeight: result.height,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _showEditTableDialog(
    BuildContext context,
    List<TableModel> allTables,
    List<TableModel> placedTables,
    TableModel table,
  ) async {
    final l = context.l10n;
    int width = table.gridWidth;
    int height = table.gridHeight;

    final result = await showDialog<_EditResult>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(l.floorMapEditTable),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(table.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SpinnerField(
                          label: l.floorMapWidth,
                          value: width,
                          min: 1,
                          max: 4,
                          onChanged: (v) => setDialogState(() => width = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpinnerField(
                          label: l.floorMapHeight,
                          value: height,
                          min: 1,
                          max: 4,
                          onChanged: (v) => setDialogState(() => height = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(ctx, const _EditResult(remove: true)),
                child: Text(l.floorMapRemoveTable),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, _EditResult(
                  width: width,
                  height: height,
                )),
                child: Text(l.actionSave),
              ),
            ],
          );
        },
      ),
    );

    if (result == null) return;

    final repo = ref.read(tableRepositoryProvider);

    if (result.remove) {
      // Remove from map by setting grid position out of bounds
      await repo.update(table.copyWith(
        gridRow: -1,
        gridCol: -1,
      ));
    } else {
      await repo.update(table.copyWith(
        gridWidth: result.width,
        gridHeight: result.height,
      ));
    }
  }
}

class _EmptyCell extends StatelessWidget {
  const _EmptyCell({required this.onTap, this.highlighted = false});
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
        color: highlighted
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
            : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.table,
    required this.section,
    required this.onTap,
  });
  final TableModel table;
  final SectionModel? section;
  final VoidCallback onTap;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blueGrey;
    try {
      final colorValue = int.parse(hex.replaceFirst('#', ''), radix: 16);
      return Color(colorValue | 0xFF000000);
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(section?.color);

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  table.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerField extends StatelessWidget {
  const _SpinnerField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove, size: 18),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
            Expanded(
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add, size: 18),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlaceResult {
  const _PlaceResult({
    this.tableId,
    required this.width,
    required this.height,
  });
  final String? tableId;
  final int width;
  final int height;
}

class _EditResult {
  const _EditResult({
    this.width = 1,
    this.height = 1,
    this.remove = false,
  });
  final int width;
  final int height;
  final bool remove;
}
