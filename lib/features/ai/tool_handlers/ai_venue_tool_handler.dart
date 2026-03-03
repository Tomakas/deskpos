import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/repositories/section_repository.dart';
import '../../../core/data/repositories/table_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

const _uuid = Uuid();

/// Handles venue-domain AI tool calls: sections and tables.
class AiVenueToolHandler {
  AiVenueToolHandler({
    required SectionRepository sectionRepo,
    required TableRepository tableRepo,
  })  : _sectionRepo = sectionRepo,
        _tableRepo = tableRepo;

  final SectionRepository _sectionRepo;
  final TableRepository _tableRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'list_sections' => _listSections(companyId),
        'create_section' => _createSection(args, companyId),
        'update_section' => _updateSection(args),
        'delete_section' => _deleteSection(args),
        'list_tables' => _listTables(args, companyId),
        'get_table' => _getTable(args),
        'create_table' => _createTable(args, companyId),
        'update_table' => _updateTable(args),
        'delete_table' => _deleteTable(args),
        _ => AiCommandError('Unknown venue tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Venue tool handler error', tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listSections(String companyId) async {
    final sections = await _sectionRepo.watchAll(companyId).first;
    final json = sections
        .take(1000)
        .map((s) => {
              'id': s.id,
              'name': s.name,
              'color': s.color,
              'is_active': s.isActive,
              'is_default': s.isDefault,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _createSection(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = SectionModel(
      id: _uuid.v7(),
      companyId: companyId,
      name: args['name'] as String,
      color: args['color'] as String?,
      isActive: args['is_active'] as bool? ?? true,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _sectionRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Section "${value.name}" created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateSection(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final existing = await _sectionRepo.getById(id);
    if (existing == null) return const AiCommandError('Section not found');

    final updated = existing.copyWith(
      name: args['name'] as String? ?? existing.name,
      color: args.containsKey('color')
          ? args['color'] as String?
          : existing.color,
      isActive: args['is_active'] as bool? ?? existing.isActive,
      updatedAt: DateTime.now(),
    );
    final result = await _sectionRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Section "${value.name}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteSection(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final result = await _sectionRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Section deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  // ---------------------------------------------------------------------------
  // Tables
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listTables(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final tables = await _tableRepo.watchAll(companyId).first;
    final sectionId = args['section_id'] as String?;
    final filtered = sectionId != null
        ? tables.where((t) => t.sectionId == sectionId).toList()
        : tables;

    final json = filtered
        .take(1000)
        .map((t) => {
              'id': t.id,
              'name': t.name,
              'section_id': t.sectionId,
              'capacity': t.capacity,
              'is_active': t.isActive,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getTable(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final table = await _tableRepo.getById(id);
    if (table == null) return const AiCommandError('Table not found');
    return AiCommandSuccess(jsonEncode({
      'id': table.id,
      'name': table.name,
      'section_id': table.sectionId,
      'capacity': table.capacity,
      'is_active': table.isActive,
    }));
  }

  Future<AiCommandResult> _createTable(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = TableModel(
      id: _uuid.v7(),
      companyId: companyId,
      name: args['name'] as String,
      sectionId: args['section_id'] as String?,
      capacity: (args['capacity'] as num?)?.toInt() ?? 0,
      isActive: args['is_active'] as bool? ?? true,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _tableRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Table "${value.name}" created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateTable(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final existing = await _tableRepo.getById(id);
    if (existing == null) return const AiCommandError('Table not found');

    final updated = existing.copyWith(
      name: args['name'] as String? ?? existing.name,
      sectionId: args.containsKey('section_id')
          ? args['section_id'] as String?
          : existing.sectionId,
      capacity: (args['capacity'] as num?)?.toInt() ?? existing.capacity,
      isActive: args['is_active'] as bool? ?? existing.isActive,
      updatedAt: DateTime.now(),
    );
    final result = await _tableRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Table "${value.name}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteTable(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final result = await _tableRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Table deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }
}
