import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

const _gridCols = 16;
const _gridRows = 10;

class FloorMapView extends ConsumerWidget {
  const FloorMapView({
    super.key,
    required this.sectionFilters,
    required this.onBillTap,
    required this.onTableTap,
  });

  final Set<String> sectionFilters;
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
            return StreamBuilder<List<BillModel>>(
              stream: ref.watch(billRepositoryProvider).watchByCompany(
                company.id,
                status: BillStatus.opened,
              ),
              builder: (context, billSnap) {
                final openBills = billSnap.data ?? [];

                // Filter tables by section
                var placedTables = allTables.where((t) =>
                    t.gridRow >= 0 &&
                    t.gridCol >= 0 &&
                    t.gridRow < _gridRows &&
                    t.gridCol < _gridCols).toList();

                if (sectionFilters.isNotEmpty) {
                  placedTables = placedTables
                      .where((t) => t.sectionId != null && sectionFilters.contains(t.sectionId))
                      .toList();
                }

                // Group bills by table
                final billsByTable = <String?, List<BillModel>>{};
                for (final bill in openBills) {
                  billsByTable.putIfAbsent(bill.tableId, () => []).add(bill);
                }

                // Bills without a table
                final billsWithoutTable = openBills
                    .where((b) => b.tableId == null)
                    .toList();

                // Auto-layout: compute positions for bills around tables
                final billPositions = <String, _BillPosition>{};
                for (final table in placedTables) {
                  final tableBills = billsByTable[table.id] ?? [];
                  for (int i = 0; i < tableBills.length; i++) {
                    final bill = tableBills[i];
                    if (bill.mapPosX != null && bill.mapPosY != null) {
                      billPositions[bill.id] = _BillPosition(
                        gridX: bill.mapPosX!.toDouble(),
                        gridY: bill.mapPosY!.toDouble(),
                        isPixelBased: true,
                      );
                    } else {
                      // Auto-layout: place below the table, then right, then further down
                      final pos = _autoLayoutPosition(table, i, placedTables);
                      billPositions[bill.id] = pos;
                    }
                  }
                }

                // Bills without table: arrange from top-left
                for (int i = 0; i < billsWithoutTable.length; i++) {
                  final bill = billsWithoutTable[i];
                  if (bill.mapPosX != null && bill.mapPosY != null) {
                    billPositions[bill.id] = _BillPosition(
                      gridX: bill.mapPosX!.toDouble(),
                      gridY: bill.mapPosY!.toDouble(),
                      isPixelBased: true,
                    );
                  } else {
                    // Stack in the top-left area
                    final col = i % 3;
                    final row = i ~/ 3;
                    billPositions[bill.id] = _BillPosition(
                      gridX: col.toDouble(),
                      gridY: row.toDouble(),
                    );
                  }
                }

                if (placedTables.isEmpty && billsWithoutTable.isEmpty) {
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

                      return Stack(
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
                                billCount: (billsByTable[table.id] ?? []).length,
                                onTap: () => onTableTap(table),
                              ),
                            ),
                          // Bills
                          for (final bill in openBills)
                            if (billPositions.containsKey(bill.id))
                              _buildBillWidget(
                                context,
                                ref,
                                bill,
                                billPositions[bill.id]!,
                                cellW,
                                cellH,
                              ),
                        ],
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
  }

  Widget _buildBillWidget(
    BuildContext context,
    WidgetRef ref,
    BillModel bill,
    _BillPosition pos,
    double cellW,
    double cellH,
  ) {
    final billW = cellW * 0.9;
    final billH = cellH * 0.6;

    double left;
    double top;

    if (pos.isPixelBased) {
      // mapPosX/Y stored as grid-relative * 100 for precision
      left = pos.gridX / 100.0 * cellW;
      top = pos.gridY / 100.0 * cellH;
    } else {
      left = pos.gridX * cellW + (cellW - billW) / 2;
      top = pos.gridY * cellH + (cellH - billH) / 2;
    }

    return Positioned(
      left: left,
      top: top,
      width: billW,
      height: billH,
      child: GestureDetector(
        onTap: () => onBillTap(bill),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.15),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.5), width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                bill.billNumber,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _BillPosition _autoLayoutPosition(
    TableModel table,
    int index,
    List<TableModel> allTables,
  ) {
    // Place bills below the table first, then to the right
    if (index == 0) {
      // Below the table
      return _BillPosition(
        gridX: table.gridCol.toDouble(),
        gridY: (table.gridRow + table.gridHeight).toDouble(),
      );
    } else if (index == 1) {
      // Right of the table
      return _BillPosition(
        gridX: (table.gridCol + table.gridWidth).toDouble(),
        gridY: table.gridRow.toDouble(),
      );
    } else {
      // Further below
      return _BillPosition(
        gridX: table.gridCol.toDouble() + ((index - 2) % table.gridWidth),
        gridY: (table.gridRow + table.gridHeight + 1).toDouble() + ((index - 2) ~/ table.gridWidth),
      );
    }
  }
}

class _BillPosition {
  const _BillPosition({
    required this.gridX,
    required this.gridY,
    this.isPixelBased = false,
  });
  final double gridX;
  final double gridY;
  final bool isPixelBased;
}

class _MapTableCell extends StatelessWidget {
  const _MapTableCell({
    required this.table,
    required this.section,
    required this.billCount,
    required this.onTap,
  });
  final TableModel table;
  final SectionModel? section;
  final int billCount;
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
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
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
                if (billCount > 0)
                  Positioned(
                    top: 2,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$billCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
