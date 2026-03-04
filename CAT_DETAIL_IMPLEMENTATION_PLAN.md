# Cat Detail Screen Implementation Plan

## Overview

This plan outlines the implementation of a dedicated Cat Detail Screen that allows users to view, edit, and delete their cat profiles. This follows Clean Architecture principles and maintains consistency with the existing codebase structure.

## Architecture Overview

### New Files to Create

```
lib/features/cat_detail/
├── presentation/
│   ├── bloc/
│   │   ├── cat_detail_bloc.dart
│   │   ├── cat_detail_event.dart
│   │   └── cat_detail_state.dart
│   ├── widgets/
│   │   ├── cat_detail_header.dart
│   │   ├── cat_detail_info_section.dart
│   │   └── delete_confirmation_dialog.dart
│   └── cat_detail_page.dart
├── domain/
│   └── usecases/
│       ├── delete_cat_usecase.dart
│       └── update_cat_usecase.dart
```

### Existing Files to Modify

1. **lib/config/routes/router.dart** - Add CatDetailRoute
2. **lib/features/cat_listing/presentation/cat_listing_page.dart** - Add navigation to detail on cat card tap
3. **lib/features/cat/domain/repositories/cat_repository.dart** - Add delete and update methods
4. **lib/features/cat/data/repositories/cat_repository_impl.dart** - Implement delete and update
5. **lib/features/cat/data/datasources/cat_datasource.dart** - Add Firebase delete and update operations
6. **lib/features/cat_create/bloc/cat_create_bloc.dart** - Support edit mode
7. **lib/service_locator.dart** - Register new usecases and bloc

## Phase 1: Domain Layer (Usecases & Repository Interface)

### 1.1 Update Repository Interface

**File: lib/features/cat/domain/repositories/cat_repository.dart**

Add new methods:
```dart
Future<void> deleteCat({required String catId});
Future<void> updateCat({required CatEntity cat});
```

### 1.2 Create Delete Cat Usecase

**File: lib/features/cat/domain/usecases/delete_cat_usecase.dart**

```dart
class DeleteCatUsecase {
  final CatRepository repository;

  DeleteCatUsecase({required this.repository});

  Future<void> call({required String catId}) async {
    return repository.deleteCat(catId: catId);
  }
}
```

### 1.3 Create Update Cat Usecase

**File: lib/features/cat/domain/usecases/update_cat_usecase.dart**

```dart
class UpdateCatUsecase {
  final CatRepository repository;

  UpdateCatUsecase({required this.repository});

  Future<void> call({required CatEntity cat}) async {
    return repository.updateCat(cat: cat);
  }
}
```

## Phase 2: Data Layer (Repository & DataSource Implementation)

### 2.1 Implement Delete in DataSource

**File: lib/features/cat/data/datasources/cat_datasource.dart**

Add method:
```dart
Future<void> deleteCat({required String userId, required String catId}) async {
  // Delete Firestore document
  await _firestore
      .collection('users')
      .doc(userId)
      .collection('cats')
      .doc(catId)
      .delete();

  // Delete profile image from Storage if exists
  try {
    final ref = _storage.ref().child('cats/$userId/$catId/profile.jpg');
    await ref.delete();
  } catch (e) {
    // Ignore if image doesn't exist
  }
}
```

### 2.2 Implement Update in DataSource

**File: lib/features/cat/data/datasources/cat_datasource.dart**

Add method:
```dart
Future<void> updateCat({
  required String userId,
  required String catId,
  required Map<String, dynamic> catData,
  File? profileImageFile,
}) async {
  String? profileImageUrl;

  // Upload new image if provided
  if (profileImageFile != null) {
    final ref = _storage.ref().child('cats/$userId/$catId/profile.jpg');
    await ref.putFile(profileImageFile);
    profileImageUrl = await ref.getDownloadURL();
    catData['profileImageUrl'] = profileImageUrl;
  }

  // Update Firestore document
  await _firestore
      .collection('users')
      .doc(userId)
      .collection('cats')
      .doc(catId)
      .update(catData);
}
```

### 2.3 Implement in Repository

**File: lib/features/cat/data/repositories/cat_repository_impl.dart**

```dart
@override
Future<void> deleteCat({required String catId}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');

  return _dataSource.deleteCat(userId: userId, catId: catId);
}

@override
Future<void> updateCat({required CatEntity cat}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');

  final catDocument = _mapper.toDocument(cat);
  return _dataSource.updateCat(
    userId: userId,
    catId: cat.id,
    catData: catDocument,
    profileImageFile: null, // Image handled separately
  );
}
```

