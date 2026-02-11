import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/table_shape.dart';
import '../../../core/data/models/map_element_model.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

const _gridCols = 32;
const _gridRows = 20;

enum _HandlePos { tl, tr, br, bl }

const _elementColors = [
  '#795548',
  '#607D8B',
  '#9E9E9E',
  '#4CAF50',
  '#2196F3',
  '#FF9800',
  '#F44336',
  '#000000',
];

class FloorMapEditorTab extends ConsumerStatefulWidget {
  const FloorMapEditorTab({super.key});

  @override
  ConsumerState<FloorMapEditorTab> createState() => _FloorMapEditorTabState();
}

class _FloorMapEditorTabState extends ConsumerState<FloorMapEditorTab> {
  String? _selectedSectionId;
  int? _dragHoverRow;
  int? _dragHoverCol;
  Object? _draggedItem; // TableModel or MapElementModel

  // Selection
  String? _selectedId;
  bool _selectedIsTable = true;

  // Resize
  bool _isResizing = false;
  _HandlePos? _activeHandle;
  Offset? _dragStartGlobal;
  int _origRow = 0, _origCol = 0, _origW = 0, _origH = 0;
  int _previewRow = 0, _previewCol = 0, _previewW = 0, _previewH = 0;

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<SectionModel>>(
      stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
      builder: (context, sectionSnap) {
        final sections = sectionSnap.data ?? [];
        if (sections.isEmpty) return const SizedBox.shrink();

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

            return StreamBuilder<List<MapElementModel>>(
              stream: ref.watch(mapElementRepositoryProvider).watchAll(company.id),
              builder: (context, elementSnap) {
                final allElements = elementSnap.data ?? [];
                final placedElements = allElements.where((e) =>
                    e.sectionId == sectionId &&
                    e.gridRow >= 0 &&
                    e.gridCol >= 0 &&
                    e.gridRow < _gridRows &&
                    e.gridCol < _gridCols).toList();

                final coloredElements = placedElements.where((e) => e.color != null).toList();
                final textElements = placedElements.where((e) => e.color == null && e.label != null).toList();

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
                                        child: DragTarget<Object>(
                                          onWillAcceptWithDetails: (details) {
                                            if (details.data is TableModel) {
                                              final table = details.data as TableModel;
                                              final canPlace = _canPlaceAt(table, r, c, placedTables);
                                              if (canPlace && (_dragHoverRow != r || _dragHoverCol != c)) {
                                                setState(() {
                                                  _dragHoverRow = r;
                                                  _dragHoverCol = c;
                                                  _draggedItem = table;
                                                });
                                              }
                                              return canPlace;
                                            } else if (details.data is MapElementModel) {
                                              final elem = details.data as MapElementModel;
                                              if (_dragHoverRow != r || _dragHoverCol != c) {
                                                setState(() {
                                                  _dragHoverRow = r;
                                                  _dragHoverCol = c;
                                                  _draggedItem = elem;
                                                });
                                              }
                                              return true;
                                            }
                                            return false;
                                          },
                                          onLeave: (_) {
                                            if (_dragHoverRow == r && _dragHoverCol == c) {
                                              setState(() {
                                                _dragHoverRow = null;
                                                _dragHoverCol = null;
                                                _draggedItem = null;
                                              });
                                            }
                                          },
                                          onAcceptWithDetails: (details) {
                                            setState(() {
                                              _dragHoverRow = null;
                                              _dragHoverCol = null;
                                              _draggedItem = null;
                                            });
                                            if (details.data is TableModel) {
                                              _moveTable(details.data as TableModel, r, c);
                                            } else if (details.data is MapElementModel) {
                                              _moveElement(details.data as MapElementModel, r, c);
                                            }
                                          },
                                          builder: (context, candidateData, rejectedData) {
                                            final isHighlighted = _draggedItem != null &&
                                                _dragHoverRow != null &&
                                                _dragHoverCol != null &&
                                                _isInDragHover(r, c);
                                            return _EmptyCell(
                                              highlighted: isHighlighted,
                                              onTap: () => _showPlaceDialog(
                                                context,
                                                selectedSection,
                                                allTables,
                                                placedTables,
                                                placedElements,
                                                r,
                                                c,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  // Colored elements (under tables)
                                  for (final elem in coloredElements)
                                    _buildElementPositioned(elem, cellW, cellH, allElements, selectedSection),
                                  // Tables
                                  for (final table in placedTables)
                                    _buildTablePositioned(table, cellW, cellH, allTables, placedTables, selectedSection),
                                  // Text-only elements (over tables)
                                  for (final elem in textElements)
                                    _buildElementPositioned(elem, cellW, cellH, allElements, selectedSection),
                                  // Resize preview
                                  if (_isResizing)
                                    Positioned(
                                      left: _previewCol * cellW,
                                      top: _previewRow * cellH,
                                      width: _previewW * cellW,
                                      height: _previewH * cellH,
                                      child: IgnorePointer(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.primary,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Selection highlight + resize handles
                                  if (_selectedId != null)
                                    ..._buildSelectionOverlay(
                                      cellW, cellH, placedTables, placedElements, allTables, allElements,
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
      },
    );
  }

  bool _isInDragHover(int r, int c) {
    if (_draggedItem == null || _dragHoverRow == null || _dragHoverCol == null) return false;
    int h, w;
    if (_draggedItem is TableModel) {
      h = (_draggedItem as TableModel).gridHeight;
      w = (_draggedItem as TableModel).gridWidth;
    } else if (_draggedItem is MapElementModel) {
      h = (_draggedItem as MapElementModel).gridHeight;
      w = (_draggedItem as MapElementModel).gridWidth;
    } else {
      return false;
    }
    return r >= _dragHoverRow! &&
        r < _dragHoverRow! + h &&
        c >= _dragHoverCol! &&
        c < _dragHoverCol! + w;
  }

  Widget _buildTablePositioned(
    TableModel table,
    double cellW,
    double cellH,
    List<TableModel> allTables,
    List<TableModel> placedTables,
    SectionModel section,
  ) {
    return Positioned(
      left: table.gridCol * cellW,
      top: table.gridRow * cellH,
      width: table.gridWidth * cellW,
      height: table.gridHeight * cellH,
      child: LongPressDraggable<TableModel>(
        data: table,
        delay: const Duration(milliseconds: 300),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDragStarted: () => setState(() => _selectedId = null),
        onDragEnd: (_) => setState(() {
          _dragHoverRow = null;
          _dragHoverCol = null;
          _draggedItem = null;
        }),
        feedback: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(6),
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.85,
            child: SizedBox(
              width: table.gridWidth * cellW,
              height: table.gridHeight * cellH,
              child: _TableCell(table: table, section: section),
            ),
          ),
        ),
        childWhenDragging: IgnorePointer(
          child: Opacity(
            opacity: 0.3,
            child: _TableCell(table: table, section: section),
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() {
            _selectedId = table.id;
            _selectedIsTable = true;
          }),
          onDoubleTap: () => _showEditTableDialog(context, allTables, placedTables, table),
          child: _TableCell(table: table, section: section),
        ),
      ),
    );
  }

  Widget _buildElementPositioned(
    MapElementModel elem,
    double cellW,
    double cellH,
    List<MapElementModel> allElements,
    SectionModel section,
  ) {
    return Positioned(
      left: elem.gridCol * cellW,
      top: elem.gridRow * cellH,
      width: elem.gridWidth * cellW,
      height: elem.gridHeight * cellH,
      child: LongPressDraggable<MapElementModel>(
        data: elem,
        delay: const Duration(milliseconds: 300),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDragStarted: () => setState(() => _selectedId = null),
        onDragEnd: (_) => setState(() {
          _dragHoverRow = null;
          _dragHoverCol = null;
          _draggedItem = null;
        }),
        feedback: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(6),
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.85,
            child: SizedBox(
              width: elem.gridWidth * cellW,
              height: elem.gridHeight * cellH,
              child: _EditorElementCell(element: elem),
            ),
          ),
        ),
        childWhenDragging: IgnorePointer(
          child: Opacity(
            opacity: 0.3,
            child: _EditorElementCell(element: elem),
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() {
            _selectedId = elem.id;
            _selectedIsTable = false;
          }),
          onDoubleTap: () => _showEditElementDialog(context, elem),
          child: _EditorElementCell(element: elem),
        ),
      ),
    );
  }

  List<Widget> _buildSelectionOverlay(
    double cellW,
    double cellH,
    List<TableModel> placedTables,
    List<MapElementModel> placedElements,
    List<TableModel> allTables,
    List<MapElementModel> allElements,
  ) {
    int row, col, w, h;
    if (_selectedIsTable) {
      final t = placedTables.where((t) => t.id == _selectedId).firstOrNull;
      if (t == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedId != null) setState(() => _selectedId = null);
        });
        return [];
      }
      row = t.gridRow; col = t.gridCol; w = t.gridWidth; h = t.gridHeight;
    } else {
      final e = placedElements.where((e) => e.id == _selectedId).firstOrNull;
      if (e == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedId != null) setState(() => _selectedId = null);
        });
        return [];
      }
      row = e.gridRow; col = e.gridCol; w = e.gridWidth; h = e.gridHeight;
    }

    final primary = Theme.of(context).colorScheme.primary;
    const handleSize = 8.0;
    const hitSize = 24.0;

    final left = col * cellW;
    final top = row * cellH;
    final width = w * cellW;
    final height = h * cellH;

    final widgets = <Widget>[
      // Selection border (hidden during resize — preview replaces it)
      if (!_isResizing)
        Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: primary, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
    ];

    // Corner handle positions
    final handles = {
      _HandlePos.tl: Offset(left, top),
      _HandlePos.tr: Offset(left + width, top),
      _HandlePos.br: Offset(left + width, top + height),
      _HandlePos.bl: Offset(left, top + height),
    };

    for (final entry in handles.entries) {
      final pos = entry.key;
      final offset = entry.value;
      widgets.add(
        Positioned(
          left: offset.dx - hitSize / 2,
          top: offset.dy - hitSize / 2,
          width: hitSize,
          height: hitSize,
          child: MouseRegion(
            cursor: SystemMouseCursors.precise,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) => _onResizeStart(pos, row, col, w, h, details, cellW, cellH),
              onPanUpdate: (details) => _onResizeUpdate(details, cellW, cellH, placedTables),
              onPanEnd: (details) => _onResizeEnd(allTables, allElements),
              onPanCancel: () => _onResizeCancel(),
              child: Center(
                child: Container(
                  width: handleSize,
                  height: handleSize,
                  decoration: BoxDecoration(
                    color: primary,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  void _onResizeStart(
    _HandlePos handle, int row, int col, int w, int h,
    DragStartDetails details, double cellW, double cellH,
  ) {
    setState(() {
      _isResizing = true;
      _activeHandle = handle;
      _dragStartGlobal = details.globalPosition;
      _origRow = row;
      _origCol = col;
      _origW = w;
      _origH = h;
      _previewRow = row;
      _previewCol = col;
      _previewW = w;
      _previewH = h;
    });
  }

  void _onResizeUpdate(DragUpdateDetails details, double cellW, double cellH, List<TableModel> placedTables) {
    if (!_isResizing || _dragStartGlobal == null || _activeHandle == null) return;

    final totalDx = details.globalPosition.dx - _dragStartGlobal!.dx;
    final totalDy = details.globalPosition.dy - _dragStartGlobal!.dy;
    final dCols = (totalDx / cellW).round();
    final dRows = (totalDy / cellH).round();

    int newRow = _origRow, newCol = _origCol, newW = _origW, newH = _origH;

    switch (_activeHandle!) {
      case _HandlePos.br:
        newW = max(1, _origW + dCols);
        newH = max(1, _origH + dRows);
      case _HandlePos.tl:
        newW = max(1, _origW - dCols);
        newH = max(1, _origH - dRows);
        newCol = _origCol + _origW - newW;
        newRow = _origRow + _origH - newH;
      case _HandlePos.tr:
        newW = max(1, _origW + dCols);
        newH = max(1, _origH - dRows);
        newRow = _origRow + _origH - newH;
      case _HandlePos.bl:
        newW = max(1, _origW - dCols);
        newH = max(1, _origH + dRows);
        newCol = _origCol + _origW - newW;
    }

    // Clamp to grid bounds
    newCol = newCol.clamp(0, _gridCols - 1);
    newRow = newRow.clamp(0, _gridRows - 1);
    newW = newW.clamp(1, _gridCols - newCol);
    newH = newH.clamp(1, _gridRows - newRow);

    setState(() {
      _previewRow = newRow;
      _previewCol = newCol;
      _previewW = newW;
      _previewH = newH;
    });
  }

  void _onResizeEnd(List<TableModel> allTables, List<MapElementModel> allElements) {
    if (!_isResizing) return;

    final newRow = _previewRow;
    final newCol = _previewCol;
    final newW = _previewW;
    final newH = _previewH;

    setState(() {
      _isResizing = false;
      _activeHandle = null;
      _dragStartGlobal = null;
    });

    if (_selectedIsTable) {
      final table = allTables.where((t) => t.id == _selectedId).firstOrNull;
      if (table != null) {
        ref.read(tableRepositoryProvider).update(table.copyWith(
          gridRow: newRow,
          gridCol: newCol,
          gridWidth: newW,
          gridHeight: newH,
        ));
      }
    } else {
      final elem = allElements.where((e) => e.id == _selectedId).firstOrNull;
      if (elem != null) {
        ref.read(mapElementRepositoryProvider).update(elem.copyWith(
          gridRow: newRow,
          gridCol: newCol,
          gridWidth: newW,
          gridHeight: newH,
        ));
      }
    }
  }

  void _onResizeCancel() {
    setState(() {
      _isResizing = false;
      _activeHandle = null;
      _dragStartGlobal = null;
    });
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
                  onSelected: (_) => setState(() {
                    _selectedSectionId = sections[i].id;
                    _selectedId = null;
                    _isResizing = false;
                    _activeHandle = null;
                    _dragStartGlobal = null;
                  }),
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

  Future<void> _moveElement(MapElementModel elem, int row, int col) async {
    await ref.read(mapElementRepositoryProvider).update(
      elem.copyWith(gridRow: row, gridCol: col),
    );
  }

  Future<void> _showPlaceDialog(
    BuildContext context,
    SectionModel section,
    List<TableModel> allTables,
    List<TableModel> placedTables,
    List<MapElementModel> placedElements,
    int row,
    int col,
  ) async {
    // Check if this cell is occupied by an existing table
    final occupyingTable = placedTables.where((t) =>
        row >= t.gridRow &&
        row < t.gridRow + t.gridHeight &&
        col >= t.gridCol &&
        col < t.gridCol + t.gridWidth).firstOrNull;
    if (occupyingTable != null) {
      setState(() {
        _selectedId = occupyingTable.id;
        _selectedIsTable = true;
      });
      return;
    }

    // Check if this cell is occupied by an element
    final occupyingElement = placedElements.where((e) =>
        row >= e.gridRow &&
        row < e.gridRow + e.gridHeight &&
        col >= e.gridCol &&
        col < e.gridCol + e.gridWidth).firstOrNull;
    if (occupyingElement != null) {
      setState(() {
        _selectedId = occupyingElement.id;
        _selectedIsTable = false;
      });
      return;
    }

    // Empty space: if something selected, just deselect
    if (_selectedId != null) {
      setState(() => _selectedId = null);
      return;
    }

    final l = context.l10n;
    final unplacedTables = allTables.where((t) =>
        t.sectionId == section.id &&
        (t.gridRow < 0 ||
         t.gridCol < 0 ||
         t.gridRow >= _gridRows ||
         t.gridCol >= _gridCols ||
         !placedTables.contains(t))).toList();

    bool isElementMode = false;
    String? selectedTableId;
    int width = 3;
    int height = 3;
    var shape = TableShape.rectangle;
    final tableCount = allTables.where((t) => t.sectionId == section.id).length;
    final defaultName = '${section.name} ${tableCount + 1}';
    final nameController = TextEditingController(text: defaultName);
    // Element fields
    final labelController = TextEditingController();
    String? elementColor;
    int elemWidth = 2;
    int elemHeight = 2;
    var elemShape = TableShape.rectangle;

    final result = await showDialog<_PlaceResult>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(isElementMode ? l.floorMapAddElement : l.floorMapAddTable),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Segment: Table / Element
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: FilterChip(
                            label: SizedBox(
                              width: double.infinity,
                              child: Text(l.floorMapSegmentTable, textAlign: TextAlign.center),
                            ),
                            selected: !isElementMode,
                            onSelected: (_) => setDialogState(() => isElementMode = false),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: FilterChip(
                            label: SizedBox(
                              width: double.infinity,
                              child: Text(l.floorMapSegmentElement, textAlign: TextAlign.center),
                            ),
                            selected: isElementMode,
                            onSelected: (_) => setDialogState(() => isElementMode = true),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!isElementMode) ...[
                    // TABLE mode
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
                    if (selectedTableId == null) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: l.fieldName),
                        autofocus: true,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SpinnerField(
                            label: l.floorMapWidth,
                            value: width,
                            min: 1,
                            max: 8,
                            onChanged: (v) => setDialogState(() => width = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SpinnerField(
                            label: l.floorMapHeight,
                            value: height,
                            min: 1,
                            max: 8,
                            onChanged: (v) => setDialogState(() => height = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final s in TableShape.values) ...[
                          if (s != TableShape.values.first) const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: FilterChip(
                                label: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    s == TableShape.rectangle ? l.floorMapShapeRectangle : l.floorMapShapeRound,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                selected: shape == s,
                                onSelected: (_) => setDialogState(() => shape = s),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    // ELEMENT mode
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(labelText: l.floorMapElementLabel),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    // Color palette
                    Text(l.floorMapElementColor, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // "None" option
                        GestureDetector(
                          onTap: () => setDialogState(() => elementColor = null),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: elementColor == null
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).dividerColor,
                                width: elementColor == null ? 3 : 1,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.block, size: 16),
                            ),
                          ),
                        ),
                        for (final hex in _elementColors)
                          GestureDetector(
                            onTap: () => setDialogState(() => elementColor = hex),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _parseColor(hex),
                                border: Border.all(
                                  color: elementColor == hex
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SpinnerField(
                            label: l.floorMapWidth,
                            value: elemWidth,
                            min: 1,
                            max: 8,
                            onChanged: (v) => setDialogState(() => elemWidth = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SpinnerField(
                            label: l.floorMapHeight,
                            value: elemHeight,
                            min: 1,
                            max: 8,
                            onChanged: (v) => setDialogState(() => elemHeight = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final s in TableShape.values) ...[
                          if (s != TableShape.values.first) const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: FilterChip(
                                label: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    s == TableShape.rectangle ? l.floorMapShapeRectangle : l.floorMapShapeRound,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                selected: elemShape == s,
                                onSelected: (_) => setDialogState(() => elemShape = s),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
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
                  isElement: isElementMode,
                  tableId: isElementMode ? null : selectedTableId,
                  name: !isElementMode && selectedTableId == null ? nameController.text.trim() : null,
                  width: isElementMode ? elemWidth : width,
                  height: isElementMode ? elemHeight : height,
                  shape: isElementMode ? elemShape : shape,
                  label: isElementMode ? labelController.text.trim() : null,
                  color: isElementMode ? elementColor : null,
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

    if (result.isElement) {
      // Create element
      final now = DateTime.now();
      final label = result.label?.isNotEmpty == true ? result.label : null;
      await ref.read(mapElementRepositoryProvider).create(MapElementModel(
        id: const Uuid().v7(),
        companyId: company.id,
        sectionId: section.id,
        gridRow: row,
        gridCol: col,
        gridWidth: result.width,
        gridHeight: result.height,
        label: label,
        color: result.color,
        shape: result.shape,
        createdAt: now,
        updatedAt: now,
      ));
    } else {
      // Table logic (unchanged)
      final repo = ref.read(tableRepositoryProvider);
      if (result.tableId != null) {
        final table = allTables.firstWhere((t) => t.id == result.tableId);
        await repo.update(table.copyWith(
          gridRow: row,
          gridCol: col,
          gridWidth: result.width,
          gridHeight: result.height,
          shape: result.shape,
        ));
      } else {
        final now = DateTime.now();
        final tableName = result.name?.isNotEmpty == true
            ? result.name!
            : '${section.name} ${allTables.where((t) => t.sectionId == section.id).length + 1}';
        await repo.create(TableModel(
          id: const Uuid().v7(),
          companyId: company.id,
          name: tableName,
          sectionId: section.id,
          gridRow: row,
          gridCol: col,
          gridWidth: result.width,
          gridHeight: result.height,
          shape: result.shape,
          createdAt: now,
          updatedAt: now,
        ));
      }
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
    var shape = table.shape;

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
                          max: 8,
                          onChanged: (v) => setDialogState(() => width = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpinnerField(
                          label: l.floorMapHeight,
                          value: height,
                          min: 1,
                          max: 8,
                          onChanged: (v) => setDialogState(() => height = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final s in TableShape.values) ...[
                        if (s != TableShape.values.first) const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: FilterChip(
                              label: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  s == TableShape.rectangle ? l.floorMapShapeRectangle : l.floorMapShapeRound,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              selected: shape == s,
                              onSelected: (_) => setDialogState(() => shape = s),
                            ),
                          ),
                        ),
                      ],
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
                  shape: shape,
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
      setState(() => _selectedId = null);
      await repo.update(table.copyWith(
        gridRow: -1,
        gridCol: -1,
      ));
    } else {
      await repo.update(table.copyWith(
        gridWidth: result.width,
        gridHeight: result.height,
        shape: result.shape,
      ));
    }
  }

  Future<void> _showEditElementDialog(BuildContext context, MapElementModel elem) async {
    final l = context.l10n;
    final labelController = TextEditingController(text: elem.label ?? '');
    String? elementColor = elem.color;
    int width = elem.gridWidth;
    int height = elem.gridHeight;
    var shape = elem.shape;

    final result = await showDialog<_EditElementResult>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(l.floorMapEditElement),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(labelText: l.floorMapElementLabel),
                  ),
                  const SizedBox(height: 12),
                  Text(l.floorMapElementColor, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GestureDetector(
                        onTap: () => setDialogState(() => elementColor = null),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: elementColor == null
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor,
                              width: elementColor == null ? 3 : 1,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.block, size: 16),
                          ),
                        ),
                      ),
                      for (final hex in _elementColors)
                        GestureDetector(
                          onTap: () => setDialogState(() => elementColor = hex),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _parseColor(hex),
                              border: Border.all(
                                color: elementColor == hex
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SpinnerField(
                          label: l.floorMapWidth,
                          value: width,
                          min: 1,
                          max: 8,
                          onChanged: (v) => setDialogState(() => width = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpinnerField(
                          label: l.floorMapHeight,
                          value: height,
                          min: 1,
                          max: 8,
                          onChanged: (v) => setDialogState(() => height = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final s in TableShape.values) ...[
                        if (s != TableShape.values.first) const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: FilterChip(
                              label: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  s == TableShape.rectangle ? l.floorMapShapeRectangle : l.floorMapShapeRound,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              selected: shape == s,
                              onSelected: (_) => setDialogState(() => shape = s),
                            ),
                          ),
                        ),
                      ],
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
                onPressed: () => Navigator.pop(ctx, const _EditElementResult(remove: true)),
                child: Text(l.floorMapRemoveElement),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, _EditElementResult(
                  label: labelController.text.trim(),
                  color: elementColor,
                  width: width,
                  height: height,
                  shape: shape,
                )),
                child: Text(l.actionSave),
              ),
            ],
          );
        },
      ),
    );

    if (result == null) return;

    final repo = ref.read(mapElementRepositoryProvider);

    if (result.remove) {
      setState(() => _selectedId = null);
      await repo.delete(elem.id);
    } else {
      final label = result.label?.isNotEmpty == true ? result.label : null;
      await repo.update(elem.copyWith(
        label: label,
        color: result.color,
        gridWidth: result.width,
        gridHeight: result.height,
        shape: result.shape,
      ));
    }
  }
}

Color _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return Colors.blueGrey;
  try {
    final colorValue = int.parse(hex.replaceFirst('#', ''), radix: 16);
    return Color(colorValue | 0xFF000000);
  } catch (_) {
    return Colors.blueGrey;
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
  });
  final TableModel table;
  final SectionModel? section;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(section?.color);
    final isRound = table.shape == TableShape.round;
    final radius = isRound ? BorderRadius.circular(999) : BorderRadius.circular(6);

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
        color: color.withValues(alpha: 0.3),
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
            borderRadius: radius,
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
    );
  }
}

class _EditorElementCell extends StatelessWidget {
  const _EditorElementCell({
    required this.element,
  });
  final MapElementModel element;

  @override
  Widget build(BuildContext context) {
    final color = element.color != null ? _parseColor(element.color) : null;
    final isRound = element.shape == TableShape.round;
    final radius = isRound ? BorderRadius.circular(999) : BorderRadius.circular(6);

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
        color: color?.withValues(alpha: 0.3) ?? Colors.transparent,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            border: color != null
                ? Border.all(color: color.withValues(alpha: 0.6), width: 2)
                : Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5), width: 1),
            borderRadius: radius,
          ),
          child: element.label != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      element.label!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: color != null
                            ? color.withValues(alpha: 0.9)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                )
              : const SizedBox.expand(),
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
    required this.isElement,
    this.tableId,
    this.name,
    required this.width,
    required this.height,
    required this.shape,
    this.label,
    this.color,
  });
  final bool isElement;
  final String? tableId;
  final String? name;
  final int width;
  final int height;
  final TableShape shape;
  final String? label;
  final String? color;
}

class _EditResult {
  const _EditResult({
    this.width = 1,
    this.height = 1,
    this.shape = TableShape.rectangle,
    this.remove = false,
  });
  final int width;
  final int height;
  final TableShape shape;
  final bool remove;
}

class _EditElementResult {
  const _EditElementResult({
    this.label,
    this.color,
    this.width = 2,
    this.height = 2,
    this.shape = TableShape.rectangle,
    this.remove = false,
  });
  final String? label;
  final String? color;
  final int width;
  final int height;
  final TableShape shape;
  final bool remove;
}
