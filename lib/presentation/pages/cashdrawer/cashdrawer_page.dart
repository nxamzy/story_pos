import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart'; // AppColors tizimi
import 'package:ocam_pos/presentation/pages/cashdrawer/widgets/cash_main_menu_widget.dart';
import 'package:ocam_pos/presentation/pages/cashdrawer/widgets/transfer_widget.dart';
import 'package:ocam_pos/presentation/pages/cashdrawer/widgets/transferm_button_widget.dart';

class CashDrawerPage extends StatefulWidget {
  const CashDrawerPage({super.key});

  @override
  State<CashDrawerPage> createState() => _CashDrawerPageState();
}

class _CashDrawerPageState extends State<CashDrawerPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // resizeToAvoidBottomInset: true — klaviatura chiqqanda TextField yopilib qolmasligi uchun
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background, // Markazlashgan fon rangi
        body: Column(
          children: const [
            // 1. Asosiy Menyu (Kassa holati, balans va h.k.)
            CashMainMenuWidget(),

            SizedBox(
              height: 24,
            ), // Standart masofa (AppColors.mintLight bilan mos)
            // 2. Pul o'tkazish/kiritish uchun TextField-lar (TransferWidget)
            // Bu vidjet ichida AppColors.primary va AppColors.mintLight ishlatilganiga ishonch hosil qil
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TransferWidget(),
            ),

            Spacer(), // Tugmani pastga surish uchun
            // 3. Tasdiqlash tugmasi (Transfer Button)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TransfermButtonWidget(),
            ),

            SizedBox(height: 30), // Pastdan chiroyli masofa
          ],
        ),
      ),
    );
  }
}
