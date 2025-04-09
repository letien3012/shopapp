import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/suppiler/supplier_bloc.dart';
import 'package:luanvan/blocs/suppiler/supplier_event.dart';
import 'package:luanvan/blocs/suppiler/supplier_state.dart';
import 'package:luanvan/models/supplier.dart';

class AddImportReceiptSupplierScreen extends StatefulWidget {
  const AddImportReceiptSupplierScreen({super.key});
  static String routeName = "add_import_receipt_supplier";

  @override
  State<AddImportReceiptSupplierScreen> createState() =>
      _AddImportReceiptSupplierScreenState();
}

class _AddImportReceiptSupplierScreenState
    extends State<AddImportReceiptSupplierScreen> {
  List<Supplier> suppliers = [];
  List<Supplier> suggestedSuppliers = [];
  final TextEditingController _searchController = TextEditingController();
  Supplier? selectedSupplier;

  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(LoadSuppliers());
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final selectedSupplierId = args['selectedSupplier'] as String?;
        if (selectedSupplierId != null &&
            context.read<SupplierBloc>().state is SupplierLoaded) {
          final state = context.read<SupplierBloc>().state as SupplierLoaded;

          final supplier = state.suppliers
              .where((s) => s.status == SupplierStatus.active)
              .toList();
          _findAndSetSelectedSupplier(selectedSupplierId, supplier);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (context.read<SupplierBloc>().state is SupplierLoaded) {
      final state = context.read<SupplierBloc>().state as SupplierLoaded;
      final query = _searchController.text.toLowerCase();
      setState(() {
        suggestedSuppliers = state.suppliers
            .where((supplier) =>
                supplier.name.toLowerCase().contains(query) ||
                (supplier.phone ?? '').toLowerCase().contains(query))
            .toList();
      });
    }
  }

  void _findAndSetSelectedSupplier(
      String supplierId, List<Supplier> allSuppliers) {
    if (supplierId.isEmpty || allSuppliers.isEmpty) {
      return;
    }
    final supplier = allSuppliers.firstWhere(
      (s) => s.id == supplierId,
    );
    setState(() {
      selectedSupplier = supplier;
    });
  }

  Widget _buildSupplierItem(Supplier supplier) {
    final isSelected = selectedSupplier?.id == supplier.id;
    return Column(
      children: [
        ListTile(
          title: Text(
            supplier.name,
            style: TextStyle(
              color: isSelected ? Colors.brown : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            setState(() {
              selectedSupplier = supplier;
            });
            Navigator.pop(context, supplier);
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSupplierList() {
    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        if (state is SupplierLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SupplierError) {
          return Center(child: Text(state.message));
        }

        if (state is SupplierLoaded) {
          final suppliers = state.suppliers
              .where((s) => s.status == SupplierStatus.active)
              .toList();
          final displayedSuppliers =
              _searchController.text.isEmpty ? suppliers : suggestedSuppliers;

          if (suppliers.isEmpty) {
            return const Center(
              child: Text('Không tìm thấy nhà cung cấp nào'),
            );
          }

          return Container(
            color: Colors.white,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: displayedSuppliers.length,
              itemBuilder: (context, index) {
                return _buildSupplierItem(displayedSuppliers[index]);
              },
            ),
          );
        }

        return const Center(child: Text('Đang tải...'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: _buildSupplierList(),
          ),
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding:
                const EdgeInsets.only(top: 40, left: 8, right: 8, bottom: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm nhà cung cấp...',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
