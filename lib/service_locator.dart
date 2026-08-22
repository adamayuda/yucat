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
import 'package:yucat/features/analytics/domain/usecase/identify_user_usecase.dart';
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
import 'package:yucat/features/brand/data/datasources/brand_verdict_datasource.dart';
import 'package:yucat/features/brand/data/mappers/brand_document_mapper.dart';
import 'package:yucat/features/brand/data/repositories/brand_repository_impl.dart';
import 'package:yucat/features/brand/data/repositories/brand_verdict_repository_impl.dart';
import 'package:yucat/features/brand/domain/repositories/brand_repository.dart';
import 'package:yucat/features/brand/domain/repositories/brand_verdict_repository.dart';
import 'package:yucat/features/brand/domain/usecases/analyze_brand_usecase.dart';
import 'package:yucat/features/brand/domain/usecases/get_brands_usecase.dart';
import 'package:yucat/features/cat/data/datasources/cat_datasource.dart';
import 'package:yucat/features/cat/data/datasources/cat_narrative_datasource.dart';
import 'package:yucat/features/cat/data/mappers/cat_document_mapper.dart';
import 'package:yucat/features/cat/data/repositories/cat_narrative_repository_impl.dart';
import 'package:yucat/features/cat/data/repositories/cat_repository_impl.dart';
import 'package:yucat/features/cat/domain/repositories/cat_narrative_repository.dart';
import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';
import 'package:yucat/features/cat/domain/usecases/create_cat_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/generate_cat_narrative_usecase.dart';
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
import 'package:yucat/features/saved_products/data/repositories/saved_products_repository_impl.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_products_repository.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_products_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/is_product_saved_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/save_product_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/unsave_product_usecase.dart';
import 'package:yucat/features/saved_products/presentation/bloc/saved_products_bloc.dart';
import 'package:yucat/features/scan_history/data/repositories/scan_history_repository_impl.dart';
import 'package:yucat/features/scan_history/domain/repositories/scan_history_repository.dart';
import 'package:yucat/features/scan_history/domain/usecases/add_scan_to_history_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/get_scan_history_usecase.dart';
import 'package:yucat/features/scan_history/presentation/bloc/scan_history_bloc.dart';
import 'package:yucat/features/product/data/datasources/product_remote_datasource.dart';
import 'package:yucat/features/product/data/mappers/product_to_domain_mapper.dart';
import 'package:yucat/features/product/data/repositories/product_repository.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_image_usecase.dart';
import 'package:yucat/features/search/data/datasources/algolia_search_datasource.dart';
import 'package:yucat/features/search/data/mappers/search_product_to_domain_mapper.dart';
import 'package:yucat/features/search/data/repositories/recent_searches_repository_impl.dart';
import 'package:yucat/features/search/data/repositories/search_repository.dart';
import 'package:yucat/features/search/domain/repositories/recent_searches_repository.dart';
import 'package:yucat/features/search/domain/repositories/search_repository.dart';
import 'package:yucat/features/search/domain/usecases/add_recent_search_usecase.dart';
import 'package:yucat/features/search/domain/usecases/clear_recent_searches_usecase.dart';
import 'package:yucat/features/search/domain/usecases/get_recent_searches_usecase.dart';
import 'package:yucat/features/search/domain/usecases/search_by_brand_usecase.dart';
import 'package:yucat/features/search/domain/usecases/search_by_query_usecase.dart';
import 'package:yucat/features/search_products/presentation/bloc/search_bloc.dart';
import 'package:yucat/features/search_products/presentation/mappers/brand_to_model_mapper.dart';
import 'package:yucat/features/search_products/presentation/mappers/product_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:yucat/services/notification_service.dart';
import 'package:yucat/services/remote_config_service.dart';
import 'package:yucat/services/review_prompt_service.dart';
import 'package:yucat/services/scan_tracking_service.dart';
import 'package:yucat/services/cat_tracking_service.dart';
import 'package:yucat/services/user_analytics_service.dart';
import 'package:yucat/features/litter/data/mappers/litter_to_domain_mapper.dart';
import 'package:yucat/features/recipes/data/datasources/recipe_seed_datasource.dart';
import 'package:yucat/features/recipes/data/repositories/recipes_repository_impl.dart';
import 'package:yucat/features/recipes/domain/repositories/recipes_repository.dart';
import 'package:yucat/features/recipes/domain/usecases/get_recipes_usecase.dart';
import 'package:yucat/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:yucat/features/recipes/presentation/mappers/recipe_entity_to_model_mapper.dart';
import 'package:yucat/features/litter_detail/presentation/bloc/litter_detail_bloc.dart';
import 'package:yucat/features/litter_detail/presentation/mappers/litter_entity_to_model_mapper.dart';
import 'package:yucat/features/saved_products/data/repositories/saved_litters_repository_impl.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_litters_repository.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_litters_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/is_litter_saved_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/save_litter_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/unsave_litter_usecase.dart';
import 'package:yucat/features/scan_history/data/repositories/litter_history_repository_impl.dart';
import 'package:yucat/features/scan_history/domain/repositories/litter_history_repository.dart';
import 'package:yucat/features/scan_history/domain/usecases/add_litter_to_history_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/get_litter_history_usecase.dart';

