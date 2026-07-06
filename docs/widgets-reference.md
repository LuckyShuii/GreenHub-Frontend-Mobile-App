# Référence des widgets

Ce document liste les widgets custom actuellement présents dans le projet, avec leur rôle, leurs paramètres et l'endroit où ils sont utilisés.

## Vue d'ensemble

| Widget | Type | Fichier | Utilité |
|---|---|---|---|
| `GreenHubApp` | `StatelessWidget` | `lib/app/app.dart` | Point d'entrée UI de l'application. Configure `MaterialApp.router`, le thème global et le routeur. |
| `LandingPage` | `StatelessWidget` | `lib/features/auth/screens/landing_page.dart` | Page d'accueil de l'authentification (landing). Sert de première route utilisateur. |
| `_BenefitRow` | `StatelessWidget` (privé) | `lib/features/auth/screens/landing_page.dart` | Ligne utilitaire pour afficher un avantage avec une icône + texte. |
| `LoginPage` | `StatefulWidget` | `lib/features/auth/screens/login_page.dart` | Écran de connexion avec formulaire, validation locale et action simulée. |
| `RegisterPage` | `StatefulWidget` | `lib/features/auth/screens/register_page.dart` | Écran d'inscription avec formulaire, validation locale et action simulée. |
| `AuthPrimaryButton` | `StatelessWidget` | `lib/shared/widgets/auth_primary_button.dart` | Bouton principal de CTA pour les actions auth (style plein). |
| `AuthSecondaryButton` | `StatelessWidget` | `lib/shared/widgets/auth_secondary_button.dart` | Bouton secondaire de CTA (style contour). |
| `AuthTextField` | `StatelessWidget` | `lib/shared/widgets/auth_text_field.dart` | Champ de saisie réutilisable pour les formulaires auth. |

## Détail par widget

### 1) `GreenHubApp`
- Fichier: `lib/app/app.dart`
- Rôle:
  - Instancie `MaterialApp.router`.
  - Active le thème `AppTheme.light`.
  - Branche le routeur `appRouter`.
- Intérêt:
  - Centralise les réglages globaux de l'application (navigation + style).

### 2) `LandingPage`
- Fichier: `lib/features/auth/screens/landing_page.dart`
- Rôle:
  - Écran d'entrée des parcours auth.
  - Affiche le branding et les CTA vers connexion/inscription.
- Navigation:
  - Utilise `context.push(AppRoutes.login)`.
  - Utilise `context.push(AppRoutes.register)`.
- Remarque:
  - La page est actuellement simplifiée (conteneur de fond). Le widget `_BenefitRow` est défini dans ce fichier pour la version complète de la landing.

### 3) `_BenefitRow` (privé)
- Fichier: `lib/features/auth/screens/landing_page.dart`
- Rôle:
  - Composant de ligne d'avantage (icône validation + texte).
- Paramètres:
  - `text` (obligatoire): texte descriptif de l'avantage.
- Utilisation:
  - Interne à la landing page (non exporté hors fichier).

### 4) `LoginPage`
- Fichier: `lib/features/auth/screens/login_page.dart`
- Rôle:
  - Formulaire de connexion avec `Form` + `GlobalKey<FormState>`.
  - Validation locale des champs email/mot de passe.
  - Affiche un `SnackBar` de simulation de connexion.
- Widgets réutilisés:
  - `AuthTextField`
  - `AuthPrimaryButton`
- Navigation croisée:
  - Lien vers l'inscription avec `context.go(AppRoutes.register)`.

### 5) `RegisterPage`
- Fichier: `lib/features/auth/screens/register_page.dart`
- Rôle:
  - Formulaire d'inscription (nom, email, mot de passe).
  - Validation locale.
  - Affiche un `SnackBar` de simulation d'inscription.
- Widgets réutilisés:
  - `AuthTextField`
  - `AuthPrimaryButton`
- Navigation croisée:
  - Lien vers la connexion avec `context.go(AppRoutes.login)`.

### 6) `AuthPrimaryButton`
- Fichier: `lib/shared/widgets/auth_primary_button.dart`
- Rôle:
  - CTA principal en pleine largeur.
  - Applique un style cohérent (couleur, rayon, ombre, typo).
- Paramètres:
  - `label` (obligatoire): texte du bouton.
  - `onPressed` (obligatoire): callback de l'action.

### 7) `AuthSecondaryButton`
- Fichier: `lib/shared/widgets/auth_secondary_button.dart`
- Rôle:
  - CTA secondaire en pleine largeur.
  - Style `OutlinedButton` avec fond blanc et bordure.
- Paramètres:
  - `label` (obligatoire): texte du bouton.
  - `onPressed` (obligatoire): callback de l'action.

### 8) `AuthTextField`
- Fichier: `lib/shared/widgets/auth_text_field.dart`
- Rôle:
  - Encapsule un `TextFormField` pour uniformiser les formulaires auth.
- Paramètres:
  - `label` (obligatoire)
  - `hint` (obligatoire)
  - `controller` (obligatoire)
  - `obscureText` (optionnel, défaut `false`)
  - `keyboardType` (optionnel)
  - `validator` (optionnel)

## Navigation associée aux widgets

Fichier: `lib/app/router.dart`

- `/` -> `LandingPage`
- `/login` -> `LoginPage`
- `/register` -> `RegisterPage`

## Non-widgets utiles (contexte)

Ces classes ne sont pas des widgets, mais elles supportent directement leur fonctionnement visuel et navigation:
- `AppRoutes` (`lib/app/router.dart`): constantes de routes.
- `appRouter` (`lib/app/router.dart`): configuration GoRouter.
- `AppTheme` (`lib/shared/theme/app_theme.dart`): thème global utilisé par `GreenHubApp`.

## Checklist maintenance

Quand un nouveau widget est ajouté:
1. Lister son fichier et son rôle dans ce document.
2. Préciser ses paramètres publics.
3. Indiquer où il est utilisé.
4. Ajouter/mettre à jour les routes si applicable.
