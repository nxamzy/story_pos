import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/transfer_log_model.dart';
import 'package:ocam_pos/data/models/transfer_party_model.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_event.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_state.dart';
import 'package:ocam_pos/presentation/cashdrawer/widgets/cash_main_menu.dart';
import 'package:ocam_pos/presentation/cashdrawer/widgets/transfer_form.dart';
import 'package:ocam_pos/presentation/employee/pages/add_employee_page.dart';

/// Kassa: balans, pul o'tkazmalari va ularning tarixi.
///
/// O'tkazmada kassaning o'zi ham taraf bo'la oladi ("Kassa" -> xodim yoki
/// xodim -> "Kassa"). Ilgari faqat ikki xodim orasida o'tkazish mumkin edi:
/// naqd savdodan kelgan pul kassada to'planib borardi va uni kassadan
/// chiqarib olishni yozib qo'yishning imkoni yo'q edi.
class CashDrawerPage extends StatefulWidget {
  const CashDrawerPage({super.key});

  @override
  State<CashDrawerPage> createState() => _CashDrawerPageState();
}

class _CashDrawerPageState extends State<CashDrawerPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  /// Dropdown o'z tanlovini ichida saqlaydi. "Yangi xodim qo'shish"
  /// bosilganda BLoC holati o'zgarmaydi, shu sababli maydon o'sha yozuvni
  /// ko'rsatib qolardi — kalitni almashtirib uni asl holatiga qaytaramiz.
  int _dropdownEpoch = 0;

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
                CashMainMenuWidget(balance: state.balance),
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
                        const SizedBox(height: 24),
                        _buildHistory(state),
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
          _partyDropdown(
            context,
            label: "Kimdan (yuboruvchi)",
            current: state.from,
            parties: state.parties,
            onChanged: (party) => context.read<CashBloc>().add(
              TransferFormChanged(fromId: party?.id, toId: state.toId),
            ),
          ),
          const SizedBox(height: 20),
          _partyDropdown(
            context,
            label: "Kimga (qabul qiluvchi)",
            current: state.to,
            parties: state.parties,
            onChanged: (party) => context.read<CashBloc>().add(
              TransferFormChanged(fromId: state.fromId, toId: party?.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _partyDropdown(
    BuildContext context, {
    required String label,
    required TransferParty? current,
    required List<TransferParty> parties,
    required ValueChanged<TransferParty?> onChanged,
  }) {
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
          key: ValueKey('$label-${current?.id}-$_dropdownEpoch'),
          initialValue: current?.id,
          isExpanded: true,
          hint: const Text("Kassa yoki xodimni tanlang"),
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
            ...parties.map(
              (party) => DropdownMenuItem<String>(
                value: party.id,
                child: Row(
                  children: [
                    Icon(
                      party.isDrawer
                          ? Icons.point_of_sale_rounded
                          : Icons.person_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        party.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Balansni ko'rsatish — kassirga qancha pul borligini
                    // tanlash paytida bilish kerak.
                    Text(
                      AppFormat.money(party.balance),
                      style: const TextStyle(
                        color: AppColors.sage,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const DropdownMenuItem<String>(
              value: _addNewValue,
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
          onChanged: (value) {
            if (value == _addNewValue) {
              setState(() => _dropdownEpoch++);
              _showAddEmployeeDialog(context);
              return;
            }
            onChanged(
              context.read<CashBloc>().state.partyById(value),
            );
          },
        ),
      ],
    );
  }

  /// So'nggi o'tkazmalar. Ma'lumot `CashBloc`da allaqachon yuklanardi, lekin
  /// ekranda umuman ko'rsatilmasdi.
  Widget _buildHistory(CashState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "So'nggi o'tkazmalar",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Divider(height: 24, color: AppColors.mintLight),
          if (state.status.isFirstLoad)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else if (state.logs.isEmpty)
            const Text(
              "Hozircha o'tkazmalar yo'q",
              style: TextStyle(color: AppColors.sage),
            )
          else
            for (final log in state.logs.take(10)) _TransferLogTile(log: log),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
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
    final from = state.from;
    final to = state.to;

    if (from == null || to == null || amount <= 0) {
      AppSnackBar.error(context, "Ma'lumotlarni to'liq kiriting!");
      return;
    }

    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text("Tasdiqlash"),
        content: Text(
          "${from.name} -> ${to.name}\nSumma: ${AppFormat.money(amount)}",
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

const String _addNewValue = 'ADD_NEW';

class _TransferLogTile extends StatelessWidget {
  final TransferLogModel log;

  const _TransferLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${log.fromName} -> ${log.toName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  log.note.isEmpty
                      ? AppFormat.dateTime(log.createdAt)
                      : "${AppFormat.dateTime(log.createdAt)} · ${log.note}",
                  style: const TextStyle(color: AppColors.sage, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppFormat.money(log.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
