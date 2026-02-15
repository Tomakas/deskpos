import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';

enum PrepStatus {
  created,
  inPrep,
  ready,
  delivered,
  cancelled,
  voided,
}

extension PrepStatusColor on PrepStatus {
  Color color(BuildContext context) {
    final c = context.appColors;
    return switch (this) {
      PrepStatus.created => c.statusCreated,
      PrepStatus.inPrep => c.statusInPrep,
      PrepStatus.ready => c.statusReady,
      PrepStatus.delivered => c.statusDelivered,
      PrepStatus.cancelled => c.statusCancelled,
      PrepStatus.voided => c.statusVoided,
    };
  }
}
