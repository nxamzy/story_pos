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
import 'package:ocam_pos/presentation/auth/widgets/auth_text_field.dart';
import 'package:ocam_pos/core/navigation/nav_extensions.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      SignInRequested(_emailController.text.trim(), _passwordController.text),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  AuthBackButton(
                    bg: AppColors.surface,
                    iconColor: AppColors.secondary,
                    // Tizimdan chiqqandan keyin login sahifasi stack ildizi
                    // bo'lib qoladi — bunda oddiy `pop()` xato beradi.
                    onTap: () =>
                        context.popOrGo(PlatformRoutes.firstPage.route),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Tizimga kirish",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hisobingiz mavjudligiga ishonch hosil qiling.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.forestMedium,
                    ),
                  ),
                  const SizedBox(height: 40),

                  AuthTextField(
                    controller: _emailController,
                    label: "Email",
                    hint: "Emailingizni kiriting",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),

                  const SizedBox(height: 20),

                  AuthTextField(
                    controller: _passwordController,
                    label: "Parol",
                    hint: "Parolingizni kiriting",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.required(v, "Parol"),
                    onFieldSubmitted: (_) => _submit(),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          context.push(PlatformRoutes.forgotPasswordPage.route),
                      child: const Text(
                        "Parolni unutdingizmi?",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildSignUpPrompt(context),
                  const SizedBox(height: 16),

                  _buildLoginButton(),

                  const SizedBox(height: 16),
                  _buildTermsInfo(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Hisobingiz yo'qmi? ",
            style: TextStyle(color: AppColors.forestDark, fontSize: 14),
          ),
          GestureDetector(
            onTap: () => context.push(PlatformRoutes.signUpPage.route),
            child: const Text(
              "Ro'yxatdan o'tish",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
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
                    "Kirish",
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

  Widget _buildTermsInfo() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: const [
          Text(
            "Xizmatlarimizdan foydalanish orqali siz ",
            style: TextStyle(color: AppColors.forestMedium, fontSize: 12),
          ),
          Text(
            "Foydalanish shartlari",
            style: TextStyle(color: AppColors.primary, fontSize: 12),
          ),
          Text(
            " va ",
            style: TextStyle(color: AppColors.forestMedium, fontSize: 12),
          ),
          Text(
            "Maxfiylik siyosati",
            style: TextStyle(color: AppColors.primary, fontSize: 12),
          ),
          Text(
            "ga rozilik bildirasiz.",
            style: TextStyle(color: AppColors.forestMedium, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
