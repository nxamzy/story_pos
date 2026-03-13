import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_bloc.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_event.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_state.dart'; // State-larni taniy olishi uchun
import 'package:ocam_pos/presentation/widgets/signup_widget/back_button.dart';
import 'package:ocam_pos/presentation/widgets/signup_widget/social_button.dart';
import 'package:ocam_pos/presentation/widgets/signup_widget/text_field.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 1. Controllerlar (Intizom!)
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isChecked = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // 2. BlocListener orqali navigatsiyani boshqaramiz
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              // Muvaffaqiyatli o'tsa - Home-ga marsh!
              context.go(PlatformRoutes.homePage.route);
            }
          },
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
                  "Sign up",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Experience the power of advanced technology",
                  style: TextStyle(fontSize: 14, color: AppColors.forestMedium),
                ),
                const SizedBox(height: 32),

                // 3. Xatolarni ko'rsatish bloki (SnackBar-siz!)
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthError) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.message,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                AuthTextField(
                  controller: _firstNameController, // Controller ulandi
                  label: "Full Name",
                  hint: "Enter your full name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: "Email",
                  hint: "Emailni kiriting",
                  icon: Icons.email,
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: "Parol",
                  hint: "Parolni kiriting",
                  icon: Icons.lock,
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: isChecked,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => isChecked = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "I accept all terms & conditions.",
                      style: TextStyle(
                        color: AppColors.emeraldMedium,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildSocialButtons(),
                const SizedBox(height: 32),

                // 4. Sign Up Button (Loading holati bilan)
                _buildSignUpButton(),

                const SizedBox(height: 20),
                _buildLoginPrompt(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Yordamchi metodlar ---

  Widget _buildSignUpButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state is AuthLoading
                ? null // Yuklanayotganda tugmani o'chirib qo'yamiz
                : () {
                    context.read<AuthBloc>().add(
                      SignUpRequested(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _firstNameController.text.trim(),
                        "", // Bloc lastName so'rasa, hozircha bo'sh yuboramiz
                      ),
                    );
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
                    "Sign up",
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

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.forestMedium, fontSize: 14),
          children: [
            const TextSpan(text: "Already have an account? "),
            TextSpan(
              text: "Log in",
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
