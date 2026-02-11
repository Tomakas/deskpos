import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/table_shape.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/map_element_model.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

const _gridCols = 32;
const _gridRows = 20;

class FloorMapView extends ConsumerWidget {
  const FloorMapView({
    super.key,
    this.sectionId,
    required this.onBillTap,
    required this.onTableTap,
  });

  final String? sectionId;
  final ValueChanged<BillModel> onBillTap;
  final ValueChanged<TableModel> onTableTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<TableModel>>(
      stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
      builder: (context, tableSnap) {
        final allTables = tableSnap.data ?? [];
        return StreamBuilder<List<SectionModel>>(
          stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
          builder: (context, sectionSnap) {
            final sections = sectionSnap.data ?? [];
            final sectionMap = {for (final s in sections) s.id: s};

            final effectiveSectionId = (sectionId != null && sections.any((s) => s.id == sectionId))
                ? sectionId
                : sections.firstOrNull?.id;

            if (effectiveSectionId == null) {
              return Center(
                child: Text(
                  l.floorMapNoTables,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return StreamBuilder<List<BillModel>>(
              stream: ref.watch(billRepositoryProvider).watchByCompany(
                company.id,
                status: BillStatus.opened,
              ),
              builder: (context, billSnap) {
                final openBills = billSnap.data ?? [];

                return StreamBuilder<List<MapElementModel>>(
                  stream: ref.watch(mapElementRepositoryProvider).watchAll(company.id),
                  builder: (context, elementSnap) {
                    final allElements = elementSnap.data ?? [];

                    final placedTables = allTables.where((t) =>
                        t.sectionId == effectiveSectionId &&
                        t.gridRow >= 0 &&
                        t.gridCol >= 0 &&
                        t.gridRow < _gridRows &&
                        t.gridCol < _gridCols).toList();

                    final placedElements = allElements.where((e) =>
                        e.sectionId == effectiveSectionId &&
                        e.gridRow >= 0 &&
                        e.gridCol >= 0 &&
                        e.gridRow < _gridRows &&
                        e.gridCol < _gridCols).toList();

                    final coloredElements = placedElements.where((e) => e.color != null).toList();
                    final textElements = placedElements.where((e) => e.color == null && e.label != null).toList();

                    // Group bills by table
                    final billsByTable = <String?, List<BillModel>>{};
                    for (final bill in openBills) {
                      billsByTable.putIfAbsent(bill.tableId, () => []).add(bill);
                    }

                    // Bills on this section's tables
                    final sectionBills = <BillModel>[];
                    for (final table in placedTables) {
                      sectionBills.addAll(billsByTable[table.id] ?? []);
                    }

                    if (placedTables.isEmpty && placedElements.isEmpty) {
                      return Center(
                        child: Text(
                          l.floorMapNoTables,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellW = constraints.maxWidth / _gridCols;
                          final cellH = constraints.maxHeight / _gridRows;
                          final billDiameter = min(cellW, cellH) * 2.5;

                          return DragTarget<BillModel>(
                            onWillAcceptWithDetails: (_) => true,
                            onAcceptWithDetails: (details) {
                              final box = context.findRenderObject() as RenderBox;
                              final local = box.globalToLocal(details.offset);
                              final centerX = local.dx + billDiameter / 2;
                              final centerY = local.dy + billDiameter / 2;
                              final gridX = (centerX / cellW * 100).round();
                              final gridY = (centerY / cellH * 100).round();

                              final radius = billDiameter / 2;
                              String? newTableId;
                              for (final table in placedTables) {
                                final tl = table.gridCol * cellW;
                                final tt = table.gridRow * cellH;
                                final tr = (table.gridCol + table.gridWidth) * cellW;
                                final tb = (table.gridRow + table.gridHeight) * cellH;
                                final cx = centerX.clamp(tl, tr);
                                final cy = centerY.clamp(tt, tb);
                                final dx = centerX - cx;
                                final dy = centerY - cy;
                                if (dx * dx + dy * dy <= radius * radius) {
                                  newTableId = table.id;
                                  break;
                                }
                              }

                              final oldTableId = details.data.tableId;
                              final tableChanged = newTableId != null && newTableId != oldTableId;

                              ref.read(billRepositoryProvider).updateMapPosition(
                                details.data.id,
                                gridX,
                                gridY,
                                tableId: tableChanged ? newTableId : null,
                                updateTable: tableChanged,
                              );
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Grid background
                                  for (int r = 0; r < _gridRows; r++)
                                    for (int c = 0; c < _gridCols; c++)
                                      Positioned(
                                        left: c * cellW,
                                        top: r * cellH,
                                        width: cellW,
                                        height: cellH,
                                        child: Container(
                                          margin: const EdgeInsets.all(0.5),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                  // Colored elements (under tables)
                                  for (final elem in coloredElements)
                                    Positioned(
                                      left: elem.gridCol * cellW,
                                      top: elem.gridRow * cellH,
                                      width: elem.gridWidth * cellW,
                                      height: elem.gridHeight * cellH,
                                      child: _MapElementCell(element: elem),
                                    ),
                                  // Tables
                                  for (final table in placedTables)
                                    Positioned(
                                      left: table.gridCol * cellW,
                                      top: table.gridRow * cellH,
                                      width: table.gridWidth * cellW,
                                      height: table.gridHeight * cellH,
                                      child: _MapTableCell(
                                        table: table,
                                        section: sectionMap[table.sectionId],
                                        onTap: () => onTableTap(table),
                                      ),
                                    ),
                                  // Text-only elements (over tables)
                                  for (final elem in textElements)
                                    Positioned(
                                      left: elem.gridCol * cellW,
                                      top: elem.gridRow * cellH,
                                      width: elem.gridWidth * cellW,
                                      height: elem.gridHeight * cellH,
                                      child: _MapElementCell(element: elem),
                                    ),
                                  // Bills as draggable circles
                                  for (final bill in sectionBills)
                                    _buildBillCircle(
                                      bill,
                                      placedTables,
                                      billsByTable,
                                      cellW,
                                      cellH,
                                      billDiameter,
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBillCircle(
    BillModel bill,
    List<TableModel> placedTables,
    Map<String?, List<BillModel>> billsByTable,
    double cellW,
    double cellH,
    double diameter,
  ) {
    double centerX;
    double centerY;

    if (bill.mapPosX != null && bill.mapPosY != null) {
      centerX = bill.mapPosX! / 100.0 * cellW;
      centerY = bill.mapPosY! / 100.0 * cellH;
    } else {
      final table = placedTables.where((t) => t.id == bill.tableId).firstOrNull;
      if (table == null) return const SizedBox.shrink();

      final tableBills = billsByTable[table.id] ?? [];
      final idx = tableBills.indexOf(bill);

      centerX = (table.gridCol + table.gridWidth / 2) * cellW;
      centerY = (table.gridRow + table.gridHeight / 2) * cellH;

      if (tableBills.length > 1) {
        final spacing = min(table.gridWidth * cellW / tableBills.length, diameter);
        final totalWidth = spacing * (tableBills.length - 1);
        centerX = (table.gridCol + table.gridWidth / 2) * cellW
            - totalWidth / 2 + idx * spacing;
      }
    }

    final left = centerX - diameter / 2;
    final top = centerY - diameter / 2;

    return Positioned(
      left: left,
      top: top,
      width: diameter,
      height: diameter,
      child: LongPressDraggable<BillModel>(
        data: bill,
        delay: const Duration(milliseconds: 200),
        feedback: Material(
          elevation: 8,
          shape: const CircleBorder(),
          color: Colors.transparent,
          child: _BillCircle(
            bill: bill,
            diameter: diameter,
            opacity: 0.85,
          ),
        ),
        childWhenDragging: IgnorePointer(
          child: Opacity(
            opacity: 0.3,
            child: _BillCircle(bill: bill, diameter: diameter),
          ),
        ),
        child: GestureDetector(
          onTap: () => onBillTap(bill),
          child: _BillCircle(bill: bill, diameter: diameter),
        ),
      ),
    );
  }
}

class _BillCircle extends StatelessWidget {
  const _BillCircle({
    required this.bill,
    required this.diameter,
    this.opacity = 1.0,
  });
  final BillModel bill;
  final double diameter;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.shade600,
          border: Border.all(color: Colors.blue.shade800, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.all(diameter * 0.15),
              child: Text(
                '${bill.totalGross ~/ 100},-',
                style: TextStyle(
                  fontSize: diameter * 0.3,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

class _MapTableCell extends StatelessWidget {
  const _MapTableCell({
    required this.table,
    required this.section,
    required this.onTap,
  });
  final TableModel table;
  final SectionModel? section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(section?.color);
    final isRound = table.shape == TableShape.round;
    final radius = isRound ? BorderRadius.circular(999) : BorderRadius.circular(8);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color.withValues(alpha: 0.25),
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapElementCell extends StatelessWidget {
  const _MapElementCell({required this.element});
  final MapElementModel element;

  @override
  Widget build(BuildContext context) {
    final color = element.color != null ? _parseColor(element.color) : null;
    final isRound = element.shape == TableShape.round;
    final radius = isRound ? BorderRadius.circular(999) : BorderRadius.circular(6);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.3),
          border: color != null
              ? Border.all(color: color.withValues(alpha: 0.6), width: 2)
              : null,
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
                      fontSize: 12,
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
    );
  }
}
