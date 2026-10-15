/// Centralized multilingual localization dictionary for the CAMSO application.
/// Supports English ('en'), French ('fr'), German ('de'), and Italian ('it').
class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation
      'nav_home': 'Home',
      'nav_products': 'Products',
      'nav_search': 'Search',
      'nav_support': 'Support',
      'nav_profile': 'Profile',

      // Headers
      'header_camso': 'CAMSO',
      'header_products': 'PRODUCTS',
      'header_search': 'SEARCH',
      'header_support': 'SUPPORT & RESOURCES',
      'header_profile': 'PROFILE',
      'header_find_dealer': 'FIND A DEALER',
      'header_share_feedback': 'SHARE FEEDBACK',
      'header_faq': 'FAQ',
      'header_bookmarks': 'MY BOOKMARKS',
      'header_product_updates': 'PRODUCT UPDATES',
      'header_notifications': 'NOTIFICATIONS',
      'header_language': 'LANGUAGE',

      // Quick Actions
      'qa_find_dealer': 'Find a Dealer',
      'qa_support_library': 'Support Library',
      'qa_submit_feedback': 'Submit Feedback',
      'qa_my_bookmarks': 'My Bookmarks',

      // Section Titles
      'sec_quick_actions': 'QUICK ACTIONS',
      'sec_support_resources': 'SUPPORT & RESOURCES',
      'sec_featured_products': 'FEATURED PRODUCTS',
      'sec_popular_categories': 'POPULAR CATEGORIES',
      'sec_browse_products': 'BROWSE PRODUCTS',
      'sec_account_portal': 'ACCOUNT & PORTAL',
      'sec_system_settings': 'SYSTEM & SETTINGS',
      'sec_role_preview': 'ROLE PREVIEW SWITCHER',

      // Profile Menu Items
      'prof_language': 'Language',
      'prof_bookmarks': 'My Bookmarks',
      'prof_product_updates': 'Product Updates',
      'prof_notifications': 'Notifications',
      'prof_about': 'About CAMSO',
      'prof_contact': 'Contact & Help',
      'prof_legal': 'Legal & Terms',
      'prof_sign_out': 'Sign Out',
      'prof_sign_in': 'SIGN IN',
      'prof_guest_title': 'Browsing as Guest',
      'prof_guest_subtitle': 'Sign in to access personalized dealer pricing, OEM manuals, and save bookmarks.',

      // Common Buttons & Labels
      'btn_call': 'Call',
      'btn_email': 'Email',
      'btn_directions': 'Directions',
      'btn_submit': 'SUBMIT',
      'btn_search': 'Search',
      'btn_retry': 'TRY AGAIN',
      'btn_cancel': 'Cancel',
      'btn_view_all': 'View All',
      'btn_reset_filter': 'Reset Filter',

      // Auth & Bookmarking Messages
      'msg_sign_in_required_bookmarks': 'Please sign in to save and manage bookmarks.',
      'msg_sign_in_required_feedback': 'Sign in required to submit feedback.',
      'msg_no_dealers_found': 'No dealers found matching your search.',
      'msg_no_bookmarks': 'No bookmarks yet',
      'msg_no_bookmarks_desc': 'Products and documents you bookmark will appear here.',
    },

    'fr': {
      // Navigation
      'nav_home': 'Accueil',
      'nav_products': 'Produits',
      'nav_search': 'Recherche',
      'nav_support': 'Support',
      'nav_profile': 'Profil',

      // Headers
      'header_camso': 'CAMSO',
      'header_products': 'PRODUITS',
      'header_search': 'RECHERCHE',
      'header_support': 'SUPPORT ET RESSOURCES',
      'header_profile': 'PROFIL',
      'header_find_dealer': 'TROUVER UN CONCESSIONNAIRE',
      'header_share_feedback': 'DONNER VOTRE AVIS',
      'header_faq': 'FAQ',
      'header_bookmarks': 'MES FAVORIS',
      'header_product_updates': 'MISES À JOUR PRODUITS',
      'header_notifications': 'NOTIFICATIONS',
      'header_language': 'LANGUE',

      // Quick Actions
      'qa_find_dealer': 'Concessionnaires',
      'qa_support_library': 'Bibliothèque Support',
      'qa_submit_feedback': 'Donner un avis',
      'qa_my_bookmarks': 'Mes favoris',

      // Section Titles
      'sec_quick_actions': 'ACTIONS RAPIDES',
      'sec_support_resources': 'SUPPORT ET RESSOURCES',
      'sec_featured_products': 'PRODUITS EN VEDETTE',
      'sec_popular_categories': 'CATÉGORIES POPULAIRES',
      'sec_browse_products': 'PARCOURIR LES PRODUITS',
      'sec_account_portal': 'COMPTE ET PORTAIL',
      'sec_system_settings': 'SYSTÈME ET PARAMÈTRES',
      'sec_role_preview': 'SÉLECTEUR DE RÔLE DÉMO',

      // Profile Menu Items
      'prof_language': 'Langue',
      'prof_bookmarks': 'Mes favoris',
      'prof_product_updates': 'Mises à jour produits',
      'prof_notifications': 'Notifications',
      'prof_about': 'À propos de CAMSO',
      'prof_contact': 'Contact et assistance',
      'prof_legal': 'Mentions légales',
      'prof_sign_out': 'Se déconnecter',
      'prof_sign_in': 'SE CONNECTER',
      'prof_guest_title': 'Navigation en invité',
      'prof_guest_subtitle': 'Connectez-vous pour voir les prix concessionnaires, guides OEM et sauvegarder vos favoris.',

      // Common Buttons & Labels
      'btn_call': 'Appeler',
      'btn_email': 'E-mail',
      'btn_directions': 'Itinéraire',
      'btn_submit': 'ENVOYER',
      'btn_search': 'Rechercher',
      'btn_retry': 'RÉESSAYER',
      'btn_cancel': 'Annuler',
      'btn_view_all': 'Voir tout',
      'btn_reset_filter': 'Réinitialiser le filtre',

      // Auth & Bookmarking Messages
      'msg_sign_in_required_bookmarks': 'Connexion requise pour sauvegarder des favoris.',
      'msg_sign_in_required_feedback': 'Connexion requise pour donner un avis.',
      'msg_no_dealers_found': 'Aucun concessionnaire trouvé.',
      'msg_no_bookmarks': 'Aucun favori pour le moment',
      'msg_no_bookmarks_desc': 'Les produits et documents enregistrés apparaîtront ici.',
    },

    'de': {
      // Navigation
      'nav_home': 'Startseite',
      'nav_products': 'Produkte',
      'nav_search': 'Suche',
      'nav_support': 'Support',
      'nav_profile': 'Profil',

      // Headers
      'header_camso': 'CAMSO',
      'header_products': 'PRODUKTE',
      'header_search': 'SUCHE',
      'header_support': 'SUPPORT & RESSOURCEN',
      'header_profile': 'PROFIL',
      'header_find_dealer': 'HÄNDLER FINDEN',
      'header_share_feedback': 'FEEDBACK GEBEN',
      'header_faq': 'FAQ',
      'header_bookmarks': 'MEINE LESEZEICHEN',
      'header_product_updates': 'PRODUKT-UPDATES',
      'header_notifications': 'BENACHRICHTIGUNGEN',
      'header_language': 'SPRACHE',

      // Quick Actions
      'qa_find_dealer': 'Händler finden',
      'qa_support_library': 'Support-Bibliothek',
      'qa_submit_feedback': 'Feedback geben',
      'qa_my_bookmarks': 'Meine Lesezeichen',

      // Section Titles
      'sec_quick_actions': 'SCHNELLZUGRIFF',
      'sec_support_resources': 'SUPPORT & RESSOURCEN',
      'sec_featured_products': 'EMPFOHLENE PRODUKTE',
      'sec_popular_categories': 'BELIEBTE KATEGORIEN',
      'sec_browse_products': 'PRODUKTE DURCHSUCHEN',
      'sec_account_portal': 'KONTO & PORTAL',
      'sec_system_settings': 'SYSTEM & EINSTELLUNGEN',
      'sec_role_preview': 'ROLLENVORSCHAU-WECHSLER',

      // Profile Menu Items
      'prof_language': 'Sprache',
      'prof_bookmarks': 'Meine Lesezeichen',
      'prof_product_updates': 'Produkt-Updates',
      'prof_notifications': 'Benachrichtigungen',
      'prof_about': 'Über CAMSO',
      'prof_contact': 'Kontakt & Hilfe',
      'prof_legal': 'Rechtliches & Bedingungen',
      'prof_sign_out': 'Abmelden',
      'prof_sign_in': 'ANMELDEN',
      'prof_guest_title': 'Als Gast surfen',
      'prof_guest_subtitle': 'Melden Sie sich an für Händlerpreise, OEM-Handbücher und Lesezeichen.',

      // Common Buttons & Labels
      'btn_call': 'Anrufen',
      'btn_email': 'E-Mail',
      'btn_directions': 'Route',
      'btn_submit': 'ABSENDEN',
      'btn_search': 'Suchen',
      'btn_retry': 'ERNEUT VERSUCHEN',
      'btn_cancel': 'Abbrechen',
      'btn_view_all': 'Alle ansehen',
      'btn_reset_filter': 'Filter zurücksetzen',

      // Auth & Bookmarking Messages
      'msg_sign_in_required_bookmarks': 'Anmeldung erforderlich, um Lesezeichen zu speichern.',
      'msg_sign_in_required_feedback': 'Anmeldung erforderlich für Feedback.',
      'msg_no_dealers_found': 'Keine Händler gefunden.',
      'msg_no_bookmarks': 'Noch keine Lesezeichen',
      'msg_no_bookmarks_desc': 'Gespeicherte Produkte und Dokumente werden hier angezeigt.',
    },

    'it': {
      // Navigation
      'nav_home': 'Home',
      'nav_products': 'Prodotti',
      'nav_search': 'Cerca',
      'nav_support': 'Supporto',
      'nav_profile': 'Profilo',

      // Headers
      'header_camso': 'CAMSO',
      'header_products': 'PRODOTTI',
      'header_search': 'CERCA',
      'header_support': 'SUPPORTO & RISORSE',
      'header_profile': 'PROFILO',
      'header_find_dealer': 'TROVA UN RIVENDITORE',
      'header_share_feedback': 'INVIA FEEDBACK',
      'header_faq': 'FAQ',
      'header_bookmarks': 'I MIEI PREFERITI',
      'header_product_updates': 'AGGIORNAMENTI PRODOTTO',
      'header_notifications': 'NOTIFICHE',
      'header_language': 'LINGUA',

      // Quick Actions
      'qa_find_dealer': 'Trova Rivenditore',
      'qa_support_library': 'Libreria Supporto',
      'qa_submit_feedback': 'Invia Feedback',
      'qa_my_bookmarks': 'I Miei Preferiti',

      // Section Titles
      'sec_quick_actions': 'AZIONI RAPIDE',
      'sec_support_resources': 'SUPPORTO & RISORSE',
      'sec_featured_products': 'PRODOTTI IN EVIDENZA',
      'sec_popular_categories': 'CATEGORIE POPOLARI',
      'sec_browse_products': 'SFOGLIA PRODOTTI',
      'sec_account_portal': 'ACCOUNT & PORTALE',
      'sec_system_settings': 'SISTEMA & IMPOSTAZIONI',
      'sec_role_preview': 'SELETTORE RUOLO DEMO',

      // Profile Menu Items
      'prof_language': 'Lingua',
      'prof_bookmarks': 'I miei preferiti',
      'prof_product_updates': 'Aggiornamenti prodotto',
      'prof_notifications': 'Notifiche',
      'prof_about': 'Informazioni su CAMSO',
      'prof_contact': 'Contatti & Assistenza',
      'prof_legal': 'Note legali & Termini',
      'prof_sign_out': 'Disconnetti',
      'prof_sign_in': 'ACCEDI',
      'prof_guest_title': 'Navigazione come Ospite',
      'prof_guest_subtitle': 'Accedi per vedere i prezzi rivenditori, manuali OEM e salvare preferiti.',

      // Common Buttons & Labels
      'btn_call': 'Chiama',
      'btn_email': 'Email',
      'btn_directions': 'Indicazioni',
      'btn_submit': 'INVIA',
      'btn_search': 'Cerca',
      'btn_retry': 'RIPROVA',
      'btn_cancel': 'Annulla',
      'btn_view_all': 'Vedi tutti',
      'btn_reset_filter': 'Reimposta filtro',

      // Auth & Bookmarking Messages
      'msg_sign_in_required_bookmarks': 'Accesso richiesto per salvare i preferiti.',
      'msg_sign_in_required_feedback': 'Accesso richiesto per inviare feedback.',
      'msg_no_dealers_found': 'Nessun rivenditore trovato.',
      'msg_no_bookmarks': 'Nessun preferito salvato',
      'msg_no_bookmarks_desc': 'I prodotti e documenti salvati appariranno qui.',
    },
  };

  /// Retrieve localized string for [key] with fallback to English.
  static String tr(String key, [String language = 'en']) {
    final langMap = _localizedValues[language] ?? _localizedValues['en']!;
    return langMap[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
