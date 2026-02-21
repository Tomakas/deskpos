import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../printing/printing_service.dart';
import 'repository_providers.dart';

final printingServiceProvider = Provider<PrintingService>((ref) => PrintingService(
      billRepo: ref.watch(billRepositoryProvider),
      orderRepo: ref.watch(orderRepositoryProvider),
      paymentRepo: ref.watch(paymentRepositoryProvider),
      paymentMethodRepo: ref.watch(paymentMethodRepositoryProvider),
      companyRepo: ref.watch(companyRepositoryProvider),
      tableRepo: ref.watch(tableRepositoryProvider),
      userRepo: ref.watch(userRepositoryProvider),
      orderItemModifierRepo: ref.watch(orderItemModifierRepositoryProvider),
    ));