final sl = GetIt.instance;

// Revamp Mixpanel project token. Separate from the legacy app's project
// (old token 'a2e7bb0030da8c6a41153524b5051ea4') so the two never overlap.
// All events also carry the `tracking_version = v2` super property.
const _mixpanelToken = '100a0ee3f1cc3cf5220f2726ce81351e';

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
  // Stamp every event with the app edition. The revamp writes to a dedicated
  // Mixpanel project (separate token) so it never overlaps with the legacy
  // app's data; this super property is belt-and-suspenders + lets us segment
  // future builds. App version/build are auto-attached by the SDK
  // (trackAutomaticEvents) as $app_version_string / $app_build_number.
  mixpanel.registerSuperProperties({'tracking_version': 'v2'});
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
  sl.registerSingleton<CatNarrativeDataSource>(
    CatNarrativeDataSource(functions: sl<FirebaseFunctions>()),
  );
  sl.registerSingleton<BrandVerdictDataSource>(
    BrandVerdictDataSource(functions: sl<FirebaseFunctions>()),
  );
  // Hard-coded catalogue for now — swap this for a remote datasource when
  // recipes move to the backend.
  sl.registerSingleton<RecipeSeedDataSource>(const RecipeSeedDataSource());
}

Future<void> _registerMappers() async {
  sl.registerSingleton<BrandDocumentMapper>(BrandDocumentMapperImpl());
  sl.registerSingleton<ProductToDomainMapper>(ProductToDomainMapperImpl());
  sl.registerSingleton<LitterToDomainMapper>(LitterToDomainMapperImpl());
  sl.registerSingleton<ProductToModelMapper>(ProductToModelMapperImpl());
  sl.registerSingleton<LitterEntityToModelMapper>(
    LitterEntityToModelMapperImpl(),
  );
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
  sl.registerSingleton<RecipeEntityToModelMapper>(
    const RecipeEntityToModelMapper(),
  );
}

