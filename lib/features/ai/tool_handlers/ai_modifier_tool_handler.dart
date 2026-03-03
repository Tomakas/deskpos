import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/data/models/item_modifier_group_model.dart';
import '../../../core/data/models/modifier_group_item_model.dart';
import '../../../core/data/models/modifier_group_model.dart';
import '../../../core/data/repositories/item_modifier_group_repository.dart';
import '../../../core/data/repositories/modifier_group_item_repository.dart';
import '../../../core/data/repositories/modifier_group_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

const _uuid = Uuid();

/// Handles modifier-domain AI tool calls (groups, group items, item assignments).
class AiModifierToolHandler {
  AiModifierToolHandler({
    required ModifierGroupRepository modifierGroupRepo,
    required ModifierGroupItemRepository modifierGroupItemRepo,
    required ItemModifierGroupRepository itemModifierGroupRepo,
  })  : _modifierGroupRepo = modifierGroupRepo,
        _modifierGroupItemRepo = modifierGroupItemRepo,
        _itemModifierGroupRepo = itemModifierGroupRepo;

  final ModifierGroupRepository _modifierGroupRepo;
  final ModifierGroupItemRepository _modifierGroupItemRepo;
  final ItemModifierGroupRepository _itemModifierGroupRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        // Modifier groups
        'list_modifier_groups' => _listModifierGroups(companyId),
        'get_modifier_group' => _getModifierGroup(args, companyId),
        'create_modifier_group' => _createModifierGroup(args, companyId),
        'update_modifier_group' => _updateModifierGroup(args, companyId),
        'delete_modifier_group' => _deleteModifierGroup(args, companyId),
        // Modifier group items
        'list_modifier_group_items' =>
          _listModifierGroupItems(args, companyId),
        'add_modifier_group_item' => _addModifierGroupItem(args, companyId),
        'remove_modifier_group_item' =>
          _removeModifierGroupItem(args, companyId),
        // Item modifier group assignments
        'list_item_modifier_groups' =>
          _listItemModifierGroups(args, companyId),
        'assign_modifier_group_to_item' =>
          _assignModifierGroupToItem(args, companyId),
        'unassign_modifier_group_from_item' =>
          _unassignModifierGroupFromItem(args, companyId),
        _ => AiCommandError('Unknown modifier tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Modifier tool handler error',
          tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Modifier Groups
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listModifierGroups(String companyId) async {
    final groups = await _modifierGroupRepo.watchAll(companyId).first;
    final json = groups
        .take(1000)
        .map((g) => {
              'id': g.id,
              'name': g.name,
              'min_selections': g.minSelections,
              'max_selections': g.maxSelections,
              'sort_order': g.sortOrder,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getModifierGroup(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final group =
        await _modifierGroupRepo.getById(id, companyId: companyId);
    if (group == null) {
      return const AiCommandError('Modifier group not found');
    }
    return AiCommandSuccess(jsonEncode({
      'id': group.id,
      'name': group.name,
      'min_selections': group.minSelections,
      'max_selections': group.maxSelections,
      'sort_order': group.sortOrder,
    }));
  }

  Future<AiCommandResult> _createModifierGroup(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final minSel = (args['min_selections'] as num?)?.toInt() ?? 0;
    final maxSel = (args['max_selections'] as num?)?.toInt();
    if (minSel < 0) {
      return const AiCommandError('min_selections must be >= 0');
    }
    if (maxSel != null && maxSel < minSel) {
      return const AiCommandError('max_selections must be >= min_selections');
    }

    final now = DateTime.now();
    final model = ModifierGroupModel(
      id: _uuid.v7(),
      companyId: companyId,
      name: args['name'] as String,
      minSelections: minSel,
      maxSelections: maxSel,
      sortOrder: (args['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _modifierGroupRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Modifier group "${value.name}" created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateModifierGroup(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing =
        await _modifierGroupRepo.getById(id, companyId: companyId);
    if (existing == null) {
      return const AiCommandError('Modifier group not found');
    }

    final minSel =
        (args['min_selections'] as num?)?.toInt() ?? existing.minSelections;
    final maxSel = args.containsKey('max_selections')
        ? (args['max_selections'] as num?)?.toInt()
        : existing.maxSelections;
    if (minSel < 0) {
      return const AiCommandError('min_selections must be >= 0');
    }
    if (maxSel != null && maxSel < minSel) {
      return const AiCommandError('max_selections must be >= min_selections');
    }

    final updated = existing.copyWith(
      name: args['name'] as String? ?? existing.name,
      minSelections: minSel,
      maxSelections: maxSel,
      sortOrder: (args['sort_order'] as num?)?.toInt() ?? existing.sortOrder,
      updatedAt: DateTime.now(),
    );
    final result = await _modifierGroupRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Modifier group "${value.name}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteModifierGroup(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing =
        await _modifierGroupRepo.getById(id, companyId: companyId);
    if (existing == null) {
      return const AiCommandError('Modifier group not found');
    }
    final result = await _modifierGroupRepo.delete(id);
    return switch (result) {
      Success() =>
        AiCommandSuccess('Modifier group deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  // ---------------------------------------------------------------------------
  // Modifier Group Items
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listModifierGroupItems(
      Map<String, dynamic> args, String companyId) async {
    final groupId = args['modifier_group_id'] as String;
    final allItems = await _modifierGroupItemRepo.getByGroup(groupId);
    final items =
        allItems.where((i) => i.companyId == companyId).toList();
    final json = items
        .take(1000)
        .map((i) => {
              'id': i.id,
              'modifier_group_id': i.modifierGroupId,
              'item_id': i.itemId,
              'sort_order': i.sortOrder,
              'is_default': i.isDefault,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _addModifierGroupItem(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = ModifierGroupItemModel(
      id: _uuid.v7(),
      companyId: companyId,
      modifierGroupId: args['modifier_group_id'] as String,
      itemId: args['item_id'] as String,
      sortOrder: (args['sort_order'] as num?)?.toInt() ?? 0,
      isDefault: args['is_default'] as bool? ?? false,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _modifierGroupItemRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Item added to modifier group',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _removeModifierGroupItem(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing =
        await _modifierGroupItemRepo.getById(id, companyId: companyId);
    if (existing == null) {
      return const AiCommandError('Modifier group item not found');
    }
    final result = await _modifierGroupItemRepo.delete(id);
    return switch (result) {
      Success() =>
        AiCommandSuccess('Item removed from modifier group', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  // ---------------------------------------------------------------------------
  // Item ↔ Modifier Group Assignments
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listItemModifierGroups(
      Map<String, dynamic> args, String companyId) async {
    final itemId = args['item_id'] as String;
    final allAssignments = await _itemModifierGroupRepo.getByItem(itemId);
    final assignments =
        allAssignments.where((a) => a.companyId == companyId).toList();
    final json = assignments
        .take(1000)
        .map((a) => {
              'id': a.id,
              'item_id': a.itemId,
              'modifier_group_id': a.modifierGroupId,
              'sort_order': a.sortOrder,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _assignModifierGroupToItem(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = ItemModifierGroupModel(
      id: _uuid.v7(),
      companyId: companyId,
      itemId: args['item_id'] as String,
      modifierGroupId: args['modifier_group_id'] as String,
      sortOrder: (args['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _itemModifierGroupRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Modifier group assigned to item',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _unassignModifierGroupFromItem(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing =
        await _itemModifierGroupRepo.getById(id, companyId: companyId);
    if (existing == null) {
      return const AiCommandError('Item modifier group assignment not found');
    }
    final result = await _itemModifierGroupRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess(
          'Modifier group unassigned from item',
          entityId: id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }
}
