import 'package:flutter/material.dart';
import 'package:ocam_pos/core/widgets/base_sheet_wrapper.dart';
import 'package:ocam_pos/presentation/sale/widgets/payment_option_card.dart';

class PaymentMethod {
  final String id;
  final String title;
  final IconData icon;

  const PaymentMethod(this.id, this.title, this.icon);
}

const List<PaymentMethod> kPaymentMethods = [
  PaymentMethod('cash', "Naqd pul", Icons.payments_outlined),
  PaymentMethod('card', "Plastik karta", Icons.credit_card_outlined),
];

/// To'lov turini tanlash. Tanlangan `id` bilan yopiladi (`cash`/`card`).
Future<String?> showPaymentMethodSheet(
  BuildContext context, {
  required String current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentMethodSheet(current: current),
  );
}

class _PaymentMethodSheet extends StatefulWidget {
  final String current;
  const _PaymentMethodSheet({required this.current});

  @override
  State<_PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<_PaymentMethodSheet> {
  late String _selected = widget.current;

  @override
  Widget build(BuildContext context) {
    return BaseSheetWrapper(
      title: "To'lov turi",
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: kPaymentMethods
                  .map(
                    (method) => PaymentOptionCard(
                      id: method.id,
                      title: method.title,
                      subtitle: '',
                      icon: method.icon,
                      isSelected: _selected == method.id,
                      onTap: () => setState(() => _selected = method.id),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selected),
                child: const Text(
                  "Tanlash",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