## Phase 3: Presentation Layer - Cat Detail Screen

### 3.1 Create Cat Detail Events

**File: lib/features/cat_detail/presentation/bloc/cat_detail_event.dart**

```dart
part of 'cat_detail_bloc.dart';

sealed class CatDetailEvent extends Equatable {
  const CatDetailEvent();
}

class CatDetailInitialEvent extends CatDetailEvent {
  final CatModel cat;

  const CatDetailInitialEvent({required this.cat});

  @override
  List<Object?> get props => [cat];
}

class CatDetailDeleteEvent extends CatDetailEvent {
  final String catId;

  const CatDetailDeleteEvent({required this.catId});

  @override
  List<Object?> get props => [catId];
}

class CatDetailEditEvent extends CatDetailEvent {
  final CatModel cat;

  const CatDetailEditEvent({required this.cat});

  @override
  List<Object?> get props => [cat];
}
```

### 3.2 Create Cat Detail States

**File: lib/features/cat_detail/presentation/bloc/cat_detail_state.dart**

```dart
part of 'cat_detail_bloc.dart';

sealed class CatDetailState extends Equatable {
  const CatDetailState();
}

class CatDetailInitialState extends CatDetailState {
  @override
  List<Object?> get props => [];
}

class CatDetailLoadedState extends CatDetailState {
  final CatModel cat;

  const CatDetailLoadedState({required this.cat});

  @override
  List<Object?> get props => [cat];
}

class CatDetailLoadingState extends CatDetailState {
  @override
  List<Object?> get props => [];
}

class CatDetailDeletedState extends CatDetailState {
  @override
  List<Object?> get props => [];
}

class CatDetailErrorState extends CatDetailState {
  final String message;

  const CatDetailErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class CatDetailNavigateToEditState extends CatDetailState {
  final CatModel cat;

  const CatDetailNavigateToEditState({required this.cat});

  @override
  List<Object?> get props => [cat];
}
```

### 3.3 Create Cat Detail BLoC

**File: lib/features/cat_detail/presentation/bloc/cat_detail_bloc.dart**

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/delete_cat_usecase.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';

part 'cat_detail_event.dart';
part 'cat_detail_state.dart';

class CatDetailBloc extends Bloc<CatDetailEvent, CatDetailState> {
  final DeleteCatUsecase _deleteCatUsecase;
  final LogScreenViewUsecase _logScreenViewUsecase;
  final LogEventUsecase _logEventUsecase;

  CatDetailBloc({
    required DeleteCatUsecase deleteCatUsecase,
    required LogScreenViewUsecase logScreenViewUsecase,
    required LogEventUsecase logEventUsecase,
  })  : _deleteCatUsecase = deleteCatUsecase,
        _logScreenViewUsecase = logScreenViewUsecase,
        _logEventUsecase = logEventUsecase,
        super(CatDetailInitialState()) {
    on<CatDetailInitialEvent>(_onCatDetailInitialEvent);
    on<CatDetailDeleteEvent>(_onCatDetailDeleteEvent);
    on<CatDetailEditEvent>(_onCatDetailEditEvent);
  }

