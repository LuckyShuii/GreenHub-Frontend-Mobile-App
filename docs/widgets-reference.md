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

## Accueil connecté

La page d'accueil appartient à `lib/features/home/`. `HomeScreen` assemble les
composants et branche la navigation; les widgets de présentation reçoivent des
callbacks et ne dépendent ni de la session ni du routeur.

| Composant | Fichier | Rôle et paramètres |
|---|---|---|
| `HomeScreen` | `lib/features/home/screens/home_screen.dart` | Reçoit `authSession`, charge le prénom une fois et ouvre les destinations protégées. |
| `ContentCardWidget` | `lib/shared/widgets/content_card_widget.dart` | Carte partagée pour les légumes de saison, le guide de tri et la communauté. `title`, `description`, `onTap`, `icon` existants; options `leading`, `decoration`, `padding`, `titleStyle`, `descriptionStyle`, `textAlign`, `minHeight`, `bottomAligned`, `descriptionSpacing`. Les valeurs par défaut restent inchangées. |
| `EcoProgressCardWidget` | `lib/features/home/widgets/eco_progress_card_widget.dart` | Carte verte avec les valeurs statiques de la maquette. Aucune gestion des niveaux ni requête API. |
| `HomeBottomNavigationWidget` | `lib/features/home/widgets/home_bottom_navigation_widget.dart` | Reçoit `onMap` et `onScan` asynchrones, `destination` et `enabled`. Anime uniquement le rond vert et son ombre derrière les trois icônes fixes, qui restent visibles; les gestes courts ou annulés recentrent sans navigation. |
| `HomeNavigationShellWidget` | `lib/features/home/widgets/home_navigation_shell_widget.dart` | Reçoit `child`, `destination`, les callbacks asynchrones et `isActive`. Porte une seule instance de la barre entre l'accueil, la carte et le scan; annule son temporisateur à chaque changement de destination ou destruction. |
| `PageUnderConstructionScreen` | `lib/shared/screens/page_under_construction_screen.dart` | Écran partagé par les six destinations provisoires; reçoit `onBack` et affiche « Page en construction ⚙️ ». |

Les tokens globaux restent dans `lib/shared/theme/`. Les variantes spécifiques
à la maquette sont dans `lib/features/home/theme/`: `HomeColors`, `HomeSizes`,
`HomeShadows` et `HomeTextStyles`. La police locale `HomeNunito` est réservée à
l'accueil afin de conserver le rendu des autres écrans. Les icônes Figma sont
embarquées dans `assets/icons/` sans modification des SVG d'origine. Les ombres
des deux badges sont appliquées nativement selon les métadonnées Figma car leurs
filtres SVG ne sont pas pris en charge. La police et sa licence OFL sont dans
`assets/fonts/nunito/`.

Routes privées ajoutées dans `lib/app/router.dart`:
- `/seasonal-vegetables`
- `/sorting-guide`
- `/community`
- `/map`
- `/waste-scan`
- `/settings`

Le rendu grisé de la carte communauté est uniquement visuel: elle reste
cliquable. Les destinations sont poussées dans la pile pour conserver l'accueil
et son profil au retour. La redirection après connexion et la protection des
routes continuent d'utiliser `AuthSession` et `createAppRouter`.

L'accueil, la carte et le scan partagent un `ShellRoute`. Au clic comme au
glissement, le rond vert rejoint l'icône en 200 ms, puis la destination s'ouvre.
Les logos carte, accueil et scan restent fixes et sont dessinés au-dessus du
rond; l'icône d'accueil n'intercepte pas le glissement du curseur.
La barre reste visible sur cette destination pendant deux secondes avant de se
déplacer vers le bas en 250 ms, jusqu'à sortir entièrement de l'écran, ombre et
zone de sécurité comprises. Le contenu de la page reste immobile et il n'y a pas
de fondu. Elle n'est pas interactive pendant cette
phase; le bouton retour reste disponible. Au retour à l'accueil, le temporisateur
et la sortie en cours sont annulés; la barre réapparaît à sa position habituelle
et le bouton retrouve le centre. Une autre navigation ou une fin de
session annule une sélection en cours. Les animations désactivées dans les
réglages d'accessibilité masquent directement la barre après les deux secondes,
sans translation.
Les durées restent centralisées dans `HomeSizes`.
