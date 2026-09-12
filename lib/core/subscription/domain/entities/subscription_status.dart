/// The two facts about a subscription that the rest of the app cares about.
///
/// [isTrial] is derived from the entitlement's period type, so it flips back to
/// `false` by itself once a trial converts or lapses — which is what lets the
/// `is_trial` tag/property drive a time-boxed trial journey without a cron.
class SubscriptionStatus {
  final bool isActive;
  final bool isTrial;

  const SubscriptionStatus({required this.isActive, required this.isTrial});

  static const none = SubscriptionStatus(isActive: false, isTrial: false);
}
