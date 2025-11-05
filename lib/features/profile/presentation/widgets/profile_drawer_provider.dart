import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:aiflow/core/services/firebase/firebase_refs.dart';
import 'package:aiflow/core/services/image_picker/image_picker_service.dart';
import 'package:aiflow/features/profile/data/datasources/profile_remote_ds.dart';
import 'package:aiflow/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:aiflow/features/profile/domain/usecases/watch_profile.dart';
import 'package:aiflow/features/profile/domain/usecases/rename_user.dart';
import 'package:aiflow/features/profile/domain/usecases/change_password.dart';
import 'package:aiflow/features/profile/presentation/controllers/profile_controller.dart';
import 'package:aiflow/features/profile/presentation/provider/profile_provider.dart';
import 'package:aiflow/features/profile/data/storage/supabase_avatar_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_drawer.dart';

class ProfileDrawerProvider extends StatelessWidget {
  const ProfileDrawerProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // data layer
    final ds = ProfileRemoteDs(FirebaseRefs.auth, FirebaseRefs.users);
    final repo = ProfileRepositoryImpl(ds);

    // core services
    final picker = ImagePickerService();
    final storage = SupabaseAvatarStorage(Supabase.instance.client);

    // controller
    final controller = ProfileController(
      FirebaseRefs.auth,
      repo,
      picker,
      storage,
    );

    // usecases
    final watch = WatchProfile(repo);
    final rename = RenameUser(repo);
    final changePwd = ChangePassword(repo);

    return ChangeNotifierProvider(
      create: (_) =>
          ProfileProvider(watch, rename, changePwd, controller)..init(),
      child: const AppDrawer(),
    );
  }
}
