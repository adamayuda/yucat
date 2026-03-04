import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/core/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:yucat/core/subscription/domain/repositories/subscription_repository.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/data/repository/analytics_repository_impl.dart';
import 'package:yucat/features/analytics/data/sources/analytics_data_source.dart';
import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_login_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_search_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_sign_up_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/set_user_properties_usecase.dart';
import 'package:yucat/features/auth/data/repository/auth_repository_impl.dart';
import 'package:yucat/features/auth/data/sources/auth_data_source.dart';
import 'package:yucat/features/auth/domain/repository/auth_repository.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/signin_anonymously_usecase.dart';
import 'package:yucat/features/brand/data/datasources/brand_datasource.dart';
import 'package:yucat/features/brand/data/mappers/brand_document_mapper.dart';
import 'package:yucat/features/brand/data/repositories/brand_repository_impl.dart';
import 'package:yucat/features/brand/domain/repositories/brand_repository.dart';
import 'package:yucat/features/brand/domain/usecases/get_brands_usecase.dart';
import 'package:yucat/features/cat/data/datasources/cat_datasource.dart';
import 'package:yucat/features/cat/data/mappers/cat_document_mapper.dart';
import 'package:yucat/features/cat/data/repositories/cat_repository_impl.dart';
import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';
import 'package:yucat/features/cat/domain/usecases/create_cat_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/delete_cat_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/update_cat_usecase.dart';
import 'package:yucat/features/cat_create/bloc/cat_create_bloc.dart';
import 'package:yucat/features/cat_create/mappers/cat_model_to_create_mapper.dart';
import 'package:yucat/features/cat_create/mappers/cat_model_to_entity_mapper.dart';
import 'package:yucat/features/cat_detail/presentation/bloc/cat_detail_bloc.dart';
import 'package:yucat/features/cat_listing/bloc/cat_listing_bloc.dart';
import 'package:yucat/features/cat_listing/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:yucat/features/product_listing/presentation/bloc/product_listing_bloc.dart';
import 'package:yucat/features/profile/bloc/profile_bloc.dart';
import 'package:yucat/features/product/data/datasources/product_remote_datasource.dart';
import 'package:yucat/features/product/data/mappers/product_to_domain_mapper.dart';
import 'package:yucat/features/product/data/repositories/product_repository.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_barcode_usecase.dart';
import 'package:yucat/features/search/data/datasources/algolia_search_datasource.dart';
import 'package:yucat/features/search/data/mappers/search_product_to_domain_mapper.dart';
import 'package:yucat/features/search/data/repositories/search_repository.dart';
import 'package:yucat/features/search/domain/repositories/search_repository.dart';
import 'package:yucat/features/search/domain/usecases/search_by_brand_usecase.dart';
import 'package:yucat/features/search/domain/usecases/search_by_query_usecase.dart';
import 'package:yucat/features/search_products/presentation/bloc/search_bloc.dart';
import 'package:yucat/features/search_products/presentation/mappers/brand_to_model_mapper.dart';
import 'package:yucat/features/search_products/presentation/mappers/product_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:yucat/services/scan_tracking_service.dart';
import 'package:yucat/services/cat_tracking_service.dart';

final sl = GetIt.instance;

const _mixpanelToken = 'a2e7bb0030da8c6a41153524b5051ea4';

Future<void> initializeDependencies() async {
  await _registerMixpanel();
  await _registerSharedPreferences();
  await _registerDio();
  await _registerFirebaseFunctions();
  await _registerDataSources();
  await _registerMappers();
  await _registerRepositories();
  await _registerUseCases();
  await _registerServices();
  await _registerBlocs();
}

Future<void> _registerMixpanel() async {
  final mixpanel = await Mixpanel.init(
    _mixpanelToken,
    trackAutomaticEvents: true,
  );
  sl.registerSingleton<Mixpanel>(mixpanel);
}

Future<void> _registerSharedPreferences() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
}

Future<void> _registerDio() async {
  sl.registerSingleton<Dio>(Dio());
}

Future<void> _registerFirebaseFunctions() async {
  sl.registerSingleton<FirebaseFunctions>(
    FirebaseFunctions.instanceFor(region: 'us-central1'),
  );
}

Future<void> _registerDataSources() async {
  sl.registerSingleton<BrandDataSource>(
    BrandDataSource(firestore: FirebaseFirestore.instance),
  );
  sl.registerSingleton<AnalyticsFirebaseDataSource>(
    AnalyticsFirebaseDataSourceImpl(),
  );
  sl.registerSingleton<AlgoliaSearchDataSource>(AlgoliaSearchDataSource());
  sl.registerSingleton<RemoteSearchDataSource>(
    RemoteSearchDataSource(
      functions: FirebaseFunctions.instanceFor(region: 'us-central1'),
      auth: FirebaseAuth.instance,
    ),
  );
  sl.registerSingleton<AuthFirebaseDataSource>(AuthFirebaseDataSource());
  sl.registerSingleton<CatDataSource>(
    CatDataSource(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    ),
  );
}

