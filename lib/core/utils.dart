import 'package:aiflow/core/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void showErrorMessage(String? message) {
    Fluttertoast.showToast(
      msg: message ?? 'Something went wrong',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: AppTheme.red,
      textColor: AppTheme.white,
      fontSize: 16.0,
    );
  }

  static void showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: AppTheme.green,
      textColor: AppTheme.white,
      fontSize: 16.0,
    );
  }
}
