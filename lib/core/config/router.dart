import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_state.dart';
import 'package:taskly/features/auth/presentation/view/login_page.dart';
import 'package:taskly/features/auth/presentation/view/register_page.dart';
import 'package:taskly/features/home/presentation/home_page.dart';
import 'package:taskly/features/tasks/presentation/view/category_management_page.dart';
import 'package:taskly/features/tasks/presentation/view/task_creation_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/task-creation',
      builder: (context, state) => const TaskCreationPage(),
    ),
    GoRoute(
      path: '/task-creation/:taskId',
      builder: (context, state) =>
          TaskCreationPage(taskId: state.pathParameters['taskId']),
    ),
    GoRoute(
      path: '/category-management',
      builder: (context, state) => const CategoryManagementPage(),
    ),
  ],
  redirect: (context, state) {
    final authBloc = context.read<AuthBloc>();
    final isAuthenticated = authBloc.state is AuthAuthenticated;

    if (state.matchedLocation == '/login' && isAuthenticated) {
      return '/';
    }
    if (!isAuthenticated &&
        state.matchedLocation != '/login' &&
        state.matchedLocation != '/register') {
      return '/login';
    }
    return null;
  },
);
