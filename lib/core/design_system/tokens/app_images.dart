/// AcePadel Design System - Image Assets
///
/// Centralized image URLs for the application.
/// All images reference PADEL-specific content stored in Supabase Storage.
///
/// Architecture:
/// - All URLs point to the `app-assets` public bucket in Supabase Storage
/// - Single source of truth: change URLs here to update the entire app
/// - To seed images: call the `seed-app-images` Edge Function (GERANT only)
/// - To replace an image: upload to `app-assets/{path}` via Supabase Dashboard
abstract class AppImages {
  AppImages._();

  // ---------------------------------------------------------------------------
  // Supabase Storage Config
  // ---------------------------------------------------------------------------

  /// Base URL for Supabase storage
  static const String _sb =
      'https://vslisxnahktqaifdurcu.supabase.co/storage/v1/object/public/app-assets';

  // ---------------------------------------------------------------------------
  // Onboarding Images - PADEL themed
  // ---------------------------------------------------------------------------

  /// Page 1: Réservation - Vue d'un court de padel avec raquettes
  static const String onboardingReservation = '$_sb/onboarding/reservation.webp';

  /// Page 2: Créneaux - Court de padel intérieur, ambiance moderne
  static const String onboardingSchedule = '$_sb/onboarding/schedule.webp';

  /// Page 3: Événements - Joueurs de padel en action
  static const String onboardingEvents = '$_sb/onboarding/events.webp';

  /// Page 4: Performances - Match de padel, action dynamique
  static const String onboardingPerformance = '$_sb/onboarding/performance.webp';

  // ---------------------------------------------------------------------------
  // Home Action Cards - PADEL themed
  // ---------------------------------------------------------------------------

  /// Réserver un court - Court de padel avec parois vitrées
  static const String homeReservation = '$_sb/home/reservation.webp';

  /// Replays - Joueur de padel en pleine action
  static const String homeReplays = '$_sb/home/replays.webp';

  /// Coaching - Entraînement / coaching padel
  static const String homeCoaching = '$_sb/home/coaching.webp';

  // ---------------------------------------------------------------------------
  // Tournaments - PADEL themed
  // ---------------------------------------------------------------------------

  /// Tournoi image 1 - Court de padel match
  static const String tournament1 = '$_sb/tournaments/tournament1.webp';

  /// Tournoi image 2 - Joueurs padel en compétition
  static const String tournament2 = '$_sb/tournaments/tournament2.webp';

  /// Tournoi image 3 - Court padel vue large
  static const String tournament3 = '$_sb/tournaments/tournament3.webp';

  /// Tournoi image 4 - Padel match intense
  static const String tournament4 = '$_sb/tournaments/tournament4.webp';

  /// Tournoi image 5 - Padel compétition
  static const String tournament5 = '$_sb/tournaments/tournament5.webp';

  /// Tournoi image 6 - Padel action
  static const String tournament6 = '$_sb/tournaments/tournament6.webp';

  /// Tournoi detail header
  static const String tournamentDetail = '$_sb/tournaments/detail.webp';

  // ---------------------------------------------------------------------------
  // Replays - PADEL match thumbnails
  // ---------------------------------------------------------------------------

  /// Replay thumbnail 1
  static const String replay1 = '$_sb/replays/replay1.webp';

  /// Replay thumbnail 2
  static const String replay2 = '$_sb/replays/replay2.webp';

  /// Replay thumbnail 3
  static const String replay3 = '$_sb/replays/replay3.webp';

  /// Replay thumbnail 4
  static const String replay4 = '$_sb/replays/replay4.webp';

  // ---------------------------------------------------------------------------
  // Welcome / Splash - PADEL themed
  // ---------------------------------------------------------------------------

  /// Welcome screen hero image - Court de padel
  static const String welcomeHero = '$_sb/welcome/hero.webp';

  // ---------------------------------------------------------------------------
  // Contact - Localisation PADEL
  // ---------------------------------------------------------------------------

  /// Contact map/location image - Vue d'un club de padel
  static const String contactLocation = '$_sb/contact/location.webp';

  // ---------------------------------------------------------------------------
  // Favorites - PADEL courts
  // ---------------------------------------------------------------------------

  /// Favorite court 1
  static const String favoriteCourt1 = '$_sb/favorites/court1.webp';

  /// Favorite court 2
  static const String favoriteCourt2 = '$_sb/favorites/court2.webp';

  /// Favorite event 1
  static const String favoriteEvent1 = '$_sb/favorites/event1.webp';

  /// Favorite event 2
  static const String favoriteEvent2 = '$_sb/favorites/event2.webp';

  // ---------------------------------------------------------------------------
  // About - Team placeholders (generic avatars)
  // ---------------------------------------------------------------------------

  /// Team member avatar 1
  static const String teamMember1 = '$_sb/team/member1.webp';

  /// Team member avatar 2
  static const String teamMember2 = '$_sb/team/member2.webp';

  /// Team member avatar 3
  static const String teamMember3 = '$_sb/team/member3.webp';

  // ---------------------------------------------------------------------------
  // Favorites - Player avatars (generic)
  // ---------------------------------------------------------------------------

  /// Player avatar 1
  static const String playerAvatar1 = '$_sb/players/avatar1.webp';

  /// Player avatar 2
  static const String playerAvatar2 = '$_sb/players/avatar2.webp';

  /// Player avatar 3
  static const String playerAvatar3 = '$_sb/players/avatar3.webp';

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Generates a Supabase storage URL for a given asset path.
  /// Example: `AppImages.storageUrl('onboarding/reservation.webp')`
  static String storageUrl(String path) => '$_sb/$path';
}
