import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/services/supplier_service.dart';
import 'package:luanvan/blocs/suppiler/supplier_event.dart';
import 'package:luanvan/blocs/suppiler/supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierService _supplierService;

  SupplierBloc(this._supplierService) : super(SupplierInitial()) {
    on<LoadSuppliers>(_onLoadSuppliers);
    on<AddSupplier>(_onAddSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<DeleteSupplier>(_onDeleteSupplier);
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      emit(SupplierLoading());
      final suppliers = await _supplierService.getSuppliers();
      emit(SupplierLoaded(suppliers));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onAddSupplier(
    AddSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      emit(SupplierLoading());
      await _supplierService.addSupplier(event.supplier);
      emit(SupplierOperationSuccess('Thêm nhà cung cấp thành công'));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onUpdateSupplier(
    UpdateSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      emit(SupplierLoading());
      await _supplierService.updateSupplier(event.supplier);
      emit(SupplierOperationSuccess('Cập nhật nhà cung cấp thành công'));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onDeleteSupplier(
    DeleteSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      emit(SupplierLoading());
      await _supplierService.deleteSupplier(event.id);
      emit(SupplierOperationSuccess('Xóa nhà cung cấp thành công'));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }
}
