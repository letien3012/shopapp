import 'package:luanvan/models/import_receipt.dart';

abstract class ImportReceiptEvent {}

class LoadImportReceipts extends ImportReceiptEvent {}

class LoadImportReceiptsByStatus extends ImportReceiptEvent {
  final ImportReceiptStatus status;
  LoadImportReceiptsByStatus(this.status);
}

class LoadImportReceiptById extends ImportReceiptEvent {
  final String id;
  LoadImportReceiptById(this.id);
}

class CreateImportReceipt extends ImportReceiptEvent {
  final ImportReceipt receipt;

  CreateImportReceipt(this.receipt);
}

class UpdateImportReceipt extends ImportReceiptEvent {
  final ImportReceipt receipt;

  UpdateImportReceipt(this.receipt);
}

class DeleteImportReceipt extends ImportReceiptEvent {
  final String id;

  DeleteImportReceipt(this.id);
}

class GetImportReceiptById extends ImportReceiptEvent {
  final String id;

  GetImportReceiptById(this.id);
}
