/// The cat's vet, as the owner typed it.
///
/// Profile data, not a dated act — so it lives on the **cat document** next to
/// `allergies`, not in `health_events`, and is edited from the carnet. Free
/// text on purpose: there is no clinic directory to key against, and the
/// value is in the phone number being one tap away.
class CatVetContact {
  final String name;
  final String? clinic;
  final String? phone;
  final String? address;

  const CatVetContact({
    required this.name,
    this.clinic,
    this.phone,
    this.address,
  });

  /// Nothing worth keeping. The edit sheet treats a blank save as a removal.
  bool get isEmpty =>
      name.trim().isEmpty &&
      (clinic ?? '').trim().isEmpty &&
      (phone ?? '').trim().isEmpty &&
      (address ?? '').trim().isEmpty;

  /// Name, else clinic — whichever the owner filled in. Never empty for a
  /// contact that passed [isEmpty].
  String get displayName =>
      name.trim().isNotEmpty ? name.trim() : (clinic ?? '').trim();
}
