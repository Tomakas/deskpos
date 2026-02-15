import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';

enum BillStatus {
  opened,
  paid,
  cancelled,
  refunded,
}

extension BillStatusColor on BillStatus {
  Color color(BuildContext context) {
    final c = context.appColors;
    return switch (this) {
      BillStatus.opened => c.billOpened,
      BillStatus.paid => c.billPaid,
      BillStatus.cancelled => c.billCancelled,
      BillStatus.refunded => c.billRefunded,
    };
  }
}
