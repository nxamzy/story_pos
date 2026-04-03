import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_bloc.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_event.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_state.dart';
import 'package:ocam_pos/presentation/widgets/signup_widget/back_button.dart';
import 'package:ocam_pos/presentation/widgets/signup_widget/social_button.dart';
import 'package:ocam_pos/presentation/widgets/signup_widget/text_field.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go(PlatformRoutes.homePage.route);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                AuthBackButton(
                  bg: AppColors.surface,
                  iconColor: AppColors.secondary,
                  onTap: () => context.pop(),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Make sure that you already have an account.",
                  style: TextStyle(fontSize: 14, color: AppColors.forestMedium),
                ),
                const SizedBox(height: 40),

                AuthTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "Enter your E-mail",
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 20),

                AuthTextField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "Enter your password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.push(PlatformRoutes.forgotPasswordPage.route),
                    child: const Text(
                      "forgot your password ?",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildDivider(),
                const SizedBox(height: 30),
                _buildSocialButtons(),
                const SizedBox(height: 60),
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
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.mintMedium)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Or",
            style: TextStyle(color: AppColors.sage, fontSize: 14),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.mintMedium)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        AuthSocialButton(type: "google"),
        SizedBox(width: 20),
        AuthSocialButton(type: "fb"),
      ],
    );
  }

  Widget _buildSignUpPrompt(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account ? ",
            style: TextStyle(color: AppColors.forestDark, fontSize: 14),
          ),
          GestureDetector(
            onTap: () => context.push(PlatformRoutes.signUpPage.route),
            child: const Text(
              "Sign up",
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
            onPressed: state is AuthLoading
                ? null
                : () {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    if (email.isNotEmpty && password.isNotEmpty) {
                      context.read<AuthBloc>().add(
                        SignInRequested(email, password),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Iltimos hamma qatorlarni to'ldiring!"),
                          backgroundColor: AppColors.emeraldBase,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: state is AuthLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Log in",
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
            "By using Our services agreeing to ",
            style: TextStyle(color: AppColors.forestMedium, fontSize: 12),
          ),
          Text(
            "Terms",
            style: TextStyle(color: AppColors.primary, fontSize: 12),
          ),
          Text(
            " and ",
            style: TextStyle(color: AppColors.forestMedium, fontSize: 12),
          ),
          Text(
            "Privacy Policy",
            style: TextStyle(color: AppColors.primary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
