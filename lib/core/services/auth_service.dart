import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/vendor_model.dart';
import '../../data/repositories/vendor_repository.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final VendorRepository _vendorRepository = VendorRepository();

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<VendorModel?> currentVendor = Rx<VendorModel?>(null);

  String? get currentVendorId => firebaseUser.value?.uid;

  Future<AuthService> init() async {
    // Listen to auth state changes
    firebaseUser.bindStream(_auth.authStateChanges());

    // Listen to vendor data changes when user is authenticated
    ever(firebaseUser, (User? user) {
      if (user != null) {
        _loadCurrentVendor(user.uid);
      } else {
        currentVendor.value = null;
      }
    });

    return this;
  }

  void _loadCurrentVendor(String vendorId) {
    _vendorRepository.watchVendor(vendorId).listen((vendor) {
      currentVendor.value = vendor;
    });
  }

  Future<bool> register({
    required String email,
    required String password,
    required String businessName,
    required String phone,
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Create vendor document with free plan
      final vendor = VendorModel(
        id: userCredential.user!.uid,
        email: email,
        businessName: businessName,
        phone: phone,
        plan: 'free',
        waveLimit: 5,
        productLimit: 10,
        createdAt: DateTime.now(),
      );

      await _vendorRepository.createVendor(vendor);

      Get.snackbar(
        'Succès',
        'Compte créé avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur lors de l\'inscription';
      if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible';
      } else if (e.code == 'email-already-in-use') {
        message = 'Cet email est déjà utilisé';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide';
      }
      Get.snackbar('Erreur', message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Get.snackbar(
        'Succès',
        'Connexion réussie',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur lors de la connexion';
      if (e.code == 'user-not-found') {
        message = 'Aucun utilisateur trouvé avec cet email';
      } else if (e.code == 'wrong-password') {
        message = 'Mot de passe incorrect';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide';
      }
      Get.snackbar('Erreur', message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.snackbar(
      'Déconnexion',
      'Vous avez été déconnecté',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  bool get isLoggedIn => firebaseUser.value != null;
}
