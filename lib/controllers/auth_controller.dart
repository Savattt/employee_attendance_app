import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  var user = Rxn<User>();
  var userModel = Rxn<UserModel>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    print('AuthController onInit: currentUser = ${AuthService().currentUser}');
    user.value = AuthService().currentUser;
    _fetchUserModel(user.value);
    AuthService().authStateChanges.listen((u) {
      print('authStateChanges fired: user = ${u?.email}');
      user.value = u;
      _fetchUserModel(u);
    });
    super.onInit();
  }

  Future<void> _fetchUserModel(User? firebaseUser) async {
    if (firebaseUser != null) {
      userModel.value = await AuthService().getUserData(firebaseUser.uid);
      print('Fetched userModel: role = ${userModel.value?.role}');
    } else {
      userModel.value = null;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('Attempting sign in for: $email');
      await AuthService().signIn(email, password);
      print('Sign in successful');
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      errorMessage.value = e.message ?? 'Sign in failed';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await AuthService().signUp(email, password);
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'Sign up failed';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await AuthService().signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await AuthService().sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'Password reset failed';
    } finally {
      isLoading.value = false;
    }
  }
}
