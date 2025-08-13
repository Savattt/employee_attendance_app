import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
// Correct import for AuthWrapper

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  var user = Rxn<User>();
  var userModel = Rxn<UserModel>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isCreatingUser =
      false.obs; // Flag to prevent auth state changes during user creation

  @override
  void onInit() {
    print('=== AuthController onInit START ===');
    print('AuthController onInit: currentUser = ${AuthService().currentUser}');
    user.value = AuthService().currentUser;

    // Set loading to true initially
    isLoading.value = true;
    print('AuthController: isLoading set to true');

    // Fetch user model and set loading to false when done
    _fetchUserModel(user.value).then((_) {
      print(
          'AuthController: _fetchUserModel completed, setting isLoading to false');
      isLoading.value = false;
    }).catchError((error) {
      print('Error fetching user model: $error');
      isLoading.value = false;
    });

    AuthService().authStateChanges.listen((u) {
      // Skip auth state changes if we're creating a user
      if (isCreatingUser.value) {
        print('Skipping auth state change during user creation');
        return;
      }

      print('authStateChanges fired: user = ${u?.email}');
      user.value = u;
      if (u != null) {
        isLoading.value = true;
        _fetchUserModel(u).then((_) {
          isLoading.value = false;
        }).catchError((error) {
          print('Error fetching user model on auth change: $error');
          isLoading.value = false;
        });
      } else {
        userModel.value = null;
        isLoading.value = false;
      }
    });
    super.onInit();
    print('=== AuthController onInit END ===');
  }

  Future<void> _fetchUserModel(User? firebaseUser) async {
    print('=== _fetchUserModel START ===');
    print('_fetchUserModel called with user: ${firebaseUser?.email}');
    if (firebaseUser != null) {
      userModel.value = await AuthService().getUserData(firebaseUser.uid);
      print('Fetched userModel: role = ${userModel.value?.role}');
    } else {
      userModel.value = null;
    }
    print('=== _fetchUserModel END ===');
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('Attempting sign in for: $email');
      await AuthService().signIn(email, password);
      print('Sign in successful');
      // Fetch user model and update listeners
      user.value = AuthService().currentUser;
      await _fetchUserModel(user.value);
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
    try {
      print('AuthController: Starting sign out process');
      await AuthService().signOut();
      print('AuthController: Sign out completed');

      // Clear user data
      user.value = null;
      userModel.value = null;

      print('AuthController: User data cleared');
    } catch (e) {
      print('AuthController: Error during sign out: $e');
    }
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

  /// Force refresh user model - useful for initial loading issues
  Future<void> refreshUserModel() async {
    if (user.value != null) {
      userModel.value = await AuthService().getUserData(user.value!.uid);
      update();
    }
  }
}
