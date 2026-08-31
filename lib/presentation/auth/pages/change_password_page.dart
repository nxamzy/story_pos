import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/validators.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_event.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_state.dart';
import 'package:ocam_pos/presentation/auth/widgets/auth_text_field.dart';

/// Tizimga kirgan holatda parolni o'zgartirish.
///
/// Firebase joriy parol bilan qayta autentifikatsiyani talab qiladi
/// (`AuthRepository.changePassword`), shu sababli "Joriy parol" maydoni ham
/// bor — faqat yangisini emas.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      PasswordChangeRequested(
        currentPassword: _currentPassController.text,
        newPassword: _newPassController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              current.action != previous.action &&
              (current.action == AuthActionStatus.success || current.hasError),
          listener: (context, state) {
            if (state.hasError) {
              AppSnackBar.error(context, state.errorMessage!);
              context.read<AuthBloc>().add(const AuthMessageCleared());
            } else if (state.action == AuthActionStatus.success) {
              AppSnackBar.success(context, state.message!);
              context.read<AuthBloc>().add(const AuthMessageCleared());
              context.pop();
            }
          },
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildBackButton(context),
                  const SizedBox(height: 32),

                  const Text(
                    "Yangi parol",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Yangi parolingizni kiriting va uni unutmang",
                    style: TextStyle(fontSize: 15, color: AppColors.sage),
                  ),

                  const SizedBox(height: 40),

                  AuthTextField(
                    label: "Joriy parol",
                    hint: "Hozirgi parolingizni kiriting",
                    icon: Icons.lock_person_outlined,
                    controller: _currentPassController,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.required(v, "Joriy parol"),
                  ),

                  const SizedBox(height: 24),

                  AuthTextField(
                    label: "Yangi parol",
                    hint: "Yangi parolni kiriting",
                    icon: Icons.lock_open_rounded,
                    controller: _newPassController,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    validator: Validators.password,
                  ),

                  const SizedBox(height: 24),

                  AuthTextField(
                    label: "Yangi parolni tasdiqlang",
                    hint: "Parolni qayta kiriting",
                    icon: Icons.lock_outline,
                    controller: _confirmPassController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.confirmPassword(
                      v,
                      _newPassController.text,
                    ),
                    onFieldSubmitted: (_) => _submit(),
                  ),

                  const Spacer(),

                  _buildSubmitButton(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => context.pop(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mintLight),
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: state.isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: state.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Tasdiqlash",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
