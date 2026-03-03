import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/data/models/product_recipe_model.dart';
import '../../../core/data/repositories/product_recipe_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

const _uuid = Uuid();

/// Handles recipe-domain AI tool calls.
class AiRecipeToolHandler {
  AiRecipeToolHandler({required ProductRecipeRepository recipeRepo})
      : _recipeRepo = recipeRepo;

  final ProductRecipeRepository _recipeRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'list_recipes' => _listRecipes(companyId),
        'get_recipe' => _getRecipe(args, companyId),
        'create_recipe' => _createRecipe(args, companyId),
        'update_recipe' => _updateRecipe(args, companyId),
        'delete_recipe' => _deleteRecipe(args, companyId),
        _ => AiCommandError('Unknown recipe tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Recipe tool handler error',
          tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  Future<AiCommandResult> _listRecipes(String companyId) async {
    final recipes = await _recipeRepo.watchAll(companyId).first;
    final json = recipes
        .take(1000)
        .map((r) => {
              'id': r.id,
              'parent_product_id': r.parentProductId,
              'component_product_id': r.componentProductId,
              'quantity_required': r.quantityRequired,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getRecipe(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final recipe = await _recipeRepo.getById(id, companyId: companyId);
    if (recipe == null) return const AiCommandError('Recipe not found');
    return AiCommandSuccess(jsonEncode({
      'id': recipe.id,
      'parent_product_id': recipe.parentProductId,
      'component_product_id': recipe.componentProductId,
      'quantity_required': recipe.quantityRequired,
    }));
  }

  Future<AiCommandResult> _createRecipe(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final quantityRequired = (args['quantity_required'] as num).toDouble();
    if (quantityRequired <= 0) {
      return const AiCommandError('quantity_required must be positive');
    }

    final now = DateTime.now();
    final model = ProductRecipeModel(
      id: _uuid.v7(),
      companyId: companyId,
      parentProductId: args['parent_product_id'] as String,
      componentProductId: args['component_product_id'] as String,
      quantityRequired: quantityRequired,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _recipeRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Recipe created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateRecipe(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing = await _recipeRepo.getById(id, companyId: companyId);
    if (existing == null) return const AiCommandError('Recipe not found');

    final newQty = args['quantity_required'] != null
        ? (args['quantity_required'] as num).toDouble()
        : null;
    if (newQty != null && newQty <= 0) {
      return const AiCommandError('quantity_required must be positive');
    }

    final updated = existing.copyWith(
      parentProductId:
          args['parent_product_id'] as String? ?? existing.parentProductId,
      componentProductId: args['component_product_id'] as String? ??
          existing.componentProductId,
      quantityRequired: newQty ?? existing.quantityRequired,
      updatedAt: DateTime.now(),
    );
    final result = await _recipeRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Recipe updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteRecipe(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing = await _recipeRepo.getById(id, companyId: companyId);
    if (existing == null) return const AiCommandError('Recipe not found');
    final result = await _recipeRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Recipe deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }
}
