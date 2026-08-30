import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_event.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_state.dart';
import 'package:ocam_pos/presentation/cashdrawer/widgets/cash_main_menu.dart';
import 'package:ocam_pos/presentation/cashdrawer/widgets/transfer_form.dart';
import 'package:ocam_pos/presentation/employee/pages/add_employee_page.dart';

class CashDrawerPage extends StatefulWidget {
  const CashDrawerPage({super.key});

  @override
  State<CashDrawerPage> createState() => _CashDrawerPageState();
}

class _CashDrawerPageState extends State<CashDrawerPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CashBloc>().add(const LoadCashDrawer());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<CashBloc, CashState>(
        listenWhen: (previous, current) =>
            current.actionMessage != previous.actionMessage ||
            current.error != previous.error,
        listener: (context, state) {
          if (state.actionMessage != null) {
            _amountController.clear();
            _noteController.clear();
            context.read<CashBloc>().add(const TransferFormChanged());
            AppSnackBar.success(context, state.actionMessage!);
          } else if (state.error != null) {
            AppSnackBar.error(context, state.error!);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                CashMainMenuWidget(balance: state.from?.balance ?? 0),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTransferCard(context, state),
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
                    onPressed: state.isTransferring
                        ? null
                        : () => _confirmTransfer(context, state),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransferCard(BuildContext context, CashState state) {
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
            "O'tkazma tafsiloti",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Divider(height: 32),
          _employeeDropdown(
            context,
            "Kimdan (yuboruvchi)",
            state.from,
            state.employees,
            (emp) => context
                .read<CashBloc>()
                .add(TransferFormChanged(from: emp, to: state.to)),
          ),
          const SizedBox(height: 20),
          _employeeDropdown(
            context,
            "Kimga (qabul qiluvchi)",
            state.to,
            state.employees,
            (emp) => context
                .read<CashBloc>()
                .add(TransferFormChanged(from: state.from, to: emp)),
          ),
        ],
      ),
    );
  }

  Widget _employeeDropdown(
    BuildContext context,
    String label,
    EmployeeModel? current,
    List<EmployeeModel> employees,
    ValueChanged<EmployeeModel?> onChanged,
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
          initialValue: current?.id,
          isExpanded: true,
          hint: const Text("Xodimni tanlang"),
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
            ...employees.map(
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
              _showAddEmployeeSimpleDialog(context);
              return;
            }
            EmployeeModel? match;
            for (final e in employees) {
              if (e.id == val) {
                match = e;
                break;
              }
            }
            onChanged(match);
          },
        ),
      ],
    );
  }

  void _showAddEmployeeSimpleDialog(BuildContext context) {
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

  void _confirmTransfer(BuildContext context, CashState state) {
    final amountStr = _amountController.text;
    final amount = AppFormat.parseAmount(amountStr);

    if (state.from == null || state.to == null || amount <= 0) {
      AppSnackBar.error(context, "Ma'lumotlarni to'liq kiriting!");
      return;
    }

    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text("Tasdiqlash"),
        content: Text(
          "${state.from!.name} -> ${state.to!.name}\nSumma: ${AppFormat.money(amount)}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text("Yo'q", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(d);
              context.read<CashBloc>().add(
                TransferRequested(
                  from: state.from,
                  to: state.to,
                  amount: amountStr,
                  note: _noteController.text,
                ),
              );
            },
            child: const Text("Ha", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
