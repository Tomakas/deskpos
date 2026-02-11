import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

class DialogVoucherRedeem extends StatefulWidget {
  const DialogVoucherRedeem({super.key});

  @override
  State<DialogVoucherRedeem> createState() => _DialogVoucherRedeemState();
}

class _DialogVoucherRedeemState extends State<DialogVoucherRedeem> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return PosDialogShell(
      title: l.billDetailVoucher,
      maxWidth: 360,
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: l.voucherEnterCode,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(context, value.trim());
            }
          },
        ),
        const SizedBox(height: 16),
        PosDialogActions(
          spacing: 12,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: () {
                final code = _controller.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context, code);
                }
              },
              child: Text(l.voucherRedeem),
            ),
          ],
        ),
      ],
    );
  }
}
