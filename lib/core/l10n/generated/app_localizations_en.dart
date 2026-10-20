// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Daftar Afandi';

  @override
  String get welcomeTitle => 'Welcome to Daftar Afandi';

  @override
  String get welcomeBody =>
      'Your shop\'s books: sales, purchases, customers and suppliers, all on your phone and working without the internet.';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get continueAction => 'Continue';

  @override
  String get shopDetailsTitle => 'Shop details';

  @override
  String get shopNameLabel => 'Shop name';

  @override
  String get shopPhoneLabel => 'Shop phone';

  @override
  String get shopPhoneOptionalHint => 'Optional. Shown on invoices you share.';

  @override
  String get errorShopNameRequired => 'Enter the shop name.';

  @override
  String errorShopNameTooLong(String max) {
    return 'The shop name can be at most $max characters.';
  }

  @override
  String get errorPhoneInvalid =>
      'The phone number can only contain digits, with an optional + at the start.';

  @override
  String errorPhoneTooShort(String min) {
    return 'The phone number needs at least $min digits.';
  }

  @override
  String errorPhoneTooLong(String max) {
    return 'The phone number can have at most $max digits.';
  }

  @override
  String get errorSaveFailed =>
      'Couldn\'t save. What you typed is still here; try again.';

  @override
  String get dataSafetyTitle => 'About your data';

  @override
  String get dataSafetyLocalOnly =>
      'Your data is stored only on this phone and is never sent to any server.';

  @override
  String get dataSafetyAndroidBackup =>
      'If backup is turned on in your phone settings, Android automatically saves a copy of your data to your Google account, so it comes back if you reinstall the app with the same account.';

  @override
  String get dataSafetyIosManual =>
      'On iPhone there is no automatic backup. You\'ll be able to export a backup yourself in an upcoming update; do it regularly.';

  @override
  String get finishAction => 'Get started';

  @override
  String get navHome => 'Home';

  @override
  String get navSales => 'Sales';

  @override
  String get navParties => 'Customers & Suppliers';

  @override
  String get navPurchases => 'Purchases';

  @override
  String get navReports => 'Reports';

  @override
  String get placeholderHomeTitle => 'Home';

  @override
  String get placeholderHomeBody =>
      'Here you\'ll see a summary of your day: sales, expenses, cash, and important alerts.';

  @override
  String get placeholderSalesTitle => 'Sales';

  @override
  String get placeholderSalesBody =>
      'Here you\'ll record sales invoices and returns and share them with your customers.';

  @override
  String get placeholderPartiesTitle => 'Customers & Suppliers';

  @override
  String get placeholderPartiesBody =>
      'Here you\'ll follow your customers and suppliers, and what each one owes you or you owe them.';

  @override
  String get placeholderPurchasesTitle => 'Purchases';

  @override
  String get placeholderPurchasesBody =>
      'Here you\'ll record purchase invoices from suppliers, and stock and cost update automatically.';

  @override
  String get placeholderReportsTitle => 'Reports';

  @override
  String get placeholderReportsBody =>
      'Here you\'ll find reports on sales, profit, stock and expenses.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsShopDetails => 'Shop details';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDigitStyle => 'Digit style';

  @override
  String get digitStyleFollowLanguage => 'Follow the language';

  @override
  String get digitStyleArabic => 'Arabic-Indic (٠١٢٣)';

  @override
  String get digitStyleLatin => 'Latin (0123)';

  @override
  String get settingsAboutData => 'About your data';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get saveAction => 'Save';

  @override
  String get openSettingsSemantics => 'Open settings';

  @override
  String get logoSemantics => 'Daftar Afandi logo';

  @override
  String get updateRequiredTitle => 'Please update the app';

  @override
  String get updateRequiredBody =>
      'Your data was saved by a newer version of Daftar Afandi. Update the app from the store to open it. Nothing in your data was changed.';

  @override
  String get dataUnrecognizedBody =>
      'The data file on this phone isn\'t recognized by this version of Daftar Afandi. Update the app from the store. Nothing in the file was changed.';

  @override
  String get startupErrorBody =>
      'Your data couldn\'t be opened. Nothing in it was changed. Close the app and open it again; if the problem continues, update the app from the store.';

  @override
  String get homeProductsAction => 'Products';

  @override
  String get homeCategoriesAction => 'Categories';

  @override
  String get lowStockCardTitle => 'Low stock';

  @override
  String lowStockCount(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText products are low on stock',
      one: '1 product is low on stock',
    );
    return '$_temp0';
  }

  @override
  String get lowStockNone => 'Stock is fine.';

  @override
  String get lowStockNoProducts => 'Add products to track their stock.';

  @override
  String get lowStockSeeAll => 'See all';

  @override
  String get productsTitle => 'Products';

  @override
  String get productsSearchHint => 'Search by name, code or barcode';

  @override
  String get productsFilterAll => 'All';

  @override
  String get productsFilterNoCategory => 'No category';

  @override
  String get productsFilterLow => 'Low stock';

  @override
  String get productsArchivedTitle => 'Archived products';

  @override
  String get productsEmpty =>
      'No products yet. Add your first product to start.';

  @override
  String get productsEmptyAction => 'Add product';

  @override
  String productsNoMatch(String query) {
    return 'No product named “$query”.';
  }

  @override
  String productsAddNamed(String name) {
    return 'Add “$name”';
  }

  @override
  String get markLowStock => 'Low stock';

  @override
  String get markBelowZero => 'Stock below zero';

  @override
  String get productArchivedBadge => 'Archived';

  @override
  String get unitPiece => 'By piece';

  @override
  String get unitKg => 'By kilogram';

  @override
  String get unitLiter => 'By liter';

  @override
  String get unitMeter => 'By meter';

  @override
  String get unitPieceShort => 'pc';

  @override
  String get unitKgShort => 'kg';

  @override
  String get unitLiterShort => 'L';

  @override
  String get unitMeterShort => 'm';

  @override
  String get productAddTitle => 'Add product';

  @override
  String get productEditTitle => 'Edit product';

  @override
  String get productNameLabel => 'Product name';

  @override
  String get productUnitLabel => 'Sold';

  @override
  String get productPriceLabel => 'Sale price per unit';

  @override
  String get productCategoryLabel => 'Category';

  @override
  String get productNoCategory => 'No category';

  @override
  String get productBarcodeLabel => 'Barcode';

  @override
  String get productSkuLabel => 'Code';

  @override
  String get productLowStockLabel => 'Low-stock level';

  @override
  String get productLowStockHint =>
      'You\'ll see a mark when stock reaches this quantity or less.';

  @override
  String get productOpeningSection => 'Opening stock';

  @override
  String get productOpeningHint =>
      'What\'s on the shelf now and what each unit cost you.';

  @override
  String get productOpeningQtyLabel => 'Quantity on hand';

  @override
  String get productOpeningCostLabel => 'Cost per unit';

  @override
  String get productUnitLockedNote =>
      'The unit can\'t change once the product has stock history.';

  @override
  String get openingConfirmTitle => 'Confirm opening stock';

  @override
  String openingConfirmBody(String qty, String cost, String total) {
    return '$qty × $cost = $total\nOpening stock can\'t be changed after saving.';
  }

  @override
  String get confirmAction => 'Confirm';

  @override
  String get backAction => 'Back';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get productNameExistsNotice =>
      'Saved. Another product has the same name.';

  @override
  String get errorNameRequired => 'Enter the product name.';

  @override
  String errorNameTooLong(String max) {
    return 'The name can be at most $max characters.';
  }

  @override
  String get errorPriceRequired => 'Enter the sale price.';

  @override
  String get errorPriceInvalid =>
      'Enter a valid amount with at most two decimal places.';

  @override
  String errorPriceTooLarge(String max) {
    return 'The amount can be at most $max.';
  }

  @override
  String get errorQuantityRequired => 'Enter the quantity.';

  @override
  String get errorQuantityInvalid =>
      'Enter a valid quantity with at most three decimal places.';

  @override
  String get errorQuantityNotWhole => 'Pieces are whole numbers.';

  @override
  String errorQuantityTooLarge(String max) {
    return 'The quantity can be at most $max.';
  }

  @override
  String get errorOpeningCostRequired =>
      'Enter the cost per unit; it\'s needed to work out profit.';

  @override
  String errorBarcodeTaken(String name) {
    return 'This barcode is already used by “$name”.';
  }

  @override
  String errorCodeTooLong(String max) {
    return 'At most $max characters.';
  }

  @override
  String errorRestoreBarcodeTaken(String name) {
    return 'Can\'t restore: the barcode is now used by “$name”.';
  }

  @override
  String errorNoteTooLong(String max) {
    return 'The note can be at most $max characters.';
  }

  @override
  String get productDetailsTitle => 'Product details';

  @override
  String get productAvgCost => 'Average cost';

  @override
  String get productStockOnHand => 'Stock on hand';

  @override
  String get productEditAction => 'Edit';

  @override
  String get productAdjustAction => 'Adjust stock';

  @override
  String get productSetOpeningAction => 'Set opening stock';

  @override
  String get productArchiveAction => 'Archive';

  @override
  String get productArchiveConfirm =>
      'Archive this product? It leaves the list and search; its history is kept and you can restore it.';

  @override
  String get productRestoreAction => 'Restore';

  @override
  String get productRestored => 'Product restored.';

  @override
  String get historyTitle => 'Stock history';

  @override
  String get historyEmpty => 'No stock changes yet.';

  @override
  String get historyShowMore => 'Show more';

  @override
  String get stockOpening => 'Opening stock';

  @override
  String get stockPurchase => 'Purchase';

  @override
  String get stockPurchaseVoid => 'Purchase voided';

  @override
  String get stockSale => 'Sale';

  @override
  String get stockSaleReturn => 'Sale return';

  @override
  String get stockSaleVoid => 'Sale voided';

  @override
  String get stockAdjustment => 'Adjustment';

  @override
  String get reasonDamage => 'Damaged';

  @override
  String get reasonCount => 'Stock count';

  @override
  String get reasonOther => 'Other';

  @override
  String get adjustTitle => 'Adjust stock';

  @override
  String get adjustReasonLabel => 'Reason';

  @override
  String adjustOnHand(String qty) {
    return 'On hand now: $qty';
  }

  @override
  String get adjustCountedLabel => 'Counted quantity';

  @override
  String get adjustRemoveLabel => 'Quantity to remove';

  @override
  String get adjustAdd => 'Add';

  @override
  String get adjustRemove => 'Remove';

  @override
  String get adjustQtyLabel => 'Quantity';

  @override
  String get adjustNoteLabel => 'Note';

  @override
  String get adjustNoteRequired => 'Write a note explaining why.';

  @override
  String adjustExceedsStock(String qty) {
    return 'Only $qty on hand.';
  }

  @override
  String get adjustAlreadyMatches =>
      'Stock already matches; nothing was recorded.';

  @override
  String adjustSaved(String qty) {
    return 'Saved. Stock is now $qty.';
  }

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoryAddHint => 'New category name';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get categoryAddAction => 'Add';

  @override
  String get categoryRename => 'Rename';

  @override
  String get categoryMoveUp => 'Move up';

  @override
  String get categoryMoveDown => 'Move down';

  @override
  String get categoryArchive => 'Archive category';

  @override
  String get categoryArchiveConfirm =>
      'Archive this category? Its products stay and show as “No category”.';

  @override
  String categoryProductCount(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }

  @override
  String get categoriesEmpty => 'No categories yet.';

  @override
  String get errorCategoryNameRequired => 'Enter the category name.';

  @override
  String get errorCategoryDuplicate =>
      'A category with this name already exists.';

  @override
  String errorCategoryNameTooLong(String max) {
    return 'The category name can be at most $max characters.';
  }

  @override
  String get productsFilterEmpty => 'No products match this filter.';

  @override
  String get productNotFound => 'This product doesn\'t exist.';

  @override
  String get productsArchivedEmpty => 'No archived products.';

  @override
  String get demoSeedMenu => 'Developer tools';

  @override
  String get demoSeedAction => 'Seed demo products';

  @override
  String demoSeedDone(String count) {
    return 'Added demo products: $count.';
  }

  @override
  String get salesNewAction => 'New sale';

  @override
  String get salesListEmpty => 'No invoices yet.';

  @override
  String get salesNoMatch => 'No matching invoices.';

  @override
  String get salesSearchHint => 'Search by invoice number or customer';

  @override
  String get salesFilterUnpaid => 'Not fully paid';

  @override
  String get listShowMore => 'Show more';

  @override
  String get walkInCustomer => 'Walk-in customer';

  @override
  String get saleKindCredit => 'Credit';

  @override
  String get saleKindPartial => 'Partly paid';

  @override
  String get saleVoidedBadge => 'Voided';

  @override
  String get saleNewTitle => 'New sale';

  @override
  String get saleAddProductAction => 'Add product';

  @override
  String get saleBarcodeLabel => 'Scan or type a barcode';

  @override
  String get saleBarcodeNotFound => 'No active product has this barcode.';

  @override
  String get saleEmpty => 'Add a product to start.';

  @override
  String get saleQtyLabel => 'Quantity';

  @override
  String get salePriceLabel => 'Unit price';

  @override
  String get saleLineDiscountLabel => 'Line discount';

  @override
  String saleRemoveLine(String name) {
    return 'Remove $name from the sale';
  }

  @override
  String saleLineTotal(String amount) {
    return 'Line total: $amount';
  }

  @override
  String get saleSubtotal => 'Subtotal';

  @override
  String get saleInvoiceDiscountLabel => 'Invoice discount';

  @override
  String get saleTotal => 'Total';

  @override
  String get salePaidLabel => 'Paid now';

  @override
  String get salePaidHint => 'Leave empty to pay the whole total';

  @override
  String get saleRemaining => 'Remaining';

  @override
  String get saleMethodLabel => 'Payment method';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodWallet => 'Mobile wallet';

  @override
  String get methodInstapay => 'InstaPay';

  @override
  String get methodCard => 'Card';

  @override
  String get saleCustomerLabel => 'Customer';

  @override
  String get saleCustomerPick => 'Pick a customer';

  @override
  String get saleCustomerClear => 'No customer';

  @override
  String get saleSaveAction => 'Save invoice';

  @override
  String saleSaved(String number) {
    return 'Invoice $number saved.';
  }

  @override
  String get saleDiscardTitle => 'Discard this sale?';

  @override
  String get saleDiscardBody => 'The products added will not be saved.';

  @override
  String get saleDiscardAction => 'Discard';

  @override
  String get saleKeepAction => 'Keep selling';

  @override
  String get shortageTitle => 'Not enough stock';

  @override
  String get shortageBody => 'Stock will go below zero for:';

  @override
  String shortageLine(String name, String stock, String need) {
    return '$name: $stock on hand, $need needed';
  }

  @override
  String get shortageConfirm => 'Save anyway';

  @override
  String get errorSaleNoLines => 'Add at least one product.';

  @override
  String get errorCreditNeedsCustomer =>
      'Credit or part payment needs a named customer.';

  @override
  String get errorPaidTooLarge => 'Paid now is more than the total.';

  @override
  String get errorLineDiscountTooLarge =>
      'The discount is more than the line amount.';

  @override
  String get errorInvoiceDiscountTooLarge =>
      'The discount is more than the subtotal.';

  @override
  String errorProductUnavailable(String name) {
    return '“$name” is no longer available; remove it from the sale.';
  }

  @override
  String get errorCustomerUnavailable =>
      'The customer is no longer available; pick another.';

  @override
  String invoiceTitle(String number) {
    return 'Sales invoice $number';
  }

  @override
  String get invoiceDateLabel => 'Date';

  @override
  String invoiceLineDetail(String qty, String price) {
    return '$qty × $price';
  }

  @override
  String invoiceLineDiscount(String amount) {
    return 'Discount $amount';
  }

  @override
  String get invoiceVoidAction => 'Void invoice';

  @override
  String get invoiceVoidTitle => 'Void this invoice?';

  @override
  String get invoiceVoidBody =>
      'Stock and the customer’s balance go back to before the sale. This cannot be undone.';

  @override
  String get reasonLabel => 'Reason';

  @override
  String invoiceVoidedOn(String date, String reason) {
    return 'Voided on $date: $reason';
  }

  @override
  String get invoiceVoided => 'Invoice voided.';

  @override
  String get invoiceNotFound => 'This invoice doesn’t exist.';

  @override
  String get invoiceAlreadyVoided => 'This invoice is already voided.';

  @override
  String get paymentAlreadyCancelled => 'This payment is already cancelled.';

  @override
  String get paymentNotCancellable =>
      'A payment made with a sale can’t be cancelled on its own. Void the invoice instead.';

  @override
  String get errorActionFailed =>
      'Couldn’t finish. Nothing changed; try again.';

  @override
  String get errorReasonRequired => 'Write the reason.';

  @override
  String errorReasonTooLong(String max) {
    return 'The reason can be at most $max characters.';
  }

  @override
  String get customersTitle => 'Customers';

  @override
  String get customersSearchHint => 'Search by name or phone';

  @override
  String get customersFilterOwes => 'Owe money';

  @override
  String get customersEmpty => 'No customers yet.';

  @override
  String get customersNoMatch => 'No matching customers.';

  @override
  String get customerAddTitle => 'Add customer';

  @override
  String customerAddNamed(String name) {
    return 'Add “$name”';
  }

  @override
  String get customersArchivedTitle => 'Archived customers';

  @override
  String get customersArchivedEmpty => 'No archived customers.';

  @override
  String get customerEditTitle => 'Edit customer';

  @override
  String get customerNameLabel => 'Customer name';

  @override
  String get customerPhoneLabel => 'Phone';

  @override
  String get customerAddressLabel => 'Address';

  @override
  String get customerNoteLabel => 'Note';

  @override
  String get customerOpeningSection => 'Opening balance';

  @override
  String get customerOpeningHint =>
      'If the customer had an account before you used the app. It can’t be changed after saving.';

  @override
  String get customerOpeningAmount => 'Amount';

  @override
  String get customerOpeningOwes => 'Customer owes the shop';

  @override
  String get customerOpeningInFavour => 'Shop owes the customer';

  @override
  String get customerNameExistsNotice =>
      'Saved. Another customer has the same name.';

  @override
  String get customerDetailsTitle => 'Customer';

  @override
  String get customerBalanceLabel => 'Balance';

  @override
  String balanceOwes(String amount) {
    return 'Owes $amount';
  }

  @override
  String balanceInFavour(String amount) {
    return 'In credit $amount';
  }

  @override
  String get balanceZero => 'No balance';

  @override
  String get customerReceivePayment => 'Receive payment';

  @override
  String get customerArchiveAction => 'Archive customer';

  @override
  String get customerArchiveConfirm =>
      'Archive this customer? Their invoices and statement stay and you can restore them.';

  @override
  String customerArchiveConfirmBalance(String balance) {
    return 'Archive this customer? Their balance of $balance stays, as do their invoices and statement; you can restore them.';
  }

  @override
  String get customerArchivedBadge => 'Archived';

  @override
  String get customerRestoreAction => 'Restore';

  @override
  String get customerRestored => 'Customer restored.';

  @override
  String get customerNotFound => 'This customer doesn’t exist.';

  @override
  String get statementTitle => 'Statement';

  @override
  String get statementEmpty => 'No entries yet.';

  @override
  String get ledgerOpening => 'Opening balance';

  @override
  String ledgerSale(String number) {
    return 'Invoice $number';
  }

  @override
  String get ledgerPayment => 'Payment';

  @override
  String ledgerPaymentReceipt(String number) {
    return 'Payment $number';
  }

  @override
  String ledgerSaleVoid(String number) {
    return 'Voided invoice $number';
  }

  @override
  String get ledgerReversal => 'Reversal';

  @override
  String ledgerBalanceAfter(String amount) {
    return 'Balance: $amount';
  }

  @override
  String get ledgerCancelled => 'Cancelled';

  @override
  String get paymentCancelAction => 'Cancel payment';

  @override
  String get paymentCancelTitle => 'Cancel this payment?';

  @override
  String get paymentCancelBody =>
      'A reversing entry of the same amount is added and the balance goes back.';

  @override
  String get paymentCancelled => 'Payment cancelled.';

  @override
  String get customerInvoicesTitle => 'Invoices';

  @override
  String get paymentTitle => 'Receive payment';

  @override
  String paymentBalanceNow(String amount) {
    return 'Current balance: $amount';
  }

  @override
  String get paymentAmountLabel => 'Amount';

  @override
  String get paymentCreditTitle => 'More than the balance';

  @override
  String paymentCreditBody(String amount) {
    return 'The customer will have $amount in credit.';
  }

  @override
  String paymentSaved(String number) {
    return 'Payment $number saved.';
  }

  @override
  String get errorAmountRequired => 'Enter the amount.';

  @override
  String get errorCustomerNameRequired => 'Enter the customer name.';

  @override
  String get errorCustomerArchived =>
      'The customer is archived; restore them first.';
}