  Future<void> _onCatDetailInitialEvent(
    CatDetailInitialEvent event,
    Emitter<CatDetailState> emit,
  ) async {
    _logEventUsecase.call(
      eventName: 'Cat Profile Viewed',
      properties: {
        'cat_name': event.cat.name,
        'cat_age_group': event.cat.ageGroup,
        'cat_breed': event.cat.breed,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(CatDetailLoadedState(cat: event.cat));
  }

  Future<void> _onCatDetailDeleteEvent(
    CatDetailDeleteEvent event,
    Emitter<CatDetailState> emit,
  ) async {
    emit(CatDetailLoadingState());

    try {
      await _deleteCatUsecase.call(catId: event.catId);

      _logEventUsecase.call(
        eventName: 'Cat Profile Deleted',
        properties: {
          'cat_id': event.catId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(CatDetailDeletedState());
    } catch (e) {
      _logEventUsecase.call(
        eventName: 'Cat Profile Delete Failed',
        properties: {
          'cat_id': event.catId,
          'error_message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(CatDetailErrorState(message: 'Failed to delete cat: $e'));
    }
  }

  Future<void> _onCatDetailEditEvent(
    CatDetailEditEvent event,
    Emitter<CatDetailState> emit,
  ) async {
    _logEventUsecase.call(
      eventName: 'Cat Profile Edit Started',
      properties: {
        'cat_name': event.cat.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(CatDetailNavigateToEditState(cat: event.cat));
  }
}
```

### 3.4 Create Cat Detail Page

**File: lib/features/cat_detail/presentation/cat_detail_page.dart**

Key features:
- Display cat profile information (name, breed, age, weight, etc.)
- Show cat photo
- Health conditions list
- Activity level and neutered status
- Edit button (top right) - navigates to cat creation wizard in edit mode
- Delete button (bottom) - shows confirmation dialog

Layout structure:
```
AppBar (with Edit button)
├── Cat Photo (circular avatar)
├── Cat Name (title)
├── Basic Info Section
│   ├── Breed
│   ├── Age Group
│   ├── Weight
│   └── Activity Level
├── Status Section
│   ├── Neutered Status
│   └── Pregnancy/Lactation
├── Health Conditions Section
│   └── List of conditions
└── Delete Button (with confirmation)
```

### 3.5 Create Delete Confirmation Dialog

**File: lib/features/cat_detail/presentation/widgets/delete_confirmation_dialog.dart**

```dart
Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  required String catName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete $catName?'),
      content: const Text(
        'Are you sure you want to delete this cat profile? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
```

## Phase 4: Edit Mode for Cat Creation

### 4.1 Modify Cat Create BLoC for Edit Mode

**File: lib/features/cat_create/bloc/cat_create_bloc.dart**

Changes needed:
1. Add optional `CatModel? editingCat` parameter to constructor
2. Pre-populate wizard steps with existing cat data when in edit mode
3. Use UpdateCatUsecase instead of CreateCatUsecase when editing
4. Track "Cat Profile Updated" event with fields_changed property

Implementation approach:
- Add `isEditMode` boolean field
- In `_onCatCreateStartedEvent`, populate steps with existing data if editing
- In `_onCatCreateSubmitEvent`, check edit mode and call appropriate usecase
- Track which fields were changed during edit

### 4.2 Create Cat Model to Entity Mapper Enhancement

Update the existing mapper to support bidirectional conversion if needed for edit mode.

## Phase 5: Navigation & Routes

### 5.1 Add Cat Detail Route

**File: lib/config/routes/router.dart**

```dart
@RoutePage()
class CatDetailRoute extends StatelessWidget {
  final CatModel cat;

  const CatDetailRoute({required this.cat});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CatDetailBloc>()
        ..add(CatDetailInitialEvent(cat: cat)),
      child: const CatDetailPage(),
    );
  }
}
```

### 5.2 Update Cat Listing Navigation

**File: lib/features/cat_listing/presentation/cat_listing_page.dart**

Change cat card `onTap` to navigate to CatDetailRoute:
```dart
onTap: () {
  context.router.push(CatDetailRoute(cat: cat));
},
```

### 5.3 Handle Navigation from Cat Detail to Edit

In CatDetailPage, listen to `CatDetailNavigateToEditState` and navigate to CatCreateRoute with edit mode.

## Phase 6: Dependency Injection

### 6.1 Register New Usecases

**File: lib/service_locator.dart**

In `_registerUseCases()`:
```dart
sl.registerSingleton<DeleteCatUsecase>(
  DeleteCatUsecase(repository: sl<CatRepository>()),
);
sl.registerSingleton<UpdateCatUsecase>(
  UpdateCatUsecase(repository: sl<CatRepository>()),
);
```

### 6.2 Register Cat Detail BLoC

**File: lib/service_locator.dart**

In `_registerBlocs()`:
```dart
sl.registerBloc<CatDetailBloc>(
  () => CatDetailBloc(
    deleteCatUsecase: sl<DeleteCatUsecase>(),
    logScreenViewUsecase: sl<LogScreenViewUsecase>(),
    logEventUsecase: sl<LogEventUsecase>(),
  ),
);
```

## Analytics Events

### Event 1: Cat Profile Viewed
**Triggered:** When cat detail screen loads
**Properties:**
- `cat_name`: String
- `cat_age_group`: String
- `cat_breed`: String
- `timestamp`: ISO8601 String

### Event 2: Cat Profile Deleted
**Triggered:** After successful cat deletion
**Properties:**
- `cat_id`: String
- `timestamp`: ISO8601 String

### Event 3: Cat Profile Delete Failed
**Triggered:** When cat deletion fails
**Properties:**
- `cat_id`: String
- `error_message`: String
- `timestamp`: ISO8601 String

### Event 4: Cat Profile Edit Started
**Triggered:** When user taps Edit button
**Properties:**
- `cat_name`: String
- `timestamp`: ISO8601 String

### Event 5: Cat Profile Updated
**Triggered:** After successful cat update (in CatCreateBloc)
**Properties:**
- `cat_name`: String
- `cat_age_group`: String
- `cat_breed`: String
- `fields_changed`: List<String> (e.g., ["weight", "healthConditions"])
- `timestamp`: ISO8601 String

## Implementation Steps (Priority Order)

### Step 1: Domain Layer
1. Add delete and update methods to CatRepository interface
2. Create DeleteCatUsecase
3. Create UpdateCatUsecase
4. Register usecases in service_locator.dart

### Step 2: Data Layer
1. Implement deleteCat in CatDataSource (Firestore + Storage)
2. Implement updateCat in CatDataSource
3. Implement deleteCat in CatRepositoryImpl
4. Implement updateCat in CatRepositoryImpl

### Step 3: Cat Detail Screen (View Only)
1. Create CatDetailEvent, CatDetailState, CatDetailBloc
2. Implement view logic in BLoC (no edit/delete yet)
3. Create CatDetailPage UI
4. Add CatDetailRoute to router
5. Update cat listing to navigate to detail screen
6. Test viewing cat details

### Step 4: Delete Functionality
1. Add delete logic to CatDetailBloc
2. Create delete confirmation dialog
3. Wire up delete button in CatDetailPage
4. Handle navigation back to listing after delete
5. Add analytics events
6. Test delete flow

### Step 5: Edit Functionality
1. Modify CatCreateBloc to support edit mode
2. Pre-populate wizard with existing cat data
3. Implement updateCat flow in CatCreateBloc
4. Add edit navigation from CatDetailPage
5. Add analytics events
6. Test edit flow end-to-end

### Step 6: Polish & Testing
1. Error handling for all operations
2. Loading states during delete/update
3. Refresh cat listing after delete/update
4. Test all analytics events fire correctly
5. Test edge cases (no internet, invalid data, etc.)

## Testing Considerations

### Manual Testing Checklist
- [ ] View cat detail screen
- [ ] All cat information displays correctly
- [ ] Cat photo displays (or placeholder if none)
- [ ] Edit button navigates to creation wizard
- [ ] Creation wizard pre-populated with cat data
- [ ] Update cat and verify changes persist
- [ ] Delete button shows confirmation dialog
- [ ] Delete removes cat from Firestore
- [ ] Delete removes cat photo from Storage
- [ ] Cat listing refreshes after delete/update
- [ ] All analytics events tracked correctly
- [ ] Error states display properly

### Edge Cases
- Cat with no photo
- Cat with no health conditions
- Deleting last cat
- Network errors during delete/update
- Rapid navigation (user spam-taps)

## UI/UX Design Guidelines

### Cat Detail Screen
- **Header:** Cat photo (circular, 120dp) centered at top
- **Name:** Large, bold text below photo
- **Sections:** Card-based layout with clear section headers
- **Colors:** Use existing app theme colors
- **Spacing:** Consistent 16dp margins
- **Icons:** Material icons for visual consistency

### Buttons
- **Edit Button:** Icon button (edit icon) in AppBar
- **Delete Button:** Full-width button at bottom, red color, destructive style
- **Confirmation Dialog:** Standard Material dialog with Cancel/Delete actions

### Navigation
- **To Detail:** Tap cat card in listing
- **To Edit:** Tap edit icon in detail screen
- **After Delete:** Pop back to listing with success message (optional)
- **After Update:** Return to detail screen with updated data

## Dependencies

No new packages required. All functionality uses existing dependencies:
- firebase_auth (already in use)
- cloud_firestore (already in use)
- firebase_storage (already in use)
- flutter_bloc (already in use)
- auto_route (already in use)
- get_it (already in use)

## Success Criteria

1. Users can view full cat profile details
2. Users can edit any cat field and changes persist
3. Users can delete a cat with confirmation
4. Deleted cats are removed from Firestore and Storage
5. Cat listing updates automatically after delete/update
6. All analytics events fire correctly
7. Error states handled gracefully
8. No regressions in existing cat creation flow
