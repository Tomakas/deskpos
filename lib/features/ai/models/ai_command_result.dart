/// Sealed class for AI tool execution outcomes.
sealed class AiCommandResult {
  const AiCommandResult();
}

/// Tool executed successfully.
class AiCommandSuccess extends AiCommandResult {
  const AiCommandSuccess(this.message, {this.entityId});

  final String message;
  final String? entityId;
}

/// Tool execution failed with an error.
class AiCommandError extends AiCommandResult {
  const AiCommandError(this.message);

  final String message;
}

/// User lacks permission for this tool.
class AiCommandPermissionDenied extends AiCommandResult {
  const AiCommandPermissionDenied(this.message);

  final String message;
}

/// Tool requires user confirmation before execution.
class AiCommandNeedsConfirmation extends AiCommandResult {
  const AiCommandNeedsConfirmation({
    required this.description,
    required this.isDestructive,
  });

  final String description;
  final bool isDestructive;
}
