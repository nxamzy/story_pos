import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/validators.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_event.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_state.dart';
import 'package:ocam_pos/presentation/auth/widgets/auth_back_button.dart';
import 'package:ocam_pos/presentation/auth/widgets/social_button.dart';
import 'package:ocam_pos/presentation/auth/widgets/auth_text_field.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _acceptedTerms = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      AppSnackBar.error(context, "Foydalanish shartlarini qabul qiling");
      return;
    }

    final parts = _fullNameController.text.trim().split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    context.read<AuthBloc>().add(
      SignUpRequested(
        _emailController.text.trim(),
        _passwordController.text,
        firstName,
        lastName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              current.isAuthenticated || current.hasError,
          listener: (context, state) {
            if (state.isAuthenticated) {
              context.go(PlatformRoutes.homePage.route);
            } else if (state.hasError) {
              AppSnackBar.error(context, state.errorMessage!);
              context.read<AuthBloc>().add(const AuthMessageCleared());
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  AuthBackButton(
                    bg: AppColors.surface,
                    iconColor: AppColors.secondary,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Ro'yxatdan o'tish",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Do'koningizni boshqarishni hoziroq boshlang.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.forestMedium,
                    ),
                  ),
                  const SizedBox(height: 32),

                  AuthTextField(
                    controller: _fullNameController,
                    label: "To'liq ism",
                    hint: "Ismingizni kiriting",
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.required(v, "Ism"),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: "Email",
                    hint: "Emailni kiriting",
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: "Parol",
                    hint: "Parolni kiriting",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _acceptedTerms,
                          activeColor: AppColors.primary,
                          onChanged: (val) =>
                              setState(() => _acceptedTerms = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Foydalanish shartlarini qabul qilaman.",
                          style: TextStyle(
                            color: AppColors.emeraldMedium,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSocialButtons(),
                  const SizedBox(height: 32),

                  _buildSignUpButton(),

                  const SizedBox(height: 20),
                  _buildLoginPrompt(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
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
                    "Ro'yxatdan o'tish",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.mintMedium)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "yoki",
            style: TextStyle(color: AppColors.sage, fontSize: 14),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.mintMedium)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AuthSocialButton(type: "google"),
        SizedBox(width: 20),
        AuthSocialButton(type: "fb"),
      ],
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.forestMedium, fontSize: 14),
          children: [
            const TextSpan(text: "Hisobingiz bormi? "),
            TextSpan(
              text: "Kirish",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push(PlatformRoutes.loginPage.route),
            ),
          ],
        ),
      ),
    );
  }
}
