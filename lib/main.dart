import 'package:aiflow/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aiflow/app/app.dart';
import 'package:aiflow/core/services/firebase/firebase_initializer.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:aiflow/features/auth/data/datasources/firebase_auth_datasource_impl.dart';
import 'package:aiflow/features/auth/data/repository/auth_repository_impl.dart';
import 'package:aiflow/features/auth/domain/usecases/sign_in.dart';
import 'package:aiflow/features/auth/domain/usecases/sign_up.dart';
import 'package:aiflow/features/auth/domain/usecases/sign_out.dart';
import 'package:aiflow/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:aiflow/features/auth/domain/usecases/current_user.dart';
import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.init();
  await Supabase.initialize(
    url: 'https://fiqzbqwxfhpktphpyuxw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpcXpicXd4Zmhwa3RwaHB5dXh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNjc3MDcsImV4cCI6MjA3Nzg0MzcwN30.rJCTsjOff6bMgwVvJb6Z7DNJrEDiKFsn2QbrYlT-qBg',
  );

  // DI
  final FirebaseAuthDataSourceImpl dataSource = FirebaseAuthDataSourceImpl();
  final AuthRepositoryImpl repo = AuthRepositoryImpl(dataSource);
  final SignInWithGoogle signInWithGoogle = SignInWithGoogle(repo);

  final SignIn signIn = SignIn(repo);
  final SignUp signUp = SignUp(repo);
  final SignOut signOut = SignOut(repo);
  final WatchAuthState watchAuthState = WatchAuthState(repo);
  final CurrentUser currentUser = CurrentUser(repo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // ChangeNotifierProvider(
        //   create: (_) => HomeResizeProvider(ImageRepository()),
        // ),
        ChangeNotifierProvider(
          create: (_) {
            final AuthProvider authProvider = AuthProvider(
              signIn,
              signUp,
              signOut,
              watchAuthState,
              currentUser,
              signInWithGoogle,
            );
            authProvider.init();
            return authProvider;
          },
        ),
      ],
      child: const AiFlow(),
    ),
  );
}
