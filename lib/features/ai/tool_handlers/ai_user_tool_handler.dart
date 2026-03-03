import 'dart:convert';

import '../../../core/data/repositories/user_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

/// Handles user-domain AI tool calls.
///
/// IMPORTANT: Always strips pinHash and authUserId from responses.
class AiUserToolHandler {
  AiUserToolHandler({required UserRepository userRepo})
      : _userRepo = userRepo;

  final UserRepository _userRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'list_users' => _listUsers(companyId),
        'get_user' => _getUser(args),
        'update_user' => _updateUser(args),
        _ => AiCommandError('Unknown user tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('User tool handler error', tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  Future<AiCommandResult> _listUsers(String companyId) async {
    final users = await _userRepo.watchAll(companyId).first;
    final json = users
        .take(1000)
        .map((u) => {
              'id': u.id,
              'username': u.username,
              'full_name': u.fullName,
              'email': u.email,
              'phone': u.phone,
              'role_id': u.roleId,
              'is_active': u.isActive,
              // pinHash and authUserId intentionally omitted
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getUser(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final user = await _userRepo.getById(id);
    if (user == null) return const AiCommandError('User not found');
    return AiCommandSuccess(jsonEncode({
      'id': user.id,
      'username': user.username,
      'full_name': user.fullName,
      'email': user.email,
      'phone': user.phone,
      'role_id': user.roleId,
      'is_active': user.isActive,
      // pinHash and authUserId intentionally omitted
    }));
  }

  Future<AiCommandResult> _updateUser(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final existing = await _userRepo.getById(id);
    if (existing == null) return const AiCommandError('User not found');

    // Only allow safe field updates — never PIN or auth fields
    final updated = existing.copyWith(
      fullName: args['full_name'] as String? ?? existing.fullName,
      email: args.containsKey('email')
          ? args['email'] as String?
          : existing.email,
      phone: args.containsKey('phone')
          ? args['phone'] as String?
          : existing.phone,
      isActive: args['is_active'] as bool? ?? existing.isActive,
      updatedAt: DateTime.now(),
    );
    final result = await _userRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'User "${value.fullName}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }
}
