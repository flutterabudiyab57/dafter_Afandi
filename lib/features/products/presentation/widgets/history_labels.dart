import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/stock_entry.dart';

/// The label of a history entry's type (FR-016).
String stockEntryLabel(AppLocalizations l10n, StockEntryType type) =>
    switch (type) {
      StockEntryType.opening => l10n.stockOpening,
      StockEntryType.purchase => l10n.stockPurchase,
      StockEntryType.purchaseVoid => l10n.stockPurchaseVoid,
      StockEntryType.sale => l10n.stockSale,
      StockEntryType.saleReturn => l10n.stockSaleReturn,
      StockEntryType.saleVoid => l10n.stockSaleVoid,
      StockEntryType.adjustment => l10n.stockAdjustment,
    };

/// The label of an adjustment reason.
String adjustmentKindLabel(AppLocalizations l10n, AdjustmentKind kind) =>
    switch (kind) {
      AdjustmentKind.damage => l10n.reasonDamage,
      AdjustmentKind.count => l10n.reasonCount,
      AdjustmentKind.other => l10n.reasonOther,
    };
