# Lancement de l'application Flutter

Ce projet est une application Flutter.

## Prerequis

- Installer android studio
- créer un device dans android studio (tuto youtube : https://www.youtube.com/watch?v=uiOIjyn5mG8)
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

