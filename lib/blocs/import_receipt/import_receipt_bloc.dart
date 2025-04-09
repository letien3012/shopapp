import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/import_receipt/import_receipt_event.dart';
import 'package:luanvan/blocs/import_receipt/import_receipt_state.dart';
import 'package:luanvan/services/import_receipt_service.dart';

class ImportReceiptBloc extends Bloc<ImportReceiptEvent, ImportReceiptState> {
  final ImportReceiptService _importReceiptService;

  ImportReceiptBloc(this._importReceiptService)
      : super(ImportReceiptInitial()) {
    on<LoadImportReceipts>(_onLoadImportReceipts);
    on<LoadImportReceiptsByStatus>(_onLoadImportReceiptsByStatus);
    on<LoadImportReceiptById>(_onLoadImportReceiptById);
    on<CreateImportReceipt>(_onCreateImportReceipt);
    on<UpdateImportReceipt>(_onUpdateImportReceipt);
    on<DeleteImportReceipt>(_onDeleteImportReceipt);
    on<GetImportReceiptById>(_onGetImportReceiptById);
  }

  Future<void> _onLoadImportReceipts(
      LoadImportReceipts event, Emitter<ImportReceiptState> emit) async {
    emit(ImportReceiptLoading());
    try {
      final receipts = await _importReceiptService.getImportReceipts();
      emit(ImportReceiptsLoaded(receipts));
    } catch (e) {
      emit(ImportReceiptError(e.toString()));
    }
  }

  Future<void> _onLoadImportReceiptsByStatus(LoadImportReceiptsByStatus event,
      Emitter<ImportReceiptState> emit) async {
    emit(ImportReceiptLoading());
    try {
      final receipts =
          await _importReceiptService.getImportReceiptsByStatus(event.status);
      emit(ImportReceiptsLoaded(receipts));
    } catch (e) {
      emit(ImportReceiptError(e.toString()));
    }
  }

  Future<void> _onLoadImportReceiptById(
      LoadImportReceiptById event, Emitter<ImportReceiptState> emit) async {
    emit(ImportReceiptLoading());
    try {
      final receipt =
          await _importReceiptService.getImportReceiptById(event.id);
      if (receipt != null) {
        emit(ImportReceiptLoaded(receipt));
      } else {
        emit(ImportReceiptError('Import receipt not found'));
      }
    } catch (e) {
      emit(ImportReceiptError(e.toString()));
    }
  }

  Future<void> _onCreateImportReceipt(
      CreateImportReceipt event, Emitter<ImportReceiptState> emit) async {
    emit(ImportReceiptLoading());
    try {
      await _importReceiptService.createImportReceipt(event.receipt);
      emit(ImportReceiptCreated());
    } catch (e) {
      emit(ImportReceiptError(e.toString()));
    }
  }

  Future<void> _onUpdateImportReceipt(
      UpdateImportReceipt event, Emitter<ImportReceiptState> emit) async {
    emit(ImportReceiptLoading());
    try {
      await _importReceiptService.updateImportReceipt(event.receipt);
      add(LoadImportReceipts());
    } catch (e) {
      emit(ImportReceiptError(e.toString()));
    }
  }

  Future<void> _onDeleteImportReceipt(
      DeleteImportReceipt event, Emitter<ImportReceiptState> emit) async {
    emit(ImportReceiptLoading());
    try {
      await _importReceiptService.deleteImportReceipt(event.id);
      add(LoadImportReceipts());
    } catch (e) {
      emit(ImportReceiptError(e.toString()));
    }
  }

  Future<void> _onGetImportReceiptById(
      GetImportReceiptById event, Emitter<ImportReceiptState> emit) async {
    emit(ImportReceiptLoading());
    try {
      final receipt =
          await _importReceiptService.getImportReceiptById(event.id);
      if (receipt != null) {
        emit(ImportReceiptLoaded(receipt));
      } else {
        emit(ImportReceiptError('Import receipt not found'));
      }
    } catch (e) {
      emit(ImportReceiptError(e.toString()));
    }
  }
}
