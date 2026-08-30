import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_event.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';

void showDeleteProduct(BuildContext context, ProductModel product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ProductBloc>(),
      child: DeleteProductSheet(product: product),
    ),
  );
}

class DeleteProductSheet extends StatefulWidget {
  final ProductModel product;

  const DeleteProductSheet({super.key, required this.product});

  @override
  State<DeleteProductSheet> createState() => _DeleteProductSheetState();
}

class _DeleteProductSheetState extends State<DeleteProductSheet> {
  bool isChecked = false;
  bool _isDeleting = false;

  void _deleteProduct() {
    setState(() => _isDeleting = true);
    context.read<ProductBloc>().add(DeleteProduct(widget.product.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (previous, current) =>
          current.actionMessage != null || current.error != null,
      listener: (context, state) {
        if (state.error != null) {
          setState(() => _isDeleting = false);
          AppSnackBar.error(context, state.error!);
        } else if (state.actionMessage != null) {
          AppSnackBar.success(context, state.actionMessage!);
          // Tafsilot sahifasidan ochilgan bo'lardi — sheet va o'sha sahifani
          // birga yopamiz, chunki mahsulot endi mavjud emas.
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandleBar(),
              const SizedBox(height: 24),

              _buildIcon(),
              const SizedBox(height: 24),

              Text(
                "\"${widget.product.name}\" o'chirilsinmi?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Bu amalni ortga qaytarib bo'lmaydi. Mahsulot omboringizdan butunlay o'chiriladi.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.sage,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              _buildCheckboxTile(),

              const SizedBox(height: 32),

              _buildDeleteButton(),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Yo'q, saqlab qolish",
                  style: TextStyle(
                    color: AppColors.sage,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.delete_forever_rounded,
        size: 54,
        color: AppColors.error,
      ),
    );
  }

  Widget _buildCheckboxTile() {
    return InkWell(
      onTap: () => setState(() => isChecked = !isChecked),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isChecked
              ? AppColors.error.withValues(alpha: 0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked
                ? AppColors.error.withValues(alpha: 0.3)
                : AppColors.mintLight,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isChecked ? AppColors.error : Colors.transparent,
                border: Border.all(
                  color: isChecked ? AppColors.error : AppColors.mintMedium,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                "Tushunaman, bu mahsulotni o'chiraman",
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: (isChecked && !_isDeleting) ? _deleteProduct : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.background,
          disabledForegroundColor: AppColors.mintMedium,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isDeleting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Ha, butunlay o'chirish",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: 45,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.mintMedium.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
