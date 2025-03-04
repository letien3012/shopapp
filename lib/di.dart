import 'package:get_it/get_it.dart';
import 'package:luanvan/services/user_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerSingleton<UserService>(UserService()); // Thêm UserService
}
