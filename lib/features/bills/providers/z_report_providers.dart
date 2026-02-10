import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/repository_providers.dart';
import '../services/z_report_service.dart';

final zReportServiceProvider = Provider<ZReportService>((ref) => ZReportService(
      billRepo: ref.watch(billRepositoryProvider),
      paymentRepo: ref.watch(paymentRepositoryProvider),
      paymentMethodRepo: ref.watch(paymentMethodRepositoryProvider),
      cashMovementRepo: ref.watch(cashMovementRepositoryProvider),
      registerSessionRepo: ref.watch(registerSessionRepositoryProvider),
      shiftRepo: ref.watch(shiftRepositoryProvider),
      userRepo: ref.watch(userRepositoryProvider),
      orderRepo: ref.watch(orderRepositoryProvider),
    ));
