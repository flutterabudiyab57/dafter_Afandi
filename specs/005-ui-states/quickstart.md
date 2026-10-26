# Quickstart: UI States and Visual Polish

## Automated

```bash
flutter analyze
flutter test
flutter test test/core/theme/theme_test.dart
flutter test test/core/widgets
flutter test test/app
```

The run proves:
- **Theme:** every tone pair is at ≥ 4.5:1 in both themes, and the component themes read back.
- **Assets:** all 19 illustrations exist in light and dark at 1x, 2x and 3x.
- **Shared widgets:** they pass in ar and en at text scale 1.0 and 2.0. The skeleton waits
  300 ms and does not shimmer under reduced motion. A new bottom message replaces the old one.
- **Every-screen walk:** it includes the empty, load-failed and banner states, with no overflow
  and every control labelled.

## On a phone (debug build)

```bash
flutter build apk --debug
```

1. **Fresh install:** walk through Welcome, which shows its illustration. Open each section and
   list: each empty list shows its own illustration, title and action.
2. **Products:**
   - Add "شاي" with a low-stock level above its stock. The list shows a "مخزون قليل" badge and
     Home shows a warning banner with "عرض الكل".
   - Search "zzz": the no-results state appears, and "مسح البحث" brings the list back.
3. **Archive and undo:** archive "شاي". A message offers "تراجع"; tap it and "شاي" is back.
4. **Unsaved changes:** open the product form, change the name and press Back. "تجاهل
   التغييرات؟" appears, and "متابعة التعديل" stays on the form. Open it again without changes:
   Back leaves at once.
5. **New sale:**
   - On credit with no customer, a warning banner at the top offers "اختيار".
   - Saving shows "جارٍ الحفظ…" on the button, then the "تم حفظ الفاتورة" message.
6. **Void an invoice:** the dialog puts the destructive choice last, and the invoice then shows
   its voided banner.
7. **Dark theme:** switch the phone to dark. The illustrations switch, and banners and badges stay
   readable.
8. **English at 200%:** switch to English and 200% text, then repeat steps 2 to 5. Nothing is cut
   off and banners wrap.
9. **Reduced motion:** turn on "remove animations". Loading placeholders, where they appear, do
   not shimmer.

Values: [data-model.md](data-model.md). Components and screen states:
[contracts/ui-components.md](contracts/ui-components.md).
