import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskly/core/widgets/button_widget.dart';
import 'package:taskly/core/widgets/logo_widget.dart';
import 'package:taskly/core/widgets/text_field_widget.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_event.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_state.dart';
import 'package:taskly/features/auth/presentation/view/components/link_row_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is AuthAuthenticated) {
                  context.go('/');
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LogoWidget(
                      fontSize: 68,
                      subtitle: 'Organize your days',
                    ),
                    TextFieldWidget(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextFieldWidget(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    if (state is AuthLoading)
                      const CircularProgressIndicator()
                    else
                      ButtonWidget(
                        text: 'Sign In',
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            AuthLoginEvent(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    LinkRowWidget(
                      mainText: 'Don\'t have an account? ',
                      linkText: 'Register now!',
                      route: '/register',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
