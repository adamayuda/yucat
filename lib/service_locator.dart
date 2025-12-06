import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/features/auth/data/repository/auth_repository_impl.dart';
import 'package:yucat/features/auth/data/sources/auth_data_source.dart';
import 'package:yucat/features/auth/domain/repository/auth_repository.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/signin_anonymously_usecase.dart';
import 'package:yucat/features/cat/data/datasources/cat_datasource.dart';
import 'package:yucat/features/cat/data/mappers/cat_document_mapper.dart';
import 'package:yucat/features/cat/data/repositories/cat_repository_impl.dart';
import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';
import 'package:yucat/features/cat/domain/usecases/create_cat_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/cat_create/presentation/bloc/cat_create_bloc.dart';
import 'package:yucat/features/cat_create/presentation/mappers/cat_model_to_entity_mapper.dart';
import 'package:yucat/features/cat_listing/presentation/bloc/cat_listing_bloc.dart';
import 'package:yucat/features/cat_listing/presentation/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:yucat/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:yucat/features/profile/bloc/profile_bloc.dart';
import 'package:yucat/features/search/data/datasources/algolia_search_datasource.dart';
import 'package:yucat/features/search/data/mappers/product_to_domain_mapper.dart';
import 'package:yucat/features/search/data/repositories/search_repository.dart';
import 'package:yucat/features/search/domain/repositories/search_repository.dart';
import 'package:yucat/features/search/domain/usecases/search_by_barcode_usecase.dart';
import 'package:yucat/features/search/domain/usecases/search_by_query_usecase.dart';
import 'package:yucat/features/search/presentation/bloc/search_bloc.dart';
import 'package:yucat/features/search/presentation/mappers/product_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/services/scan_tracking_service.dart';
import 'package:yucat/services/cat_tracking_service.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await _registerSharedPreferences();
  await _registerDio();
  await _registerDataSources();
  await _registerMappers();
  await _registerRepositories();
  await _registerUseCases();
  await _registerServices();
  await _registerBlocs();
}

Future<void> _registerSharedPreferences() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
}

Future<void> _registerDio() async {
  sl.registerSingleton<Dio>(Dio());
}

Future<void> _registerDataSources() async {
  sl.registerSingleton<AlgoliaSearchDataSource>(AlgoliaSearchDataSource());
  sl.registerSingleton<AuthFirebaseDataSource>(AuthFirebaseDataSource());
  sl.registerSingleton<CatDataSource>(
    CatDataSource(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    ),
  );
}

Future<void> _registerMappers() async {
  sl.registerSingleton<ProductToDomainMapper>(ProductToDomainMapperImpl());
  sl.registerSingleton<ProductToModelMapper>(ProductToModelMapperImpl());
  sl.registerSingleton<ProductEntityToModelMapper>(
    ProductEntityToModelMapperImpl(),
  );
  sl.registerSingleton<CatEntityToModelMapper>(CatEntityToModelMapperImpl());
  sl.registerSingleton<CatDocumentMapper>(CatDocumentMapperImpl());
  sl.registerSingleton<CatModelToEntityMapper>(CatModelToEntityMapper());
}

Future<void> _registerRepositories() async {
  sl.registerSingleton<SearchRepository>(
    SearchRepositoryImpl(
      dataSource: sl<AlgoliaSearchDataSource>(),
      productToDomainMapper: sl<ProductToDomainMapper>(),
    ),
  );
  sl.registerSingleton<CatRepository>(
    CatRepositoryImpl(
      dataSource: sl<CatDataSource>(),
      mapper: sl<CatDocumentMapper>(),
    ),
  );
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(dataSource: sl<AuthFirebaseDataSource>()),
  );
}

Future<void> _registerUseCases() async {
  sl.registerSingleton<SearchByQueryUsecase>(
    SearchByQueryUsecase(searchRepository: sl<SearchRepository>()),
  );
  sl.registerSingleton<SearchByBarcodeUsecase>(
    SearchByBarcodeUsecase(searchRepository: sl<SearchRepository>()),
  );
  sl.registerSingleton<GetCatsUsecase>(
    GetCatsUsecase(repository: sl<CatRepository>()),
  );
  sl.registerSingleton<CreateCatUsecase>(
    CreateCatUsecase(repository: sl<CatRepository>()),
  );
  sl.registerSingleton<CurrentUserUsecase>(
    CurrentUserUsecase(repository: sl<AuthRepository>()),
  );
  sl.registerSingleton<SigninAnonymouslyUsecase>(
    SigninAnonymouslyUsecase(repository: sl<AuthRepository>()),
  );
}

Future<void> _registerServices() async {
  sl.registerSingleton<ScanTrackingService>(
    ScanTrackingService(prefs: sl<SharedPreferences>()),
  );
  sl.registerSingleton<CatTrackingService>(
    CatTrackingService(getCatsUsecase: sl<GetCatsUsecase>()),
  );
}

extension BlocProviderRegistration on GetIt {
  void registerBloc<T extends Bloc>(T Function() create) {
    registerFactory<T>(create);
    registerFactory<BlocProvider<T>>(
      () => BlocProvider<T>(create: (_) => sl<T>()),
    );
  }
}

Future<void> _registerBlocs() async {
  sl.registerBloc<OnBoardingBloc>(
    () => OnBoardingBloc(prefs: sl<SharedPreferences>()),
  );
  sl.registerBloc<SearchBloc>(
    () => SearchBloc(
      searchByQueryUsecase: sl<SearchByQueryUsecase>(),
      productToModelMapper: sl<ProductToModelMapper>(),
    ),
  );
  sl.registerBloc<HomeBloc>(
    () => HomeBloc(
      searchByBarcodeUsecase: sl<SearchByBarcodeUsecase>(),
      productEntityToModelMapper: sl<ProductEntityToModelMapper>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
      signinAnonymouslyUsecase: sl<SigninAnonymouslyUsecase>(),
    ),
  );
  sl.registerBloc<ProfileBloc>(() => ProfileBloc());
  sl.registerBloc<ProductDetailBloc>(() => ProductDetailBloc());
  sl.registerBloc<CatListingBloc>(
    () => CatListingBloc(
      getCatsUsecase: sl<GetCatsUsecase>(),
      catEntityToModelMapper: sl<CatEntityToModelMapper>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
    ),
  );
  sl.registerBloc<CatCreateBloc>(
    () => CatCreateBloc(
      createCatUsecase: sl<CreateCatUsecase>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
    ),
  );
}
