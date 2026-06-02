import 'package:intl/intl.dart';

import 'money.dart';

/// Bir tutarı (kuruş) yerel biçimde, tam lira ve ` ₺` ekiyle döndürür.
///
/// - TR (varsayılan): `1.000 ₺` (binlik ayracı nokta)
/// - EN: `1,000 ₺` (binlik ayracı virgül)
///
/// Kuruş artığı gösterilmez; tutar tam liraya yuvarlanır (artık atılır).
String formatCurrency(int kurus, {String locale = 'tr'}) {
  final lira = kurusToLira(kurus);
  final formatter = NumberFormat.decimalPattern(locale);
  return '${formatter.format(lira)} ₺';
}