Future<void> _registerMappers() async {
  sl.registerSingleton<BrandDocumentMapper>(BrandDocumentMapperImpl());
  sl.registerSingleton<ProductToDomainMapper>(ProductToDomainMapperImpl());
  sl.registerSingleton<ProductToModelMapper>(ProductToModelMapperImpl());
  sl.registerSingleton<ProductEntityToModelMapper>(
    ProductEntityToModelMapperImpl(),
  );
  sl.registerSingleton<SearchProductToDomainMapper>(
    SearchProductToDomainMapperImpl(),
  );
  sl.registerSingleton<CatEntityToModelMapper>(CatEntityToModelMapperImpl());
  sl.registerSingleton<CatDocumentMapper>(CatDocumentMapperImpl());
  sl.registerSingleton<CatModelToEntityMapper>(CatModelToEntityMapper());
  sl.registerSingleton<CatModelToCreateMapper>(CatModelToCreateMapperImpl());
  sl.registerSingleton<BrandToModelMapper>(BrandToModelMapperImpl());
}

Future<void> _registerRepositories() async {
  sl.registerSingleton<BrandRepository>(
    BrandRepositoryImpl(
      dataSource: sl<BrandDataSource>(),
      mapper: sl<BrandDocumentMapper>(),
    ),
  );
  sl.registerSingleton<AnalyticsRepository>(
    AnalyticsRepositoryImpl(mixpanel: sl<Mixpanel>()),
  );
  sl.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(
      remoteDataSource: sl<RemoteSearchDataSource>(),
      algoliaDataSource: sl<AlgoliaSearchDataSource>(),
      productToDomainMapper: sl<ProductToDomainMapper>(),
      searchProductToDomainMapper: sl<SearchProductToDomainMapper>(),
    ),
  );
  sl.registerSingleton<SearchRepository>(
    SearchRepositoryImpl(
      dataSource: sl<AlgoliaSearchDataSource>(),
      searchProductToDomainMapper: sl<SearchProductToDomainMapper>(),
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
  sl.registerSingleton<SubscriptionRepository>(SubscriptionRepositoryImpl());
}

Future<void> _registerUseCases() async {
  sl.registerSingleton<SearchByBrandUsecase>(
    SearchByBrandUsecase(searchRepository: sl<SearchRepository>()),
  );
  sl.registerSingleton<GetBrandsUsecase>(
    GetBrandsUsecase(repository: sl<BrandRepository>()),
  );
  sl.registerSingleton<LogEventUsecase>(
    LogEventUsecase(repository: sl<AnalyticsRepository>()),
  );
  sl.registerSingleton<LogScreenViewUsecase>(
    LogScreenViewUsecase(repository: sl<AnalyticsRepository>()),
  );
  sl.registerSingleton<LogLoginUsecase>(
    LogLoginUsecase(repository: sl<AnalyticsRepository>()),
  );
  sl.registerSingleton<LogSignUpUsecase>(
    LogSignUpUsecase(repository: sl<AnalyticsRepository>()),
  );
  sl.registerSingleton<LogSearchUsecase>(
    LogSearchUsecase(repository: sl<AnalyticsRepository>()),
  );
  sl.registerSingleton<SetUserPropertiesUsecase>(
    SetUserPropertiesUsecase(repository: sl<AnalyticsRepository>()),
  );
  sl.registerSingleton<SearchByQueryUsecase>(
    SearchByQueryUsecase(searchRepository: sl<SearchRepository>()),
  );
  sl.registerSingleton<FetchProductByBarcodeUsecase>(
    FetchProductByBarcodeUsecase(productRepository: sl<ProductRepository>()),
  );
  sl.registerSingleton<GetCatsUsecase>(
    GetCatsUsecase(repository: sl<CatRepository>()),
  );
  sl.registerSingleton<CreateCatUsecase>(
    CreateCatUsecase(repository: sl<CatRepository>()),
  );
  sl.registerSingleton<DeleteCatUsecase>(
    DeleteCatUsecase(repository: sl<CatRepository>()),
  );
  sl.registerSingleton<UpdateCatUsecase>(
    UpdateCatUsecase(repository: sl<CatRepository>()),
  );
  sl.registerSingleton<CurrentUserUsecase>(
    CurrentUserUsecase(repository: sl<AuthRepository>()),
  );
  sl.registerSingleton<SigninAnonymouslyUsecase>(
    SigninAnonymouslyUsecase(repository: sl<AuthRepository>()),
  );
  sl.registerSingleton<HasActiveSubscriptionUseCase>(
    HasActiveSubscriptionUseCase(repository: sl<SubscriptionRepository>()),
  );
}

Future<void> _registerServices() async {
  sl.registerSingleton<ScanTrackingService>(
    ScanTrackingService(
      prefs: sl<SharedPreferences>(),
      hasActiveSubscriptionUseCase: sl<HasActiveSubscriptionUseCase>(),
      logEventUsecase: sl<LogEventUsecase>(),
    ),
  );
  sl.registerSingleton<CatTrackingService>(
    CatTrackingService(
      getCatsUsecase: sl<GetCatsUsecase>(),
      hasActiveSubscriptionUseCase: sl<HasActiveSubscriptionUseCase>(),
      logEventUsecase: sl<LogEventUsecase>(),
    ),
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
  sl.registerBloc<SplashBloc>(() => SplashBloc(prefs: sl<SharedPreferences>()));
  sl.registerBloc<ProductListingBloc>(
    () => ProductListingBloc(
      searchByBrandUsecase: sl<SearchByBrandUsecase>(),
      productToModelMapper: sl<ProductToModelMapper>(),
      logScreenViewUsecase: sl<LogScreenViewUsecase>(),
    ),
  );
  sl.registerBloc<OnBoardingBloc>(
    () => OnBoardingBloc(
      prefs: sl<SharedPreferences>(),
      logScreenViewUsecase: sl<LogScreenViewUsecase>(),
      logEventUsecase: sl<LogEventUsecase>(),
    ),
  );
  sl.registerBloc<SearchBloc>(
    () => SearchBloc(
      searchByQueryUsecase: sl<SearchByQueryUsecase>(),
      productToModelMapper: sl<ProductToModelMapper>(),
      logScreenViewUsecase: sl<LogScreenViewUsecase>(),
      logEventUsecase: sl<LogEventUsecase>(),
      getBrandsUsecase: sl<GetBrandsUsecase>(),
      brandToModelMapper: sl<BrandToModelMapper>(),
    ),
  );
  sl.registerBloc<HomeBloc>(
    () => HomeBloc(
      fetchProductByBarcodeUsecase: sl<FetchProductByBarcodeUsecase>(),
      productEntityToModelMapper: sl<ProductEntityToModelMapper>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
      signinAnonymouslyUsecase: sl<SigninAnonymouslyUsecase>(),
      scanTrackingService: sl<ScanTrackingService>(),
      logScreenViewUsecase: sl<LogScreenViewUsecase>(),
      logEventUsecase: sl<LogEventUsecase>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
  sl.registerBloc<ProfileBloc>(
    () => ProfileBloc(logScreenViewUsecase: sl<LogScreenViewUsecase>()),
  );
  sl.registerBloc<ProductDetailBloc>(
    () => ProductDetailBloc(
      logScreenViewUsecase: sl<LogScreenViewUsecase>(),
      logEventUsecase: sl<LogEventUsecase>(),
    ),
  );
  sl.registerBloc<CatListingBloc>(
    () => CatListingBloc(
      getCatsUsecase: sl<GetCatsUsecase>(),
      catEntityToModelMapper: sl<CatEntityToModelMapper>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
      logScreenViewUsecase: sl<LogScreenViewUsecase>(),
      catTrackingService: sl<CatTrackingService>(),
    ),
  );
  sl.registerBloc<CatDetailBloc>(
    () => CatDetailBloc(
      deleteCatUsecase: sl<DeleteCatUsecase>(),
      logScreenViewUsecase: sl<LogScreenViewUsecase>(),
      logEventUsecase: sl<LogEventUsecase>(),
    ),
  );
  sl.registerBloc<CatCreateBloc>(
    () => CatCreateBloc(
      createCatUsecase: sl<CreateCatUsecase>(),
      updateCatUsecase: sl<UpdateCatUsecase>(),
      catModelToEntityMapper: sl<CatModelToEntityMapper>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
      logScreenViewUsecase: sl<LogScreenViewUsecase>(),
      logEventUsecase: sl<LogEventUsecase>(),
    ),
  );
  sl.registerBloc<PaywallBloc>(
    () => PaywallBloc(
      hasActiveSubscriptionUseCase: sl<HasActiveSubscriptionUseCase>(),
      logEventUsecase: sl<LogEventUsecase>(),
    ),
  );
}
