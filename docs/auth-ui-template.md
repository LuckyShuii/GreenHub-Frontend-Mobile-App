# Auth UI Template - GreenHub

## Objectif

Mettre en place une base d'authentification UI-only (sans backend) pour Flutter, avec:

- une landing page;
- un ecran de connexion;
- un ecran d'inscription;
- une navigation go_router;
- un design system Dart (equivalent a du CSS reutilisable).

## Ce qui a ete implemente

### 1. Bootstrap applicatif

- `lib/main.dart`
  - point d'entree simplifie;
  - lance `GreenHubApp`.

- `lib/app/app.dart`
  - `MaterialApp.router`;
  - branche le theme global;
  - branche la config go_router.

### 2. Routing

- `lib/app/router.dart`
  - routes:
    - `/` -> landing;
    - `/login` -> connexion;
    - `/register` -> inscription.

### 3. Ecrans Auth

- `lib/features/auth/screens/landing_page.dart`
  - hero + message;
  - cartes de benefices;
  - CTA Se connecter / S'inscrire.

- `lib/features/auth/screens/login_page.dart`
  - formulaire email + mot de passe;
  - validation locale minimale;
  - navigation vers inscription.

- `lib/features/auth/screens/register_page.dart`
  - formulaire nom + email + mot de passe;
  - validation locale minimale;
  - navigation vers connexion.

### 4. Design system (equivalent CSS)

- `lib/shared/theme/app_colors.dart`
  - palette couleur + gradient principal.

- `lib/shared/theme/app_spacing.dart`
  - echelle d'espacements.

- `lib/shared/theme/app_radii.dart`
  - rayons de bordure.

- `lib/shared/theme/app_shadows.dart`
  - ombres standard.

- `lib/shared/theme/app_text_styles.dart`
  - styles texte reutilisables.

- `lib/shared/theme/app_theme.dart`
  - `ThemeData` global (Material 3 + input styles).

### 5. Composants UI reutilisables

- `lib/shared/widgets/auth_primary_button.dart`
- `lib/shared/widgets/auth_secondary_button.dart`
- `lib/shared/widgets/auth_text_field.dart`

Ces widgets permettent de garder un style coherent sans repetition.

### 6. Dependances et test

- `pubspec.yaml`
  - ajout de `go_router`.

- `test/widget_test.dart`
  - test adapte au nouveau flux (presence des boutons auth sur landing).

## Comment utiliser / modifier le style

Le style est centralise dans `lib/shared/theme`.

1. Couleurs
- modifier `AppColors` pour impacter toute l'app.

2. Espacements
- ajuster `AppSpacing` au lieu de valeurs en dur.

3. Typographie
- modifier `AppTextStyles` pour un changement global.

4. Bordures/ombres
- ajuster `AppRadii` et `AppShadows` pour harmoniser toutes les cartes/boutons.

## Limites actuelles

Template UI uniquement:

- pas d'auth backend;
- pas de token/session;
- pas de stockage securise;
- pas de social login.

Les actions de submit affichent volontairement un `SnackBar` de simulation.

## Prochaine etape pour une auth reelle

1. Creer `lib/features/auth/services/auth_service.dart`.
2. Brancher Firebase Auth / Supabase / API custom.
3. Remplacer les `SnackBar` par de vrais appels d'auth.
4. Ajouter un etat global de session (Provider/Riverpod/BLoC).
5. Ajouter une route protegee post-login (ex: `/home`).

## Commandes utiles

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