Future<void> _registerRepositories() async {
  sl.registerSingleton<BrandVerdictRepository>(
    BrandVerdictRepositoryImpl(dataSource: sl<BrandVerdictDataSource>()),
  );
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
      productToDomainMapper: sl<ProductToDomainMapper>(),
      litterToDomainMapper: sl<LitterToDomainMapper>(),
    ),
  );
  sl.registerSingleton<SearchRepository>(
    SearchRepositoryImpl(
      dataSource: sl<AlgoliaSearchDataSource>(),
      searchProductToDomainMapper: sl<SearchProductToDomainMapper>(),
    ),
  );
  sl.registerSingleton<RecentSearchesRepository>(
    RecentSearchesRepositoryImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerSingleton<CatRepository>(
    CatRepositoryImpl(
      dataSource: sl<CatDataSource>(),
      mapper: sl<CatDocumentMapper>(),
    ),
  );
  sl.registerSingleton<CatNarrativeRepository>(
    CatNarrativeRepositoryImpl(dataSource: sl<CatNarrativeDataSource>()),
  );
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(dataSource: sl<AuthFirebaseDataSource>()),
  );
  sl.registerSingleton<SubscriptionRepository>(SubscriptionRepositoryImpl());
  sl.registerSingleton<SavedProductsRepository>(
    SavedProductsRepositoryImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerSingleton<SavedLittersRepository>(
    SavedLittersRepositoryImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerSingleton<ScanHistoryRepository>(
    ScanHistoryRepositoryImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerSingleton<LitterHistoryRepository>(
    LitterHistoryRepositoryImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerSingleton<RecipesRepository>(
    RecipesRepositoryImpl(dataSource: sl<RecipeSeedDataSource>()),
  );
}

Future<void> _registerUseCases() async {
  sl.registerSingleton<SearchByBrandUsecase>(
    SearchByBrandUsecase(searchRepository: sl<SearchRepository>()),
  );
  sl.registerSingleton<GetBrandsUsecase>(
    GetBrandsUsecase(repository: sl<BrandRepository>()),
  );
  sl.registerSingleton<AnalyzeBrandUsecase>(
    AnalyzeBrandUsecase(
      repository: sl<BrandVerdictRepository>(),
      searchByBrand: sl<SearchByBrandUsecase>(),
    ),
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
  sl.registerSingleton<IdentifyUserUsecase>(
    IdentifyUserUsecase(repository: sl<AnalyticsRepository>()),
  );
  sl.registerSingleton<SearchByQueryUsecase>(
    SearchByQueryUsecase(searchRepository: sl<SearchRepository>()),
  );
  sl.registerSingleton<GetRecentSearchesUsecase>(
    GetRecentSearchesUsecase(repository: sl<RecentSearchesRepository>()),
  );
  sl.registerSingleton<AddRecentSearchUsecase>(
    AddRecentSearchUsecase(repository: sl<RecentSearchesRepository>()),
  );
  sl.registerSingleton<ClearRecentSearchesUsecase>(
    ClearRecentSearchesUsecase(repository: sl<RecentSearchesRepository>()),
  );
  sl.registerSingleton<FetchProductByImageUsecase>(
    FetchProductByImageUsecase(productRepository: sl<ProductRepository>()),
  );
  sl.registerSingleton<GetCatsUsecase>(
    GetCatsUsecase(repository: sl<CatRepository>()),
  );
  sl.registerSingleton<CreateCatUsecase>(
    CreateCatUsecase(repository: sl<CatRepository>()),
  );
  sl.registerSingleton<GenerateCatNarrativeUsecase>(
    GenerateCatNarrativeUsecase(repository: sl<CatNarrativeRepository>()),
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
  sl.registerSingleton<GetSavedProductsUsecase>(
    GetSavedProductsUsecase(repository: sl<SavedProductsRepository>()),
  );
  sl.registerSingleton<IsProductSavedUsecase>(
    IsProductSavedUsecase(repository: sl<SavedProductsRepository>()),
  );
  sl.registerSingleton<SaveProductUsecase>(
    SaveProductUsecase(repository: sl<SavedProductsRepository>()),
  );
  sl.registerSingleton<UnsaveProductUsecase>(
    UnsaveProductUsecase(repository: sl<SavedProductsRepository>()),
  );
  sl.registerSingleton<GetScanHistoryUsecase>(
    GetScanHistoryUsecase(repository: sl<ScanHistoryRepository>()),
  );
  sl.registerSingleton<AddScanToHistoryUsecase>(
    AddScanToHistoryUsecase(repository: sl<ScanHistoryRepository>()),
  );
  sl.registerSingleton<GetSavedLittersUsecase>(
    GetSavedLittersUsecase(repository: sl<SavedLittersRepository>()),
  );
  sl.registerSingleton<IsLitterSavedUsecase>(
    IsLitterSavedUsecase(repository: sl<SavedLittersRepository>()),
  );
  sl.registerSingleton<SaveLitterUsecase>(
    SaveLitterUsecase(repository: sl<SavedLittersRepository>()),
  );
  sl.registerSingleton<UnsaveLitterUsecase>(
    UnsaveLitterUsecase(repository: sl<SavedLittersRepository>()),
  );
  sl.registerSingleton<GetLitterHistoryUsecase>(
    GetLitterHistoryUsecase(repository: sl<LitterHistoryRepository>()),
  );
  sl.registerSingleton<AddLitterToHistoryUsecase>(
    AddLitterToHistoryUsecase(repository: sl<LitterHistoryRepository>()),
  );
  sl.registerSingleton<GetRecipesUsecase>(
    GetRecipesUsecase(repository: sl<RecipesRepository>()),
  );
}

Future<void> _registerServices() async {
  sl.registerSingleton<UserAnalyticsService>(
    UserAnalyticsService(
      identifyUserUsecase: sl<IdentifyUserUsecase>(),
      setUserPropertiesUsecase: sl<SetUserPropertiesUsecase>(),
    ),
  );
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
  sl.registerSingleton<ReviewPromptService>(
    ReviewPromptService(
      prefs: sl<SharedPreferences>(),
      logEventUsecase: sl<LogEventUsecase>(),
    ),
  );
  // Depends on the UserAnalyticsService registered above — the direction is
  // load-bearing, which is why OneSignal tag writes live here and never inside
  // UserAnalyticsService (that edge would be a cycle).
  sl.registerSingleton<NotificationService>(
    NotificationService(
      logEventUsecase: sl<LogEventUsecase>(),
      userAnalyticsService: sl<UserAnalyticsService>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
  sl.registerSingleton<RemoteConfigService>(RemoteConfigService());
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
  sl.registerBloc<SplashBloc>(
    () => SplashBloc(
      prefs: sl<SharedPreferences>(),
      hasActiveSubscriptionUseCase: sl<HasActiveSubscriptionUseCase>(),
      userAnalyticsService: sl<UserAnalyticsService>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
      signinAnonymouslyUsecase: sl<SigninAnonymouslyUsecase>(),
      notificationService: sl<NotificationService>(),
    ),
  );
  sl.registerBloc<ProductListingBloc>(
    () => ProductListingBloc(
      searchByBrandUsecase: sl<SearchByBrandUsecase>(),
      productToModelMapper: sl<ProductToModelMapper>(),
    ),
  );
  sl.registerBloc<OnBoardingBloc>(
    () => OnBoardingBloc(
      prefs: sl<SharedPreferences>(),
      logScreenViewUsecase: sl<LogScreenViewUsecase>(),
      logEventUsecase: sl<LogEventUsecase>(),
      userAnalyticsService: sl<UserAnalyticsService>(),
      remoteConfigService: sl<RemoteConfigService>(),
      notificationService: sl<NotificationService>(),
    ),
  );
  sl.registerBloc<SearchBloc>(
    () => SearchBloc(
      searchByQueryUsecase: sl<SearchByQueryUsecase>(),
      productToModelMapper: sl<ProductToModelMapper>(),
      logEventUsecase: sl<LogEventUsecase>(),
      getBrandsUsecase: sl<GetBrandsUsecase>(),
      brandToModelMapper: sl<BrandToModelMapper>(),
      getRecentSearchesUsecase: sl<GetRecentSearchesUsecase>(),
      addRecentSearchUsecase: sl<AddRecentSearchUsecase>(),
      clearRecentSearchesUsecase: sl<ClearRecentSearchesUsecase>(),
    ),
  );
  sl.registerBloc<HomeBloc>(
    () => HomeBloc(
      fetchProductByImageUsecase: sl<FetchProductByImageUsecase>(),
      productEntityToModelMapper: sl<ProductEntityToModelMapper>(),
      litterEntityToModelMapper: sl<LitterEntityToModelMapper>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
      signinAnonymouslyUsecase: sl<SigninAnonymouslyUsecase>(),
      reviewPromptService: sl<ReviewPromptService>(),
      getCatsUsecase: sl<GetCatsUsecase>(),
      getSavedProductsUsecase: sl<GetSavedProductsUsecase>(),
      addScanToHistoryUsecase: sl<AddScanToHistoryUsecase>(),
      addLitterToHistoryUsecase: sl<AddLitterToHistoryUsecase>(),
      logEventUsecase: sl<LogEventUsecase>(),
      notificationService: sl<NotificationService>(),
      userAnalyticsService: sl<UserAnalyticsService>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
  sl.registerBloc<ProfileBloc>(
    () => ProfileBloc(
      prefs: sl<SharedPreferences>(),
      getCatsUsecase: sl<GetCatsUsecase>(),
      getSavedProductsUsecase: sl<GetSavedProductsUsecase>(),
      getSavedLittersUsecase: sl<GetSavedLittersUsecase>(),
      getScanHistoryUsecase: sl<GetScanHistoryUsecase>(),
      getLitterHistoryUsecase: sl<GetLitterHistoryUsecase>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
    ),
  );
  sl.registerBloc<ProductDetailBloc>(
    () => ProductDetailBloc(
      logEventUsecase: sl<LogEventUsecase>(),
      isProductSavedUsecase: sl<IsProductSavedUsecase>(),
      saveProductUsecase: sl<SaveProductUsecase>(),
      unsaveProductUsecase: sl<UnsaveProductUsecase>(),
    ),
  );
  sl.registerBloc<LitterDetailBloc>(
    () => LitterDetailBloc(
      logEventUsecase: sl<LogEventUsecase>(),
      isLitterSavedUsecase: sl<IsLitterSavedUsecase>(),
      saveLitterUsecase: sl<SaveLitterUsecase>(),
      unsaveLitterUsecase: sl<UnsaveLitterUsecase>(),
    ),
  );
  sl.registerBloc<SavedProductsBloc>(
    () => SavedProductsBloc(
      getSavedProductsUsecase: sl<GetSavedProductsUsecase>(),
      getSavedLittersUsecase: sl<GetSavedLittersUsecase>(),
    ),
  );
  sl.registerBloc<ScanHistoryBloc>(
    () => ScanHistoryBloc(
      getScanHistoryUsecase: sl<GetScanHistoryUsecase>(),
      getLitterHistoryUsecase: sl<GetLitterHistoryUsecase>(),
    ),
  );
  sl.registerBloc<CatListingBloc>(
    () => CatListingBloc(
      getCatsUsecase: sl<GetCatsUsecase>(),
      catEntityToModelMapper: sl<CatEntityToModelMapper>(),
      currentUserUsecase: sl<CurrentUserUsecase>(),
    ),
  );
  sl.registerBloc<CatDetailBloc>(
    () => CatDetailBloc(
      deleteCatUsecase: sl<DeleteCatUsecase>(),
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
      notificationService: sl<NotificationService>(),
    ),
  );
  sl.registerBloc<PaywallBloc>(
    () => PaywallBloc(
      hasActiveSubscriptionUseCase: sl<HasActiveSubscriptionUseCase>(),
      logEventUsecase: sl<LogEventUsecase>(),
      userAnalyticsService: sl<UserAnalyticsService>(),
      notificationService: sl<NotificationService>(),
    ),
  );
  sl.registerBloc<RecipesBloc>(
    () => RecipesBloc(
      getRecipesUsecase: sl<GetRecipesUsecase>(),
      mapper: sl<RecipeEntityToModelMapper>(),
    ),
  );
}
