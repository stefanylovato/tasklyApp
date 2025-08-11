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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email (e.g., user@domain.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    if (value.trim() != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LogoWidget(
                          fontSize: 68,
                          subtitle: 'Register below',
                        ),
                        TextFieldWidget(
                          controller: _nameController,
                          hintText: 'Name',
                          validator: _validateName,
                        ),
                        const SizedBox(height: 10),
                        TextFieldWidget(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 10),
                        TextFieldWidget(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 10),
                        TextFieldWidget(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm password',
                          obscureText: true,
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: 10),
                        if (state is AuthLoading)
                          const CircularProgressIndicator()
                        else
                          ButtonWidget(
                            text: 'Sign Up',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  AuthRegisterEvent(
                                    _nameController.text.trim(),
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please correct the errors in the form',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        const SizedBox(height: 20),
                        LinkRowWidget(
                          mainText: 'I\'m already a member. ',
                          linkText: 'Login now!',
                          route: '/login',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
