import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/employee_model.dart';

class AttendanceRecord {
  final IconData icon;
  final String title, time, status;
  final Color color;
  AttendanceRecord({
    required this.icon,
    required this.title,
    required this.time,
    required this.status,
    required this.color,
  });
}

class EmployeeHRMScreen extends StatefulWidget {
  final EmployeeModel? employee;

  const EmployeeHRMScreen({super.key, this.employee});

  @override
  State<EmployeeHRMScreen> createState() => _EmployeeHRMScreenState();
}

class _EmployeeHRMScreenState extends State<EmployeeHRMScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late EmployeeModel _currentEmployee;

  final List<AttendanceRecord> attendanceList = [
    AttendanceRecord(
      icon: Icons.login_rounded,
      title: 'Kelish',
      time: '09:41 AM',
      status: 'Vaqtida',
      color: AppColors.primary,
    ),
    AttendanceRecord(
      icon: Icons.coffee_rounded,
      title: 'Tanaffus',
      time: '12:30 PM',
      status: 'Vaqtida',
      color: Colors.orange,
    ),
    AttendanceRecord(
      icon: Icons.logout_rounded,
      title: 'Ketish',
      time: '04:00 PM',
      status: "Erta",
      color: Colors.redAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _currentEmployee =
        widget.employee ??
        EmployeeModel(
          id: "ID-0001",
          name: "Administrator",
          role: "Do'kon egasi",
          phone: "+998 00 000 00 00",
          imageUrl: "",
          salary: 0.0,
          lastCheckIn: "Kelmagan",
          earlyLeaves: 0,
          absents: 0,
          presentDays: 0,
          lateIns: 0,
          createdAt: DateTime.now(),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [_buildHeader(), _buildStatsGrid(), _buildTabSection()],
      ),
    );
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
          onPressed: () => AppSnackBar.info(context, "Tez orada qo'shiladi"),
          icon: const Icon(
            Icons.edit_note_rounded,
            color: AppColors.primary,
            size: 28,
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
                      _currentEmployee.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${_currentEmployee.id.substring(0, 5)}... | ${_currentEmployee.role}',
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
      tag: _currentEmployee.id,
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
        child: _currentEmployee.imageUrl.isNotEmpty
            ? Image.network(
                _currentEmployee.imageUrl,
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
        _currentEmployee.name.isNotEmpty
            ? _currentEmployee.name[0].toUpperCase()
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
          'Last check in : ${_currentEmployee.lastCheckIn}',
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
            value: '${_currentEmployee.earlyLeaves}',
            color: Colors.purple,
            icon: Icons.exit_to_app,
          ),
          _StatCard(
            title: 'Kelmagan',
            value: '${_currentEmployee.absents}',
            color: Colors.redAccent,
            icon: Icons.person_off,
          ),
          _StatCard(
            title: 'Kelgan',
            value: '${_currentEmployee.presentDays}',
            color: AppColors.primary,
            icon: Icons.how_to_reg,
          ),
          _StatCard(
            title: 'Kech qolgan',
            value: '${_currentEmployee.lateIns}',
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
                children: [_buildActivityList(), _buildAttendanceContent()],
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
          Tab(text: 'Faoliyat'),
          Tab(text: 'Davomat'),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.background,
            child: Icon(Icons.history, color: AppColors.primary),
          ),
          title: Text("Action #${index + 101}"),
          subtitle: Text("Completed by ${_currentEmployee.name.split(' ')[0]}"),
          trailing: const Icon(Icons.chevron_right, color: AppColors.sage),
        ),
      ),
    );
  }

  Widget _buildAttendanceContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildMiniCalendar(),
        const SizedBox(height: 25),
        ...attendanceList.map((item) => _AttendanceTile(record: item)),
      ],
    );
  }

  Widget _buildMiniCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "March 2026",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              7,
              (i) => _CalendarDay(
                day: "${10 + i}",
                label: i == 3 ? "Pay" : "Kun",
                isSelected: i == 3,
              ),
            ),
          ),
        ],
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

class _AttendanceTile extends StatelessWidget {
  final AttendanceRecord record;
  const _AttendanceTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: record.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(record.icon, color: record.color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  record.time,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: record.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              record.status,
              style: TextStyle(
                color: record.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final String day, label;
  final bool isSelected;
  const _CalendarDay({
    required this.day,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.sage),
        ),
        const SizedBox(height: 8),
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.forestDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
