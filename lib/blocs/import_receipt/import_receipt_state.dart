import 'package:luanvan/models/import_receipt.dart';

abstract class ImportReceiptState {}

class ImportReceiptInitial extends ImportReceiptState {}

class ImportReceiptLoading extends ImportReceiptState {}

class ImportReceiptsLoaded extends ImportReceiptState {
  final List<ImportReceipt> receipts;
  ImportReceiptsLoaded(this.receipts);
}

class ImportReceiptLoaded extends ImportReceiptState {
  final ImportReceipt receipt;
  ImportReceiptLoaded(this.receipt);
}

class ImportReceiptCreated extends ImportReceiptState {}

class ImportReceiptError extends ImportReceiptState {
  final String message;

  ImportReceiptError(this.message);
}
