import 'package:dalili/core/network/dio_client.dart';
import 'package:dalili/features/library/data/datasources/library_remote_datasource.dart';
import 'package:dalili/features/library/data/repositories/library_repository_impl.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/book_detail/book_detail_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/department/department_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/scanner/scanner_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/search/search_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // AppSettingsCubit first — DioClient's _LangInterceptor depends on it
  sl.registerLazySingleton<AppSettingsCubit>(() => AppSettingsCubit());

  // Network
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Data sources
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(sl()),
  );

  // Singleton cubits
  sl.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(sl<LibraryRepository>(), sl<AppSettingsCubit>()),
  );

  // Factory cubits — new instance per screen push
  sl.registerFactory<DepartmentCubit>(
    () => DepartmentCubit(sl()),
  );
  sl.registerFactory<SearchCubit>(
    () => SearchCubit(sl()),
  );
  sl.registerFactory<ScannerCubit>(
    () => ScannerCubit(sl()),
  );
  sl.registerFactory<BookDetailCubit>(
    () => BookDetailCubit(),
  );
}
