import 'package:employee_management/application/auth/auth_bloc.dart';
import 'package:employee_management/application/employee/employee_bloc.dart';
import 'package:employee_management/application/theme/theme_bloc.dart';
import 'package:employee_management/infrastructure/auth/data_source/auth_remote.dart';
import 'package:employee_management/infrastructure/auth/repository/auth_repository.dart';
import 'package:employee_management/infrastructure/core/http/http_service.dart';
import 'package:employee_management/infrastructure/core/local_storage/shared_prefs_service.dart';
import 'package:employee_management/infrastructure/employee/data_source/employee_local.dart';
import 'package:employee_management/infrastructure/employee/data_source/employee_remote.dart';
import 'package:employee_management/infrastructure/employee/repository/employee_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  final sharedPrefsService = SharedPrefsService();
  await sharedPrefsService.init();
  locator.registerLazySingleton(() => sharedPrefsService);
  locator.registerLazySingleton(() => HttpService());

  locator.registerLazySingleton(() => FirebaseAuth.instance);
  locator.registerLazySingleton(() => GoogleSignIn());

  locator.registerLazySingleton(
    () => AuthRemoteDataSource(
      firebaseAuth: locator<FirebaseAuth>(),
      googleSignIn: locator<GoogleSignIn>(),
    ),
  );
  locator.registerLazySingleton(
    () => AuthRepository(remoteDataSource: locator<AuthRemoteDataSource>()),
  );
  locator.registerLazySingleton(
    () => AuthBloc(authRepository: locator<AuthRepository>()),
  );

  locator.registerLazySingleton(
    () => EmployeeRemoteDataSource(httpService: locator<HttpService>()),
  );
  locator.registerLazySingleton(
    () => EmployeeLocalDataSource(sharedPrefsService: locator<SharedPrefsService>()),
  );
  locator.registerLazySingleton(
    () => EmployeeRepository(
      remoteDataSource: locator<EmployeeRemoteDataSource>(),
      localDataSource: locator<EmployeeLocalDataSource>(),
    ),
  );
  locator.registerLazySingleton(
    () => EmployeeBloc(repository: locator<EmployeeRepository>()),
  );

  locator.registerLazySingleton(
    () => ThemeBloc(sharedPrefsService: locator<SharedPrefsService>()),
  );
}
