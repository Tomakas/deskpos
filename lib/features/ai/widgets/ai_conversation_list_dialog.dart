import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/models/ai_conversation_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../providers/ai_providers.dart';

class AiConversationListDialog extends ConsumerStatefulWidget {
  const AiConversationListDialog({super.key});

  @override
  ConsumerState<AiConversationListDialog> createState() =>
      _AiConversationListDialogState();
}

class _AiConversationListDialogState
    extends ConsumerState<AiConversationListDialog> {
  List<AiConversationModel>? _conversations;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final conversations =
          await ref.read(aiDirectServiceProvider).fetchConversations(
                companyId: company.id,
                userId: user.id,
              );
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final dateFormat = DateFormat.yMd().add_Hm();

    return PosDialogShell(
      title: l.aiConversationHistory,
      maxWidth: 420,
      showCloseButton: true,
      scrollable: true,
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_conversations == null || _conversations!.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text(l.aiNoConversations)),
          )
        else
          ...List.generate(_conversations!.length, (i) {
            final conv = _conversations![i];
            return ListTile(
              title: Text(
                conv.title ?? conv.id.substring(0, 8),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(dateFormat.format(conv.createdAt)),
              onTap: () => Navigator.of(context).pop(conv),
            );
          }),
      ],
    );
  }
}
