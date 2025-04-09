import 'package:luanvan/models/supplier.dart';

abstract class SupplierState {}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<Supplier> suppliers;
  SupplierLoaded(this.suppliers);
}

class SupplierError extends SupplierState {
  final String message;
  SupplierError(this.message);
}

class SupplierOperationSuccess extends SupplierState {
  final String message;
  SupplierOperationSuccess(this.message);
}
