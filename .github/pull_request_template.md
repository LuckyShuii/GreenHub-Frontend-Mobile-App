# PR – Greener Frontend (Flutter)

Cette Pull Request doit respecter les règles définies dans le **Plan Qualité Greener**.

Référence : [Plan Qualité / Normes de développement](https://www.notion.so/shiningmoonsunshine/PLAN-ASSURANCE-QUALIT-2f5be3249cb08033bc65ef4baaa8ba68)

---

# Description

Explique brièvement ce que fait cette PR :

- fonctionnalité ou correction
- écrans impactés
- widgets ou providers modifiés
- interaction avec l’API backend si applicable

---

# Rappels importants

## Format de branche

Les branches doivent respecter la convention suivante :

```
feature/[TRIGRAM]-[ID_TICKET]-[description]
fix/[TRIGRAM]-[ID_TICKET]-[description]
refactor/[TRIGRAM]-[ID_TICKET]-[description]
```

Exemple :

```
feature/LBT-12-scan-image-ai
```

---

## Format des commits (Conventional Commits)

Format :

```
<type>(scope): description
```

Types autorisés :

- `feat` → nouvelle fonctionnalité
- `fix` → correction de bug
- `docs` → documentation
- `style` → formatage du code
- `refactor` → refactoring sans changement fonctionnel
- `test` → ajout ou modification de tests
- `release` → préparation d'une release

---

## Normes Frontend (Flutter / Dart)

Le code Flutter doit respecter le guide **Effective Dart**.

Principales règles :

- indentation : **2 espaces**
- longueur de ligne : **80 caractères maximum**
- utiliser les **virgules finales (trailing commas)** dans les widgets multilignes
- privilégier la lisibilité des widgets imbriqués

### Nomenclature

Fichiers :

```
snake_case.dart
```

Exemples :

```
login_screen.dart
custom_button_widget.dart
auth_provider.dart
```

Classes :

```
PascalCase
```

Exemple :

```
UserDashboard
WasteScannerScreen
```

Variables / fonctions :

```
lowerCamelCase
```

Exemple :

```
isUserLoggedIn
calculateCarbonScore
```

### Privatisation

Les variables ou méthodes internes doivent commencer par `_`.

Exemple :

```
_currentStep
_loadUserProfile()
```

---

## Structure des fichiers (convention projet)

| Type             | Convention            | Exemple                     |
| ---------------- | --------------------- | --------------------------- |
| Widget           | `[nom]_widget.dart`   | `custom_button_widget.dart` |
| Screen           | `[nom]_screen.dart`   | `home_screen.dart`          |
| Provider / State | `[nom]_provider.dart` | `auth_provider.dart`        |

---

# Checklist avant merge

Avant de demander une review :

- [ ] Le code respecte les normes Flutter / Dart
- [ ] `flutter analyze` ne retourne aucune erreur
- [ ] L’application compile et fonctionne localement
- [ ] Les widgets modifiés ont été testés
- [ ] Les interactions avec l’API backend ont été vérifiées
- [ ] La CI est verte
