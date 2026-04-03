import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/repositories/cash_repository.dart';
import 'package:ocam_pos/presentation/pages/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/pages/cashdrawer/widgets/cash_main_menu_widget.dart';
import 'package:ocam_pos/presentation/pages/cashdrawer/widgets/transfer_widget.dart';
import 'package:ocam_pos/presentation/pages/employee/add_employee.dart';

class CashDrawerPage extends StatefulWidget {
  const CashDrawerPage({super.key});

  @override
  State<CashDrawerPage> createState() => _CashDrawerPageState();
}

class _CashDrawerPageState extends State<CashDrawerPage> {
  final _repo = CashRepositoryImpl();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedFromId;
  String? _selectedToId;
  List<EmployeeModel> _allEmployees = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _repo.getEmployees().listen((data) {
      if (mounted) {
        setState(() {
          _allEmployees = data;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  EmployeeModel? _findEmp(String? id) {
    if (id == null) return null;
    try {
      return _allEmployees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFrom = _findEmp(_selectedFromId);
    final selectedTo = _findEmp(_selectedToId);

    return BlocProvider(
      create: (_) => CashBloc(_repo),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<CashBloc, CashState>(
          listener: (context, state) {
            if (state is CashSuccess) {
              _amountController.clear();
              _noteController.clear();
              setState(() {
                _selectedFromId = null;
                _selectedToId = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Muvaffaqiyatli!"),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is CashError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  CashMainMenuWidget(balance: selectedFrom?.balance ?? 0.0),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTransferCard(),
                          const SizedBox(height: 24),
                          TransferWidget(
                            amountController: _amountController,
                            noteController: _noteController,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TransfermButtonWidget(
                      onPressed: state is CashLoading
                          ? null
                          : () => _confirmTransfer(
                              context,
                              selectedFrom,
                              selectedTo,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransferCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Transfer Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Divider(height: 32),
          _simpleDropdown("From (Sender)", _selectedFromId, (val) {
            setState(() => _selectedFromId = val);
          }),
          const SizedBox(height: 20),
          _simpleDropdown("To (Receiver)", _selectedToId, (val) {
            setState(() => _selectedToId = val);
          }),
        ],
      ),
    );
  }

  Widget _simpleDropdown(
    String label,
    String? currentId,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentId,
          isExpanded: true,
          hint: const Text("Select Employee"),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          items: [
            ..._allEmployees.map(
              (e) => DropdownMenuItem<String>(value: e.id, child: Text(e.name)),
            ),
            const DropdownMenuItem<String>(
              value: "ADD_NEW",
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Yangi xodim qo'shish",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (val) {
            if (val == "ADD_NEW") {
              _showAddEmployeeSimpleDialog();
            } else {
              onChanged(val);
            }
          },
        ),
      ],
    );
  }

  void _showAddEmployeeSimpleDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Yangi xodim"),
        content: const Text("Xodim qo'shish sahifasiga o'tasizmi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Yo'q", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmployeeAddPage(),
                ),
              );
            },
            child: const Text("O'tish", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmTransfer(
    BuildContext ctx,
    EmployeeModel? from,
    EmployeeModel? to,
  ) {
    final amountStr = _amountController.text;
    final amount = double.tryParse(amountStr) ?? 0.0;

    if (from == null || to == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ma'lumotlarni to'liq kiriting!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text("Tasdiqlash"),
        content: Text("${from.name} -> ${to.name}\nSumma: $amountStr"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text("Yo'q", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(d);
              ctx.read<CashBloc>().executeTransfer(
                from: from,
                to: to,
                amountStr: amountStr,
                note: _noteController.text,
              );
            },
            child: const Text("Ha", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
