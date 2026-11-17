import SwiftUI

// MARK: - Supported App Languages

public enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case spanish    = "es"
    case english    = "en"
    case french     = "fr"
    case german     = "de"
    case portuguese = "pt"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .spanish:    return "Español"
        case .english:    return "English"
        case .french:     return "Français"
        case .german:     return "Deutsch"
        case .portuguese: return "Português"
        }
    }

    public var localizedName: String {
        switch self {
        case .spanish:    return "Español (España / América Latina)"
        case .english:    return "English (US / UK)"
        case .french:     return "Français (France / Canada)"
        case .german:     return "Deutsch (Deutschland / Österreich)"
        case .portuguese: return "Português (Brasil / Portugal)"
        }
    }

    public var flagSymbol: String {
        switch self {
        case .spanish:    return "ES"
        case .english:    return "EN"
        case .french:     return "FR"
        case .german:     return "DE"
        case .portuguese: return "PT"
        }
    }
}

// MARK: - LocalizationManager (@Observable Single Source of Truth)

@Observable
public final class LocalizationManager: @unchecked Sendable {
    public static let shared = LocalizationManager()

    public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "smartbot_app_language")
        }
    }

    public init() {
        let savedLang = UserDefaults.standard.string(forKey: "smartbot_app_language")
        if let savedLang = savedLang, let lang = AppLanguage(rawValue: savedLang) {
            self.currentLanguage = lang
        } else {
            // Detección automática por locale del sistema
            let preferred = Locale.preferredLanguages.first ?? "es"
            if preferred.hasPrefix("en") {
                self.currentLanguage = .english
            } else if preferred.hasPrefix("fr") {
                self.currentLanguage = .french
            } else if preferred.hasPrefix("de") {
                self.currentLanguage = .german
            } else if preferred.hasPrefix("pt") {
                self.currentLanguage = .portuguese
            } else {
                self.currentLanguage = .spanish
            }
        }
    }

    // MARK: - String Dictionary Translation Engine

    public func localized(_ key: String) -> String {
        if let table = localizedStrings[currentLanguage], let val = table[key] {
            return val
        }
        // Fallback a Español o la misma clave
        if let fallback = localizedStrings[.spanish]?[key] {
            return fallback
        }
        return key
    }

    public func format(_ key: String, _ args: CVarArg...) -> String {
        let formatString = localized(key)
        return String(format: formatString, arguments: args)
    }

    // MARK: - Dictionary of Complete Localized Strings (5 Languages)

    private let localizedStrings: [AppLanguage: [String: String]] = [
        .spanish: [
            // General & App
            "app_name": "SmartBot Browser",
            "app_tagline": "Navegación Líquida y Privada de Próxima Generación",
            "cancel": "Cancelar",
            "done": "Listo",
            "save": "Guardar",
            "edit": "Editar",
            "delete": "Eliminar",
            "back": "Atrás",
            "forward": "Adelante",
            "reload": "Recargar",
            "close": "Cerrar",
            "continue": "Continuar",
            "start": "Comenzar",
            "skip": "Omitir",
            "confirm": "Confirmar",
            "search_placeholder": "Buscar o escribir URL",
            "copy": "Copiar",
            "copied": "Copiado",

            // Onboarding 5 Pasos
            "onboarding_step1_title": "Selecciona tu Idioma",
            "onboarding_step1_sub": "SmartBot Browser adaptará toda su interfaz en tiempo real.",
            "onboarding_step2_title": "Crea tu Primer Perfil",
            "onboarding_step2_sub": "Personaliza tu identidad para mantener pestañas y búsquedas organizadas.",
            "onboarding_step2_name_label": "¿Cómo te llamas?",
            "onboarding_step2_name_placeholder": "Tu nombre",
            "onboarding_step2_age_label": "¿Cuál es tu edad?",
            "onboarding_step2_age_placeholder": "Ej. 25",
            "onboarding_step2_color_label": "Color de Perfil",
            "onboarding_step2_desc_label": "Descripción opcional",
            "onboarding_step2_desc_placeholder": "Ej. Navegación personal diaria",
            "onboarding_step3_title": "Elige tu Apariencia",
            "onboarding_step3_sub": "Cristal líquido puro adaptado a la luz de tu entorno.",
            "onboarding_theme_light": "Modo Claro Blanco",
            "onboarding_theme_light_desc": "Cristal esmerilado blanco con contraste negro nítido.",
            "onboarding_theme_dark": "Modo Oscuro Negro",
            "onboarding_theme_dark_desc": "Cristal negro ahumado con reflejos especulares de 0.5pt.",
            "onboarding_theme_system": "Automático del Sistema",
            "onboarding_theme_system_desc": "Cambia suavemente según la hora solar de iOS.",
            "onboarding_step4_title": "Motor de Búsqueda",
            "onboarding_step4_sub": "Elige el motor predeterminado para tus búsquedas en la barra inteligente.",
            "onboarding_search_google": "Google",
            "onboarding_search_google_desc": "El índice web más extenso y rápido del mundo.",
            "onboarding_search_duck": "DuckDuckGo",
            "onboarding_search_duck_desc": "Búsquedas privadas sin rastreo ni perfilado publicitario.",
            "onboarding_search_brave": "Brave Search",
            "onboarding_search_brave_desc": "Índice web independiente centrado en privacidad estricta.",
            "onboarding_search_ecosia": "Ecosia",
            "onboarding_search_ecosia_desc": "El buscador ecológico que planta árboles con tus búsquedas.",
            "onboarding_step5_title": "Seguridad y Bloqueo",
            "onboarding_step5_sub": "Protege tus pestañas, historial y contraseñas con biometría o PIN.",
            "onboarding_security_bio_enable": "Activar autenticación biométrica",
            "onboarding_security_pin_enable": "Configurar PIN de 4 dígitos",
            "onboarding_security_skip": "Continuar sin bloqueo",
            "welcome_title": "Bienvenido a SmartBot Browser",

            // Lock Screen
            "lock_title": "SmartBot Browser Protegido",
            "lock_subtitle_faceid": "Usa Face ID para desbloquear tu sesión",
            "lock_subtitle_touchid": "Usa Touch ID para desbloquear tu sesión",
            "lock_subtitle_pin": "Introduce tu PIN de 4 dígitos",
            "lock_enter_pin": "Introduce el PIN de acceso",
            "lock_pin_incorrect": "PIN incorrecto. Vuelve a intentarlo.",
            "lock_unlock_button": "Desbloquear",
            "lock_use_pin": "Usar PIN de respaldo",
            "lock_use_biometrics": "Usar Biometría",

            // Safari Bottom Bar & Navigation
            "bar_search_url": "Buscar o escribir URL",
            "bar_tabs": "Pestañas",
            "bar_new_tab": "Nueva pestaña",
            "bar_tools": "Herramientas",
            "bar_share": "Compartir",
            "bar_reload": "Recargar página",
            "bar_stop": "Detener carga",

            // Dashboard & Home
            "home_greeting_morning": "Buenos días, %@",
            "home_greeting_afternoon": "Buenas tardes, %@",
            "home_greeting_evening": "Buenas noches, %@",
            "home_recent_searches": "Búsquedas recientes",
            "home_saved_sites": "Páginas guardadas",
            "home_add_saved_site": "Añadir página favorita",
            "home_clear_searches": "Limpiar historial",
            "home_no_searches": "No hay búsquedas recientes todavía",
            "home_quick_launch": "Acceso Rápido",

            // SSL & Security Inspector
            "ssl_inspector_title": "Seguridad del Sitio",
            "ssl_secure_connection": "Conexión cifrada y verificada",
            "ssl_insecure_connection": "Sitio no seguro: tus datos pueden ser interceptados",
            "ssl_domain": "Dominio",
            "ssl_protocol": "Protocolo TLS",
            "ssl_cipher": "Cifrado",
            "ssl_issuer": "Emisor del Certificado",
            "ssl_validity": "Validez",
            "ssl_trusted": "Certificado Raíz Confiable de Apple",
            "ssl_untrusted": "Certificado No Confiable o Autofirmado",
            "ssl_anti_tracker": "Escudo Anti-Espías y Rastreadores",
            "ssl_anti_tracker_desc": "Bloquea cookies de terceros y huellas digitales en este dominio.",
            "ssl_learn_more": "Más información sobre seguridad SSL/TLS",

            // Anti-Tracker Engine
            "tracker_shield_active": "Escudo de Protección Activo",
            "tracker_blocked_session": "Rastreadores bloqueados en esta sesión",
            "tracker_blocked_page": "Rastreadores bloqueados en esta página",
            "tracker_cookie_shield": "Bloqueo estricto de cookies de terceros",
            "tracker_fingerprint_shield": "Prevención de huella digital Canvas/WebGL",
            "tracker_adblock": "Filtro de anuncios molestos y redirecciones",

            // Password Vault
            "vault_title": "Bóveda de Contraseñas",
            "vault_search_placeholder": "Buscar sitios o usuarios...",
            "vault_new_credential": "Nueva Contraseña",
            "vault_site": "Sitio web o Dominio",
            "vault_username": "Usuario o Correo",
            "vault_password": "Contraseña",
            "vault_generate_password": "Generar contraseña segura",
            "vault_copied_password": "¡Contraseña copiada al portapapeles!",
            "vault_empty": "No hay contraseñas guardadas en la bóveda",
            "vault_locked_message": "Autentícate para acceder a tus contraseñas cifradas",

            // Profiles & Spaces
            "profile_title": "Perfiles de Navegación",
            "profile_switch": "Cambiar Perfil",
            "profile_new": "Nuevo Perfil",
            "profile_edit": "Editar Perfil",
            "profile_name": "Nombre del perfil",
            "profile_color": "Color distintivo",
            "profile_has_pin": "Proteger con PIN propio",
            "spaces_title": "Espacios",
            "space_new": "Nuevo Espacio",
            "space_pin_first": "Fijar al principio",
            "space_move_tab": "Mover pestaña aquí",
            "space_rename": "Renombrar espacio",
            "space_delete": "Eliminar espacio",

            // Settings & Factory Reset
            "settings_title": "Ajustes",
            "settings_general": "General",
            "settings_language": "Idioma de la interfaz",
            "settings_theme": "Apariencia y Cristal",
            "settings_search_engine": "Motor de búsqueda",
            "settings_security": "Seguridad y Biometría",
            "settings_privacy": "Privacidad y Rastreadores",
            "settings_passwords": "Bóveda de Contraseñas",
            "settings_credits": "Acerca de y Créditos",
            "settings_reset_zone": "Zona de Restablecimiento",
            "settings_factory_reset": "Restablecer SmartBot Browser de fábrica",
            "settings_factory_reset_warning": "Esta acción borrará de forma irreversible todos los perfiles, historial, marcadores, contraseñas en bóveda y configuraciones, volviendo a la pantalla de bienvenida inicial.",
            "settings_factory_reset_confirm": "Sí, borrar y restablecer todo",

            // Credits
            "credits_title": "Acerca de SmartBot Browser",
            "credits_lead": "Arquitectura de Navegación Líquida Nativa en Swift",
            "credits_author_label": "Diseñado y Desarrollado por",
            "credits_author_name": "Rubén Aguilarte",
            "credits_tech_title": "Tecnología y Privacidad",
            "credits_tech_desc": "Diseñado con los más altos estándares de calidad de Apple: SwiftUI, WebKit con aislamiento de memoria de procesos, aceleración Metal y cifrado de hardware mediante iOS Secure Enclave."
        ],

        .english: [
            "app_name": "SmartBot Browser",
            "app_tagline": "Next-Generation Liquid & Private Web Browsing",
            "cancel": "Cancel",
            "done": "Done",
            "save": "Save",
            "edit": "Edit",
            "delete": "Delete",
            "back": "Back",
            "forward": "Forward",
            "reload": "Reload",
            "close": "Close",
            "continue": "Continue",
            "start": "Get Started",
            "skip": "Skip",
            "confirm": "Confirm",
            "search_placeholder": "Search or enter website name",
            "copy": "Copy",
            "copied": "Copied",

            "onboarding_step1_title": "Choose your Language",
            "onboarding_step1_sub": "SmartBot Browser dynamically adapts its entire interface in real-time.",
            "onboarding_step2_title": "Create your Profile",
            "onboarding_step2_sub": "Personalize your identity to keep tabs, history, and searches organized.",
            "onboarding_step2_name_label": "What is your name?",
            "onboarding_step2_name_placeholder": "Your name",
            "onboarding_step2_age_label": "What is your age?",
            "onboarding_step2_age_placeholder": "e.g. 25",
            "onboarding_step2_color_label": "Profile Color Accent",
            "onboarding_step2_desc_label": "Optional description",
            "onboarding_step2_desc_placeholder": "e.g. Everyday personal browsing",
            "onboarding_step3_title": "Select Appearance",
            "onboarding_step3_sub": "Pure liquid glass tuned to your ambient lighting conditions.",
            "onboarding_theme_light": "Crisp Light Mode",
            "onboarding_theme_light_desc": "Frosted white glass with rich, deep black typography.",
            "onboarding_theme_dark": "Deep Dark Mode",
            "onboarding_theme_dark_desc": "Smoked obsidian glass with 0.5pt specular reflections.",
            "onboarding_theme_system": "System Match",
            "onboarding_theme_system_desc": "Smoothly transitions with your iOS system solar schedule.",
            "onboarding_step4_title": "Default Search Engine",
            "onboarding_step4_sub": "Select your preferred engine for instant smart-bar queries.",
            "onboarding_search_google": "Google",
            "onboarding_search_google_desc": "The most extensive and fastest web index on earth.",
            "onboarding_search_duck": "DuckDuckGo",
            "onboarding_search_duck_desc": "Private web queries with zero tracking or user profiling.",
            "onboarding_search_brave": "Brave Search",
            "onboarding_search_brave_desc": "Independent search index built around strict privacy.",
            "onboarding_search_ecosia": "Ecosia",
            "onboarding_search_ecosia_desc": "Eco-friendly search engine that plants trees as you search.",
            "onboarding_step5_title": "Security & App Lock",
            "onboarding_step5_sub": "Safeguard your tabs, history, and credentials with biometrics or PIN.",
            "onboarding_security_bio_enable": "Enable biometric authentication",
            "onboarding_security_pin_enable": "Configure 4-digit PIN code",
            "onboarding_security_skip": "Proceed without lock",
            "welcome_title": "Welcome to SmartBot Browser",

            "lock_title": "SmartBot Browser Locked",
            "lock_subtitle_faceid": "Use Face ID to resume your browsing session",
            "lock_subtitle_touchid": "Use Touch ID to resume your browsing session",
            "lock_subtitle_pin": "Enter your 4-digit security PIN",
            "lock_enter_pin": "Enter access PIN",
            "lock_pin_incorrect": "Incorrect PIN. Please try again.",
            "lock_unlock_button": "Unlock",
            "lock_use_pin": "Use Backup PIN",
            "lock_use_biometrics": "Use Biometrics",

            "bar_search_url": "Search or enter website name",
            "bar_tabs": "Tabs",
            "bar_new_tab": "New Tab",
            "bar_tools": "Tools",
            "bar_share": "Share",
            "bar_reload": "Reload page",
            "bar_stop": "Stop loading",

            "home_greeting_morning": "Good morning, %@",
            "home_greeting_afternoon": "Good afternoon, %@",
            "home_greeting_evening": "Good evening, %@",
            "home_recent_searches": "Recent searches",
            "home_saved_sites": "Saved bookmarks",
            "home_add_saved_site": "Add favorite website",
            "home_clear_searches": "Clear search history",
            "home_no_searches": "No recent queries found",
            "home_quick_launch": "Quick Launch",

            "ssl_inspector_title": "Website Security",
            "ssl_secure_connection": "Encrypted & Verified Connection",
            "ssl_insecure_connection": "Unencrypted site: your data may be intercepted",
            "ssl_domain": "Domain",
            "ssl_protocol": "TLS Protocol",
            "ssl_cipher": "Cipher Suite",
            "ssl_issuer": "Certificate Authority",
            "ssl_validity": "Validity Period",
            "ssl_trusted": "Apple Trusted Root Certificate",
            "ssl_untrusted": "Untrusted or Self-Signed Certificate",
            "ssl_anti_tracker": "Anti-Spy & Tracker Shield",
            "ssl_anti_tracker_desc": "Blocks third-party cookies and fingerprinting on this domain.",
            "ssl_learn_more": "Learn more about SSL/TLS security",

            "tracker_shield_active": "Protective Shield Active",
            "tracker_blocked_session": "Trackers blocked in this session",
            "tracker_blocked_page": "Trackers blocked on this page",
            "tracker_cookie_shield": "Strict third-party cookie isolation",
            "tracker_fingerprint_shield": "Canvas and WebGL fingerprint prevention",
            "tracker_adblock": "Invasive pop-up and redirect blocker",

            "vault_title": "Password Vault",
            "vault_search_placeholder": "Search sites or accounts...",
            "vault_new_credential": "New Password",
            "vault_site": "Website or Domain",
            "vault_username": "Username or Email",
            "vault_password": "Password",
            "vault_generate_password": "Generate secure password",
            "vault_copied_password": "Password copied to clipboard!",
            "vault_empty": "No credentials stored in vault",
            "vault_locked_message": "Authenticate to access encrypted passwords",

            "profile_title": "Browsing Profiles",
            "profile_switch": "Switch Profile",
            "profile_new": "New Profile",
            "profile_edit": "Edit Profile",
            "profile_name": "Profile name",
            "profile_color": "Accent color",
            "profile_has_pin": "Protect with dedicated PIN",
            "spaces_title": "Spaces",
            "space_new": "New Space",
            "space_pin_first": "Pin to front",
            "space_move_tab": "Move tab here",
            "space_rename": "Rename space",
            "space_delete": "Delete space",

            "settings_title": "Settings",
            "settings_general": "General",
            "settings_language": "Interface Language",
            "settings_theme": "Appearance & Glass",
            "settings_search_engine": "Search Engine",
            "settings_security": "Security & Biometrics",
            "settings_privacy": "Privacy & Tracker Shield",
            "settings_passwords": "Password Vault",
            "settings_credits": "About & Credits",
            "settings_reset_zone": "Reset Zone",
            "settings_factory_reset": "Factory Reset SmartBot Browser",
            "settings_factory_reset_warning": "This will irreversibly purge all profiles, tabs, history, saved passwords, and preferences, restoring initial setup.",
            "settings_factory_reset_confirm": "Yes, purge and reset everything",

            "credits_title": "About SmartBot Browser",
            "credits_lead": "Native Swift Liquid Navigation Architecture",
            "credits_author_label": "Designed and Engineered by",
            "credits_author_name": "Rubén Aguilarte",
            "credits_tech_title": "Technology & Security",
            "credits_tech_desc": "Built following Apple's highest engineering benchmarks: SwiftUI, WebKit process isolation, Metal GPU acceleration, and iOS Secure Enclave hardware encryption."
        ],

        .french: [
            "app_name": "SmartBot Browser",
            "app_tagline": "Navigation Web Liquide et Privée de Nouvelle Génération",
            "cancel": "Annuler",
            "done": "Terminé",
            "save": "Enregistrer",
            "edit": "Modifier",
            "delete": "Supprimer",
            "back": "Retour",
            "forward": "Suivant",
            "reload": "Recharger",
            "close": "Fermer",
            "continue": "Continuer",
            "start": "Commencer",
            "skip": "Ignorer",
            "confirm": "Confirmer",
            "search_placeholder": "Rechercher ou entrer un site",
            "copy": "Copier",
            "copied": "Copié",

            "onboarding_step1_title": "Choisissez votre langue",
            "onboarding_step1_sub": "SmartBot Browser adapte toute son interface en temps réel.",
            "onboarding_step2_title": "Créez votre profil",
            "onboarding_step2_sub": "Personnalisez votre identité pour organiser vos onglets et recherches.",
            "onboarding_step2_name_label": "Comment vous appelez-vous ?",
            "onboarding_step2_name_placeholder": "Votre nom",
            "onboarding_step2_age_label": "Quel est votre âge ?",
            "onboarding_step2_age_placeholder": "Ex. 25",
            "onboarding_step2_color_label": "Couleur du profil",
            "onboarding_step2_desc_label": "Description optionnelle",
            "onboarding_step2_desc_placeholder": "Ex. Navigation quotidienne",
            "onboarding_step3_title": "Sélectionnez l'apparence",
            "onboarding_step3_sub": "Verre liquide pur adapté à la lumière ambiante.",
            "onboarding_theme_light": "Mode Clair Blanc",
            "onboarding_theme_light_desc": "Verre blanc dépoli avec typographie noire nette.",
            "onboarding_theme_dark": "Mode Sombre Noir",
            "onboarding_theme_dark_desc": "Verre noir fumé avec reflets spéculaires fins de 0.5pt.",
            "onboarding_theme_system": "Automatique du système",
            "onboarding_theme_system_desc": "S'adapte au rythme solaire de votre appareil iOS.",
            "onboarding_step4_title": "Moteur de recherche",
            "onboarding_step4_sub": "Choisissez le moteur par défaut pour la barre d'adresse.",
            "onboarding_search_google": "Google",
            "onboarding_search_google_desc": "L'index web le plus vaste et rapide au monde.",
            "onboarding_search_duck": "DuckDuckGo",
            "onboarding_search_duck_desc": "Recherches privées sans suivi ni profilage publicitaire.",
            "onboarding_search_brave": "Brave Search",
            "onboarding_search_brave_desc": "Index indépendant axé sur la confidentialité stricte.",
            "onboarding_search_ecosia": "Ecosia",
            "onboarding_search_ecosia_desc": "Le moteur écologique qui plante des arbres avec vos recherches.",
            "onboarding_step5_title": "Sécurité et verrouillage",
            "onboarding_step5_sub": "Protégez vos onglets et mots de passe avec Face ID ou code PIN.",
            "onboarding_security_bio_enable": "Activer l'authentification biométrique",
            "onboarding_security_pin_enable": "Configurer un code PIN à 4 chiffres",
            "onboarding_security_skip": "Continuer sans verrouillage",
            "welcome_title": "Bienvenue sur SmartBot Browser",

            "lock_title": "SmartBot Browser Verrouillé",
            "lock_subtitle_faceid": "Utilisez Face ID pour déverrouiller votre session",
            "lock_subtitle_touchid": "Utilisez Touch ID pour déverrouiller votre session",
            "lock_subtitle_pin": "Entrez votre code PIN de sécurité",
            "lock_enter_pin": "Code PIN d'accès",
            "lock_pin_incorrect": "Code PIN incorrect. Veuillez réessayer.",
            "lock_unlock_button": "Déverrouiller",
            "lock_use_pin": "Utiliser le code PIN",
            "lock_use_biometrics": "Utiliser la biométrie",

            "bar_search_url": "Rechercher ou entrer un site",
            "bar_tabs": "Onglets",
            "bar_new_tab": "Nouvel onglet",
            "bar_tools": "Outils",
            "bar_share": "Partager",
            "bar_reload": "Recharger la page",
            "bar_stop": "Arrêter le chargement",

            "home_greeting_morning": "Bonjour, %@",
            "home_greeting_afternoon": "Bon après-midi, %@",
            "home_greeting_evening": "Bonsoir, %@",
            "home_recent_searches": "Recherches récentes",
            "home_saved_sites": "Sites enregistrés",
            "home_add_saved_site": "Ajouter un site favori",
            "home_clear_searches": "Effacer l'historique",
            "home_no_searches": "Aucune recherche récente",
            "home_quick_launch": "Accès Rapide",

            "ssl_inspector_title": "Sécurité du Site",
            "ssl_secure_connection": "Connexion chiffrée et vérifiée",
            "ssl_insecure_connection": "Site non sécurisé : vos données peuvent être interceptées",
            "ssl_domain": "Domaine",
            "ssl_protocol": "Protocole TLS",
            "ssl_cipher": "Suite de chiffrement",
            "ssl_issuer": "Autorité de certification",
            "ssl_validity": "Période de validité",
            "ssl_trusted": "Certificat racine de confiance Apple",
            "ssl_untrusted": "Certificat non fiable ou auto-signé",
            "ssl_anti_tracker": "Bouclier anti-espions et traqueurs",
            "ssl_anti_tracker_desc": "Bloque les cookies tiers et le pistage sur ce domaine.",
            "ssl_learn_more": "En savoir plus sur la sécurité SSL/TLS",

            "tracker_shield_active": "Bouclier de protection actif",
            "tracker_blocked_session": "Traqueurs bloqués cette session",
            "tracker_blocked_page": "Traqueurs bloqués sur cette page",
            "tracker_cookie_shield": "Blocage strict des cookies tiers",
            "tracker_fingerprint_shield": "Prévention des empreintes Canvas et WebGL",
            "tracker_adblock": "Bloqueur de publicités intrusives",

            "vault_title": "Coffre-fort de Mots de Passe",
            "vault_search_placeholder": "Rechercher des comptes...",
            "vault_new_credential": "Nouveau Mot de Passe",
            "vault_site": "Site web ou Domaine",
            "vault_username": "Identifiant ou Email",
            "vault_password": "Mot de passe",
            "vault_generate_password": "Générer un mot de passe sécurisé",
            "vault_copied_password": "Mot de passe copié dans le presse-papier !",
            "vault_empty": "Aucun identifiant enregistré",
            "vault_locked_message": "Authentifiez-vous pour accéder au coffre-fort",

            "profile_title": "Profils de Navigation",
            "profile_switch": "Changer de profil",
            "profile_new": "Nouveau profil",
            "profile_edit": "Modifier le profil",
            "profile_name": "Nom du profil",
            "profile_color": "Couleur d'accent",
            "profile_has_pin": "Protéger par code PIN dédié",
            "spaces_title": "Espaces",
            "space_new": "Nouvel espace",
            "space_pin_first": "Épingler en tête",
            "space_move_tab": "Déplacer l'onglet ici",
            "space_rename": "Renommer l'espace",
            "space_delete": "Supprimer l'espace",

            "settings_title": "Réglages",
            "settings_general": "Général",
            "settings_language": "Langue de l'interface",
            "settings_theme": "Apparence et Verre Liquide",
            "settings_search_engine": "Moteur de recherche",
            "settings_security": "Sécurité et Biométrie",
            "settings_privacy": "Confidentialité et Traqueurs",
            "settings_passwords": "Coffre-fort",
            "settings_credits": "À propos et Crédits",
            "settings_reset_zone": "Zone de Réinitialisation",
            "settings_factory_reset": "Réinitialiser aux paramètres d'usine",
            "settings_factory_reset_warning": "Cette action supprimera irréversiblement tous vos profils, historique, mots de passe et réglages.",
            "settings_factory_reset_confirm": "Oui, tout effacer et réinitialiser",

            "credits_title": "À propos de SmartBot Browser",
            "credits_lead": "Architecture de Navigation Liquide Native en Swift",
            "credits_author_label": "Conçu et Développé par",
            "credits_author_name": "Rubén Aguilarte",
            "credits_tech_title": "Technologie et Sécurité",
            "credits_tech_desc": "Conçu selon les exigences d'ingénierie d'Apple : SwiftUI, isolation des processus WebKit, accélération Metal et chiffrement Secure Enclave."
        ],

        .german: [
            "app_name": "SmartBot Browser",
            "app_tagline": "Flüssiges & Privates Web-Browsing der nächsten Generation",
            "cancel": "Abbrechen",
            "done": "Fertig",
            "save": "Speichern",
            "edit": "Bearbeiten",
            "delete": "Löschen",
            "back": "Zurück",
            "forward": "Vorwärts",
            "reload": "Neu laden",
            "close": "Schließen",
            "continue": "Weiter",
            "start": "Starten",
            "skip": "Überspringen",
            "confirm": "Bestätigen",
            "search_placeholder": "Suchen oder Website eingeben",
            "copy": "Kopieren",
            "copied": "Kopiert",

            "onboarding_step1_title": "Sprache wählen",
            "onboarding_step1_sub": "SmartBot Browser passt die gesamte Benutzeroberfläche in Echtzeit an.",
            "onboarding_step2_title": "Profil erstellen",
            "onboarding_step2_sub": "Organisiere deine Tabs, Chronik und Suchanfragen nach Lebensbereichen.",
            "onboarding_step2_name_label": "Wie heißt du?",
            "onboarding_step2_name_placeholder": "Dein Name",
            "onboarding_step2_age_label": "Wie alt bist du?",
            "onboarding_step2_age_placeholder": "z. B. 25",
            "onboarding_step2_color_label": "Profilfarbe",
            "onboarding_step2_desc_label": "Optionale Beschreibung",
            "onboarding_step2_desc_placeholder": "z. B. Tägliches Surfen",
            "onboarding_step3_title": "Erscheinungsbild wählen",
            "onboarding_step3_sub": "Flüssiges Glas, perfekt abgestimmt auf deine Lichtverhältnisse.",
            "onboarding_theme_light": "Heller Modus",
            "onboarding_theme_light_desc": "Mattiertes weißes Glas mit tiefschwarzer Typografie.",
            "onboarding_theme_dark": "Dunkler Modus",
            "onboarding_theme_dark_desc": "Rauchiges Obsidian-Glas mit feinen 0.5pt Reflexionen.",
            "onboarding_theme_system": "Systemstandard",
            "onboarding_theme_system_desc": "Passt sich dem automatischen iOS-Tag-Nacht-Rhythmus an.",
            "onboarding_step4_title": "Standardsuchmaschine",
            "onboarding_step4_sub": "Wähle deine bevorzugte Suchmaschine für die intelligente Adressleiste.",
            "onboarding_search_google": "Google",
            "onboarding_search_google_desc": "Der weltweit größte und schnellste Web-Index.",
            "onboarding_search_duck": "DuckDuckGo",
            "onboarding_search_duck_desc": "Private Suchen ohne Tracking und Werbeprofile.",
            "onboarding_search_brave": "Brave Search",
            "onboarding_search_brave_desc": "Unabhängiger Index mit Fokus auf strikte Privatsphäre.",
            "onboarding_search_ecosia": "Ecosia",
            "onboarding_search_ecosia_desc": "Die umweltfreundliche Suchmaschine, die Bäume pflanzt.",
            "onboarding_step5_title": "Sicherheit & Sperre",
            "onboarding_step5_sub": "Schütze deine Daten mit biometrischer Authentifizierung oder PIN.",
            "onboarding_security_bio_enable": "Biometrische Entsperrung aktivieren",
            "onboarding_security_pin_enable": "4-stellige PIN einrichten",
            "onboarding_security_skip": "Ohne Sperre fortfahren",
            "welcome_title": "Willkommen bei SmartBot Browser",

            "lock_title": "SmartBot Browser Gesperrt",
            "lock_subtitle_faceid": "Verwende Face ID zum Entsperren deiner Sitzung",
            "lock_subtitle_touchid": "Verwende Touch ID zum Entsperren deiner Sitzung",
            "lock_subtitle_pin": "Gib deine 4-stellige Sicherheits-PIN ein",
            "lock_enter_pin": "Zugangs-PIN eingeben",
            "lock_pin_incorrect": "Falsche PIN. Bitte erneut versuchen.",
            "lock_unlock_button": "Entsperren",
            "lock_use_pin": "Ersatz-PIN nutzen",
            "lock_use_biometrics": "Biometrie nutzen",

            "bar_search_url": "Suchen oder Website eingeben",
            "bar_tabs": "Tabs",
            "bar_new_tab": "Neuer Tab",
            "bar_tools": "Werkzeuge",
            "bar_share": "Teilen",
            "bar_reload": "Seite neu laden",
            "bar_stop": "Laden anhalten",

            "home_greeting_morning": "Guten Morgen, %@",
            "home_greeting_afternoon": "Guten Tag, %@",
            "home_greeting_evening": "Guten Abend, %@",
            "home_recent_searches": "Letzte Suchanfragen",
            "home_saved_sites": "Gespeicherte Lesezeichen",
            "home_add_saved_site": "Favoriten-Website hinzufügen",
            "home_clear_searches": "Suchverlauf löschen",
            "home_no_searches": "Bisher keine letzten Suchanfragen",
            "home_quick_launch": "Schnellzugriff",

            "ssl_inspector_title": "Website-Sicherheit",
            "ssl_secure_connection": "Verschlüsselte & verifizierte Verbindung",
            "ssl_insecure_connection": "Unsichere Website: Daten können abgefangen werden",
            "ssl_domain": "Domain",
            "ssl_protocol": "TLS-Protokoll",
            "ssl_cipher": "Verschlüsselungssuite",
            "ssl_issuer": "Zertifizierungsstelle",
            "ssl_validity": "Gültigkeitszeitraum",
            "ssl_trusted": "Vertrauenswürdiges Apple Root-Zertifikat",
            "ssl_untrusted": "Nicht vertrauenswürdiges Zertifikat",
            "ssl_anti_tracker": "Anti-Spionage & Tracker-Schild",
            "ssl_anti_tracker_desc": "Blockiert Drittanbieter-Cookies und Fingerprinting auf dieser Domain.",
            "ssl_learn_more": "Mehr über SSL/TLS-Sicherheit erfahren",

            "tracker_shield_active": "Schutzschild aktiv",
            "tracker_blocked_session": "Blockierte Tracker in dieser Sitzung",
            "tracker_blocked_page": "Blockierte Tracker auf dieser Seite",
            "tracker_cookie_shield": "Strikte Drittanbieter-Cookie-Blockierung",
            "tracker_fingerprint_shield": "Canvas- & WebGL-Fingerprinting verhindert",
            "tracker_adblock": "Aufdringliche Werbe- und Weiterleitungsblocker",

            "vault_title": "Passwort-Tresor",
            "vault_search_placeholder": "Konten durchsuchen...",
            "vault_new_credential": "Neues Passwort",
            "vault_site": "Website oder Domain",
            "vault_username": "Benutzername oder E-Mail",
            "vault_password": "Passwort",
            "vault_generate_password": "Sicheres Passwort generieren",
            "vault_copied_password": "Passwort in die Zwischenablage kopiert!",
            "vault_empty": "Keine Passwörter im Tresor hinterlegt",
            "vault_locked_message": "Authentifizieren, um auf Passwörter zuzugreifen",

            "profile_title": "Browsing-Profile",
            "profile_switch": "Profil wechseln",
            "profile_new": "Neues Profil",
            "profile_edit": "Profil bearbeiten",
            "profile_name": "Profilname",
            "profile_color": "Akzentfarbe",
            "profile_has_pin": "Mit eigener PIN schützen",
            "spaces_title": "Spaces",
            "space_new": "Neuer Space",
            "space_pin_first": "Ganz oben anheften",
            "space_move_tab": "Tab hierher verschieben",
            "space_rename": "Space umbenennen",
            "space_delete": "Space löschen",

            "settings_title": "Einstellungen",
            "settings_general": "Allgemein",
            "settings_language": "Sprache",
            "settings_theme": "Erscheinungsbild & Glas",
            "settings_search_engine": "Suchmaschine",
            "settings_security": "Sicherheit & Biometrie",
            "settings_privacy": "Datenschutz & Tracker",
            "settings_passwords": "Passwort-Tresor",
            "settings_credits": "Über & Mitwirkende",
            "settings_reset_zone": "Zurücksetzen",
            "settings_factory_reset": "SmartBot Browser auf Werkseinstellungen zurücksetzen",
            "settings_factory_reset_warning": "Dies löscht unwiderruflich alle Profile, Tabs, Chronik, Passwörter und Einstellungen.",
            "settings_factory_reset_confirm": "Ja, alles löschen und zurücksetzen",

            "credits_title": "Über SmartBot Browser",
            "credits_lead": "Native flüssige Swift-Browser-Architektur",
            "credits_author_label": "Entworfen und entwickelt von",
            "credits_author_name": "Rubén Aguilarte",
            "credits_tech_title": "Technologie & Sicherheit",
            "credits_tech_desc": "Entwickelt nach den höchsten Qualitätsstandards von Apple: SwiftUI, WebKit-Prozessisolation, Metal-GPU-Beschleunigung und Secure Enclave-Verschlüsselung."
        ],

        .portuguese: [
            "app_name": "SmartBot Browser",
            "app_tagline": "Navegação Web Líquida e Privada de Próxima Geração",
            "cancel": "Cancelar",
            "done": "Concluído",
            "save": "Salvar",
            "edit": "Editar",
            "delete": "Excluir",
            "back": "Voltar",
            "forward": "Avançar",
            "reload": "Recarregar",
            "close": "Fechar",
            "continue": "Continuar",
            "start": "Começar",
            "skip": "Pular",
            "confirm": "Confirmar",
            "search_placeholder": "Pesquisar ou digitar endereço",
            "copy": "Copiar",
            "copied": "Copiado",

            "onboarding_step1_title": "Selecione seu Idioma",
            "onboarding_step1_sub": "O SmartBot Browser adapta toda a interface em tempo real.",
            "onboarding_step2_title": "Crie seu Perfil",
            "onboarding_step2_sub": "Personalize sua identidade para manter abas e pesquisas organizadas.",
            "onboarding_step2_name_label": "Qual é o seu nome?",
            "onboarding_step2_name_placeholder": "Seu nome",
            "onboarding_step2_age_label": "Qual é a sua idade?",
            "onboarding_step2_age_placeholder": "Ex. 25",
            "onboarding_step2_color_label": "Cor do Perfil",
            "onboarding_step2_desc_label": "Descrição opcional",
            "onboarding_step2_desc_placeholder": "Ex. Navegação pessoal diária",
            "onboarding_step3_title": "Escolha a Aparência",
            "onboarding_step3_sub": "Vidro líquido puro adaptado à luz do ambiente.",
            "onboarding_theme_light": "Modo Claro Branco",
            "onboarding_theme_light_desc": "Vidro fosco branco com contraste preto nítido.",
            "onboarding_theme_dark": "Modo Escuro Negro",
            "onboarding_theme_dark_desc": "Vidro negro fumê com reflexos especulares finos de 0.5pt.",
            "onboarding_theme_system": "Automático do Sistema",
            "onboarding_theme_system_desc": "Muda suavemente de acordo com o horário solar do iOS.",
            "onboarding_step4_title": "Mecanismo de Busca",
            "onboarding_step4_sub": "Escolha o buscador padrão para pesquisas rápidas na barra.",
            "onboarding_search_google": "Google",
            "onboarding_search_google_desc": "O índice web mais rápido e extenso do mundo.",
            "onboarding_search_duck": "DuckDuckGo",
            "onboarding_search_duck_desc": "Pesquisas privadas sem rastreamento nem perfis publicitários.",
            "onboarding_search_brave": "Brave Search",
            "onboarding_search_brave_desc": "Índice independente focado em privacidade rigorosa.",
            "onboarding_search_ecosia": "Ecosia",
            "onboarding_search_ecosia_desc": "O buscador ecológico que planta árvores com suas pesquisas.",
            "onboarding_step5_title": "Segurança e Bloqueio",
            "onboarding_step5_sub": "Proteja suas abas, histórico e senhas com biometria ou PIN.",
            "onboarding_security_bio_enable": "Ativar autenticação biométrica",
            "onboarding_security_pin_enable": "Configurar código PIN de 4 dígitos",
            "onboarding_security_skip": "Continuar sem bloqueio",
            "welcome_title": "Bem-vindo ao SmartBot Browser",

            "lock_title": "SmartBot Browser Bloqueado",
            "lock_subtitle_faceid": "Use o Face ID para retomar sua sessão",
            "lock_subtitle_touchid": "Use o Touch ID para retomar sua sessão",
            "lock_subtitle_pin": "Digite seu PIN de 4 dígitos",
            "lock_enter_pin": "Digite o PIN de acesso",
            "lock_pin_incorrect": "PIN incorreto. Tente novamente.",
            "lock_unlock_button": "Desbloquear",
            "lock_use_pin": "Usar PIN de recuperação",
            "lock_use_biometrics": "Usar Biometria",

            "bar_search_url": "Pesquisar ou digitar endereço",
            "bar_tabs": "Abas",
            "bar_new_tab": "Nova Aba",
            "bar_tools": "Ferramentas",
            "bar_share": "Compartilhar",
            "bar_reload": "Recarregar página",
            "bar_stop": "Parar carregamento",

            "home_greeting_morning": "Bom dia, %@",
            "home_greeting_afternoon": "Boa tarde, %@",
            "home_greeting_evening": "Boa noite, %@",
            "home_recent_searches": "Pesquisas recentes",
            "home_saved_sites": "Páginas salvas",
            "home_add_saved_site": "Adicionar site favorito",
            "home_clear_searches": "Limpar histórico",
            "home_no_searches": "Nenhuma pesquisa recente ainda",
            "home_quick_launch": "Acesso Rápido",

            "ssl_inspector_title": "Segurança do Site",
            "ssl_secure_connection": "Conexão criptografada e verificada",
            "ssl_insecure_connection": "Site não seguro: seus dados podem ser interceptados",
            "ssl_domain": "Domínio",
            "ssl_protocol": "Protocolo TLS",
            "ssl_cipher": "Cifra de Criptografia",
            "ssl_issuer": "Autoridade Certificadora",
            "ssl_validity": "Período de Validade",
            "ssl_trusted": "Certificado Raiz Confiável da Apple",
            "ssl_untrusted": "Certificado não confiável ou autoassinado",
            "ssl_anti_tracker": "Escudo Anti-Espiões e Rastreadores",
            "ssl_anti_tracker_desc": "Bloqueia cookies de terceiros e impressão digital neste domínio.",
            "ssl_learn_more": "Saiba mais sobre segurança SSL/TLS",

            "tracker_shield_active": "Escudo de Proteção Ativo",
            "tracker_blocked_session": "Rastreadores bloqueados nesta sessão",
            "tracker_blocked_page": "Rastreadores bloqueados nesta página",
            "tracker_cookie_shield": "Isolamento estrito de cookies de terceiros",
            "tracker_fingerprint_shield": "Prevenção de impressão digital Canvas e WebGL",
            "tracker_adblock": "Bloqueador de anúncios invasivos",

            "vault_title": "Cofre de Senhas",
            "vault_search_placeholder": "Pesquisar contas...",
            "vault_new_credential": "Nova Senha",
            "vault_site": "Site ou Domínio",
            "vault_username": "Usuário ou E-mail",
            "vault_password": "Senha",
            "vault_generate_password": "Gerar senha segura",
            "vault_copied_password": "Senha copiada para a área de transferência!",
            "vault_empty": "Nenhuma credencial salva no cofre",
            "vault_locked_message": "Autentique-se para acessar as senhas criptografadas",

            "profile_title": "Perfis de Navegação",
            "profile_switch": "Trocar Perfil",
            "profile_new": "Novo Perfil",
            "profile_edit": "Editar Perfil",
            "profile_name": "Nome do perfil",
            "profile_color": "Cor de destaque",
            "profile_has_pin": "Proteger com PIN exclusivo",
            "spaces_title": "Espaços",
            "space_new": "Novo Espaço",
            "space_pin_first": "Fixar no topo",
            "space_move_tab": "Mover aba para cá",
            "space_rename": "Renomear espaço",
            "space_delete": "Excluir espaço",

            "settings_title": "Ajustes",
            "settings_general": "Geral",
            "settings_language": "Idioma da interface",
            "settings_theme": "Aparência e Vidro Líquido",
            "settings_search_engine": "Mecanismo de busca",
            "settings_security": "Segurança e Biometria",
            "settings_privacy": "Privacidade e Rastreadores",
            "settings_passwords": "Cofre de Senhas",
            "settings_credits": "Sobre e Créditos",
            "settings_reset_zone": "Zona de Redefinição",
            "settings_factory_reset": "Restaurar SmartBot Browser para os padrões de fábrica",
            "settings_factory_reset_warning": "Esta ação excluirá irrevogavelmente todos os perfis, abas, histórico, senhas e ajustes.",
            "settings_factory_reset_confirm": "Sim, apagar e restaurar tudo",

            "credits_title": "Sobre o SmartBot Browser",
            "credits_lead": "Arquitetura de Navegação Líquida Nativa em Swift",
            "credits_author_label": "Projetado e Desenvolvido por",
            "credits_author_name": "Rubén Aguilarte",
            "credits_tech_title": "Tecnologia e Segurança",
            "credits_tech_desc": "Construído de acordo com os mais altos padrões da Apple: SwiftUI, isolamento de processos WebKit, aceleração Metal e criptografia Secure Enclave."
        ]
    ]
}

// MARK: - Global Convenience Helper

public enum Loc {
    public static func tr(_ key: String) -> String {
        LocalizationManager.shared.localized(key)
    }

    public static func format(_ key: String, _ args: CVarArg...) -> String {
        LocalizationManager.shared.format(key, args)
    }
}
