import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';

enum PrepStatus {
  created,
  ready,
  delivered,
  voided,
}

extension PrepStatusColor on PrepStatus {
  Color color(BuildContext context) {
    final c = context.appColors;
    return switch (this) {
      PrepStatus.created => c.statusCreated,
      PrepStatus.ready => c.statusReady,
      PrepStatus.delivered => c.statusDelivered,
      PrepStatus.voided => c.statusVoided,
    };
  }
}
