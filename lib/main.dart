import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/core/config/router.dart';
import 'package:taskly/features/auth/data/repository/auth_repository_impl.dart';
import 'package:taskly/features/auth/domain/usecases/usecases_implementations/login_usecase.dart';
import 'package:taskly/features/auth/domain/usecases/usecases_implementations/logout_usecase.dart';
import 'package:taskly/features/auth/domain/usecases/usecases_implementations/persist_login_usecase.dart';
import 'package:taskly/features/auth/domain/usecases/usecases_implementations/register_usecase.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_event.dart';
import 'package:taskly/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_implementation/create_category_usecase.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_implementation/create_task_usecase.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_implementation/delete_category_usecase.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_implementation/delete_task_usecase.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_implementation/get_category_usecase.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_implementation/get_tasks_usecase.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_implementation/update_category_usecase.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_implementation/update_task_usecase.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_implementation/upload_media_usecase.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_bloc.dart';
import 'package:taskly/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TasklyApp());
}

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            login: Login(AuthRepositoryImpl()),
            register: Register(AuthRepositoryImpl()),
            logout: Logout(AuthRepositoryImpl()),
            persistLogin: PersistLogin(AuthRepositoryImpl()),
          )..add(AuthCheckStatusEvent()),
        ),
        BlocProvider(
          create: (context) => TaskBloc(
            createTask: CreateTask(TaskRepositoryImpl()),
            getTasks: GetTasks(TaskRepositoryImpl()),
            updateTask: UpdateTask(TaskRepositoryImpl()),
            deleteTask: DeleteTask(TaskRepositoryImpl()),
            createCategory: CreateCategory(TaskRepositoryImpl()),
            getCategories: GetCategories(TaskRepositoryImpl()),
            updateCategory: UpdateCategory(TaskRepositoryImpl()),
            deleteCategory: DeleteCategory(TaskRepositoryImpl()),
            uploadMedia: UploadMedia(TaskRepositoryImpl()),
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: 'Taskly',
        theme: ThemeData(primarySwatch: Colors.orange),
      ),
    );
  }
}
