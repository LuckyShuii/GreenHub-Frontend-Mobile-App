# Lancement de l'application Flutter

Ce projet est une application Flutter.

## Installation du SDK Flutter (Windows)

Si la commande `flutter` n'est pas reconnue, installer le SDK Flutter puis l'ajouter au `PATH`.

1. Installer Git: https://git-scm.com/download/win
2. Cloner Flutter dans un dossier local (exemple `C:\Users\<votre_user>\flutter`):

```powershell
git clone https://github.com/flutter/flutter.git -b stable C:\Users\<votre_user>\flutter
```

3. Ajouter `C:\Users\<votre_user>\flutter\bin` dans la variable d'environnement `Path` (User).
4. Redemarrer VS Code (ou au minimum le terminal integre).
5. Verifier l'installation:

```powershell
flutter --version
flutter doctor
```

## Prerequis

- Installer android studio
- créer un device dans android studio (tuto : https://docs.flutter.dev/platform-integration/android/setup)
- Flutter SDK installe (`flutter --version`)
- Android SDK installe (pour Android)
- Un device/emulateur disponible (`flutter devices`) (redémarrer vscode si vous ne voyez pas le device créé)

## 1. Verifier l'environnement

```bash
flutter doctor
```

Si Android affiche une erreur sur `cmdline-tools` ou les licences:

```bash
flutter doctor --android-licenses
```

S'il y a un problème avec vscode : 

- ouvrir visual studio installer
- cliquer sur le bouton modifier
- dans l'onglet Workloads (bureau) cocher : Desktop development with C++

## 2. Installer les dependances du projet

Depuis la racine `flutter_frontend/`:

```bash
flutter pub get
```

## 3. Lancer l'application

### Lancement rapide (device par defaut)

```bash
flutter run
```

### Choisir un device cible

Lister les devices:

```bash
flutter devices
```

Lancer sur un device specifique:

```bash
flutter run -d <device_id>
```

Exemples:

```bash
flutter run -d emulator-5554
flutter run -d chrome
flutter run -d windows
```

## 4. Build de verification (optionnel)

APK debug Android:

```bash
flutter build apk --debug
```

## Depannage rapide

- Nettoyer et reinstaller les artefacts Flutter:

```bash
flutter clean
flutter pub get
flutter run
```

- Si Android ne demarre pas: verifier Android Studio + SDK Manager, puis relancer `flutter doctor`.

## Hot Reload

- Appuyer sur 'r' dans le terminal flutter

- Appuyer sur 'R' pour un redémarrage complet  