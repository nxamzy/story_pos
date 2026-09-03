import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/core/widgets/confirm_dialog.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_bloc.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_event.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_state.dart';
import 'package:ocam_pos/presentation/employee/widgets/edit_employee_sheet.dart';

class EmployeeHRMScreen extends StatefulWidget {
  final EmployeeModel? employee;

  const EmployeeHRMScreen({super.key, this.employee});

  @override
  State<EmployeeHRMScreen> createState() => _EmployeeHRMScreenState();
}

class _EmployeeHRMScreenState extends State<EmployeeHRMScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Ekranda ko'rsatilayotgan xodim. Har build'da BLoC ro'yxatidan qayta
  /// olinadi — shu sababli tahrirlashdan keyin sahifa darhol yangilanadi
  /// (`initState`da bir marta nusxa olinsa, eski qiymat qotib qolardi).
  EmployeeModel? _currentEmployee;

  /// O'chirish so'ralganini eslab qolamiz: sahifa faqat amal muvaffaqiyatli
  /// tugagach yopiladi, xato bo'lsa ochiq qolib xabar ko'rsatadi.
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.employee;

    // Xodim uzatilmagan bo'lsa soxta "Administrator" profili ko'rsatilardi —
    // ilovada bunday xodim umuman mavjud emas edi. Endi rost holat
    // ko'rsatiladi.
    if (initial == null) return _buildNoEmployeeScreen(context);

    final employees = context.watch<EmployeeBloc>().state.employees;
    _currentEmployee = employees.firstWhere(
      (e) => e.id == initial.id,
      orElse: () => initial,
    );

    return BlocListener<EmployeeBloc, EmployeeState>(
      listenWhen: (previous, current) =>
          current.error != previous.error || current.actionMessage != null,
      listener: (context, state) {
        if (state.error != null) {
          setState(() => _isDeleting = false);
          AppSnackBar.error(context, state.error!);
        } else if (_isDeleting && state.actionMessage != null) {
          AppSnackBar.success(context, state.actionMessage!);
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Column(
          children: [_buildHeader(), _buildStatsGrid(), _buildTabSection()],
        ),
      ),
    );
  }

  Widget _buildNoEmployeeScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.forestDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Xodim profili',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildEmptyTabState(
        icon: Icons.badge_outlined,
        message: "Xodim tanlanmagan.\nRo'yxatdan xodimni tanlang.",
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final employee = _currentEmployee;
    if (employee == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: "Xodimni o'chirish",
      message:
          "\"${employee.name}\" o'chirilsinmi? Bu amalni ortga qaytarib "
          "bo'lmaydi.",
      confirmLabel: "Ha, o'chirish",
    );
    if (!confirmed || !context.mounted) return;

    setState(() => _isDeleting = true);
    context.read<EmployeeBloc>().add(DeleteEmployee(employee.id));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.forestDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Xodim profili',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          tooltip: "Tahrirlash",
          onPressed: () => showEditEmployeeSheet(context, _currentEmployee!),
          icon: const Icon(
            Icons.edit_note_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        IconButton(
          tooltip: "O'chirish",
          onPressed: () => _confirmDelete(context),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.forestDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildProfileImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentEmployee!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _employeeSubtitle(_currentEmployee!),
                      style: const TextStyle(
                        color: AppColors.mintLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLastCheckIn(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Hero(
      tag: _currentEmployee!.id,
      child: Container(
        width: 70,
        height: 70,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: _currentEmployee!.imageUrl.isNotEmpty
            ? Image.network(
                _currentEmployee!.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildInitialsFallback(),
              )
            : _buildInitialsFallback(),
      ),
    );
  }

  Widget _buildInitialsFallback() {
    return Center(
      child: Text(
        _currentEmployee!.name.isNotEmpty
            ? _currentEmployee!.name[0].toUpperCase()
            : "?",
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLastCheckIn() {
    return Row(
      children: [
        const Icon(
          Icons.access_time_filled_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Oxirgi kelgan vaqti: ${_currentEmployee!.lastCheckIn}',
          style: const TextStyle(color: AppColors.mintLight, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 2.2,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _StatCard(
            title: "Erta ketish",
            value: '${_currentEmployee!.earlyLeaves}',
            color: Colors.purple,
            icon: Icons.exit_to_app,
          ),
          _StatCard(
            title: 'Kelmagan',
            value: '${_currentEmployee!.absents}',
            color: Colors.redAccent,
            icon: Icons.person_off,
          ),
          _StatCard(
            title: 'Kelgan',
            value: '${_currentEmployee!.presentDays}',
            color: AppColors.primary,
            icon: Icons.how_to_reg,
          ),
          _StatCard(
            title: 'Kech qolgan',
            value: '${_currentEmployee!.lateIns}',
            color: Colors.orange,
            icon: Icons.timer_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          children: [
            const SizedBox(height: 25),
            _buildCustomTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildInfoTab(), _buildAttendanceContent()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.sage,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "Ma'lumot"),
          Tab(text: 'Davomat'),
        ],
      ),
    );
  }

  String _employeeSubtitle(EmployeeModel employee) {
    // Firestore hujjat id'si uzun bo'ladi, lekin qisqa id ham bo'lishi
    // mumkin — `substring(0, 5)` bunday holatda yiqilardi.
    final shortId = employee.id.length > 5
        ? '${employee.id.substring(0, 5)}...'
        : employee.id;
    return 'ID: $shortId | ${employee.role}';
  }

  /// "Ma'lumot" bo'limi — telefon, maosh va balans ilgari ilovaning
  /// hech bir ekranida ko'rinmasdi.
  Widget _buildInfoTab() {
    final employee = _currentEmployee!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      physics: const BouncingScrollPhysics(),
      children: [
        _InfoTile(
          icon: Icons.badge_outlined,
          label: "Lavozimi",
          value: employee.role.isEmpty ? "Ko'rsatilmagan" : employee.role,
        ),
        _InfoTile(
          icon: Icons.phone_outlined,
          label: "Telefon",
          value: employee.phone.isEmpty ? "Ko'rsatilmagan" : employee.phone,
        ),
        if (employee.altPhone.isNotEmpty)
          _InfoTile(
            icon: Icons.add_call,
            label: "Qo'shimcha telefon",
            value: employee.altPhone,
          ),
        _InfoTile(
          icon: Icons.payments_outlined,
          label: "Oylik maosh",
          value: AppFormat.money(employee.salary),
        ),
        _InfoTile(
          icon: Icons.account_balance_wallet_outlined,
          label: "Qo'lidagi balans",
          value: AppFormat.money(employee.balance),
        ),
        _InfoTile(
          icon: Icons.event_outlined,
          label: "Qo'shilgan sana",
          value: AppFormat.dateLong(employee.createdAt),
        ),
        if (employee.notes.isNotEmpty)
          _InfoTile(
            icon: Icons.edit_note_outlined,
            label: "Eslatma",
            value: employee.notes,
          ),
      ],
    );
  }

  Widget _buildAttendanceContent() {
    // Davomat (kelish/ketish) jurnali hali ishlab chiqilmagan — xuddi
    // faoliyat jurnali kabi, buni yozib borish mexanizmi loyihalanmagan.
    return _buildEmptyTabState(
      icon: Icons.event_busy_rounded,
      message: "Davomat ma'lumotlari hali mavjud emas",
    );
  }

  Widget _buildEmptyTabState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.mintMedium),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.sage, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final IconData icon;
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.forestLight,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.sage, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.forestDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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
