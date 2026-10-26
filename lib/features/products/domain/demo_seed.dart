import '../../../core/utils/quantity.dart';
import '../../../core/utils/result.dart';
import 'product_draft.dart';
import 'product_repository.dart';

const List<String> _arabicNames = [
  'شاي',
  'سكر',
  'أرز',
  'مكرونة',
  'زيت',
  'دقيق',
  'عدس',
  'فول',
  'صابون',
  'منظف',
  'بسكويت',
  'عصير',
];

const List<String> _latinNames = ['Pepsi', 'Nescafe', 'Tide', 'Lipton'];

/// Debug-only demo data (002 decision B2): [count] products through the
/// normal create path, about one in four with opening stock and one in
/// ten low. Returns how many were saved.
Future<int> seedDemoProducts(ProductRepository repo, {int count = 2000}) async {
  var saved = 0;
  for (var i = 1; i <= count; i++) {
    final latin = i % 5 == 0;
    final base = latin
        ? _latinNames[i % _latinNames.length]
        : _arabicNames[i % _arabicNames.length];
    final unit = UnitType.values[i % UnitType.values.length];
    final stocked = i % 4 == 0;
    final draft = ProductDraft.create(
      name: '$base $i',
      unit: unit,
      priceText: '${5 + i % 200}.${(i * 7 % 100).toString().padLeft(2, '0')}',
      barcode: i % 3 == 0 ? '622${i.toString().padLeft(10, '0')}' : '',
      lowStockText: i % 10 == 0 ? '5' : '',
      openingQtyText: stocked ? '${i % 30 + 1}' : '',
      openingCostText: stocked ? '${3 + i % 150}' : '',
    );
    if (draft case Ok(:final value)) {
      if (await repo.create(value) is Ok) saved++;
    }
  }
  return saved;
}
