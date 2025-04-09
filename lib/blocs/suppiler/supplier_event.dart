import 'package:luanvan/models/supplier.dart';

abstract class SupplierEvent {}

class LoadSuppliers extends SupplierEvent {}

class AddSupplier extends SupplierEvent {
  final Supplier supplier;
  AddSupplier(this.supplier);
}

class UpdateSupplier extends SupplierEvent {
  final Supplier supplier;

  UpdateSupplier(this.supplier);
}

class DeleteSupplier extends SupplierEvent {
  final String id;

  DeleteSupplier(this.id);
}
