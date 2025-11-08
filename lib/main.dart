import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:aiflow/app/app.dart';

import 'package:aiflow/core/services/firebase/firebase_initializer.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
// ===== Chat DI =====
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aiflow/features/home/data/models/chat_message_model.dart';
import 'package:aiflow/features/home/data/datasources/chat_local_ds.dart';
import 'package:aiflow/features/home/data/datasources/chat_remote_ds.dart';
import 'package:aiflow/features/home/data/repositories/chat_repository_impl.dart';
import 'package:aiflow/features/home/domain/repositories/chat_repository.dart';

// ===== Auth imports (yours) =====
import 'package:aiflow/features/auth/data/datasources/firebase_auth_datasource_impl.dart';
import 'package:aiflow/features/auth/data/repository/auth_repository_impl.dart';
import 'package:aiflow/features/auth/domain/usecases/sign_in.dart';
import 'package:aiflow/features/auth/domain/usecases/sign_up.dart';
import 'package:aiflow/features/auth/domain/usecases/sign_out.dart';
import 'package:aiflow/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:aiflow/features/auth/domain/usecases/current_user.dart';
import 'package:aiflow/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';

// Supabase (yours)
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase + Supabase (yours)
  await FirebaseInitializer.init();
  await Supabase.initialize(
    url: 'https://fiqzbqwxfhpktphpyuxw.supabase.co',
    anonKey: '...your anon key...', // keep as you had
  );

  // ===== Chat storage (Hive) =====
  await Hive.initFlutter();
  Hive.registerAdapter(ChatMessageModelAdapter());
  final chatBox = await Hive.openBox<ChatMessageModel>('chat_box');

  // ===== Auth DI (yours) =====
  final firebaseAuthDS = FirebaseAuthDataSourceImpl();
  final authRepo = AuthRepositoryImpl(firebaseAuthDS);
  final signInWithGoogle = SignInWithGoogle(authRepo);
  final signIn = SignIn(authRepo);
  final signUp = SignUp(authRepo);
  final signOut = SignOut(authRepo);
  final watchAuthState = WatchAuthState(authRepo);
  final currentUser = CurrentUser(authRepo);

  // ===== Chat DI =====
  // IMPORTANT: point to your proxy (Worker/Express) that streams SSE.
  // Do NOT put an OpenAI key in the app.
  const chatProxyUrl = 'https://aiflow-worker.aiflowworker.workers.dev';

  final chatRepo = ChatRepositoryImpl(
    remote: ChatRemoteDS(baseUrl: chatProxyUrl),
    local: ChatLocalDS(chatBox),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final p = AuthProvider(
              signIn,
              signUp,
              signOut,
              watchAuthState,
              currentUser,
              signInWithGoogle,
            );
            p.init();
            return p;
          },
        ),
        // Provide ChatRepository to the whole app
        Provider<ChatRepository>.value(value: chatRepo),
      ],
      child: const AiFlow(),
    ),
  );
}
