import 'package:aiflow/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
