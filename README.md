# GreenLeaf — exact-design Android test app

## What this version is

The `assets/index.html` file is **byte-for-byte identical** to the HTML you uploaded (`GreenLeaf_Clean_Campaigns_Smooth_Navigation.html`). SHA-256: `346570616adebe400469e3cec8a13e887d0bac89a1eaa944a55844c17ead4839`.

Unlike the prior native-widget reimplementation, this app **does not redraw the screens** with different Flutter components. A Flutter Android shell uses **one persistent local WebView** for the original HTML/CSS/JavaScript, including all tabs, original spacing/colors/icons, glass cards, billing, conversation demo, chart and original 140ms cross-fade. The WebView does not reload when changing tabs. Flutter handles Android system bars, initial loading, Android Back and the APK build.

This is a **hybrid app (Flutter + embedded WebView)** and cannot be accurately described as a fully native widget UI. It is the more visually faithful approach; it has not been performance-benchmarked on a Galaxy S25. The HTML already includes the intended smoother page transitions. All content and messaging are demo-only.

## Upload to GitHub and build APK

1. Extract the ZIP. **Do not upload the ZIP itself** to GitHub.
2. Open https://github.com/Lasar456/greenLeaf-whatsapp (or your chosen Flutter test repository).
3. Replace the existing `lib/main.dart`, `pubspec.yaml`, `assets/index.html`, and `branding` files with the extracted ones. If `assets` is not in the repository, upload it.
4. GitHub hides `.github` on Windows. In your repo, edit/create `.github/workflows/main.yml`, paste the content of `WORKFLOW_TO_PASTE_ON_GITHUB.yml`, and commit to the `main` branch. You can also upload the extracted hidden `.github` folder using a Git client.
5. GitHub -> **Actions** -> **Build GreenLeaf EXACT DESIGN APK**. The run should be triggered by the commit, or choose `Run workflow`.
6. When the run is green, open it -> **Artifacts** -> download `GreenLeaf-EXACT-DESIGN-APK` -> extract -> `app-debug.apk`.
7. Transfer `app-debug.apk` to the Samsung Galaxy S25 and install.

**Build notes:** Flutter and Android build tools are not available in this environment. The included GitHub Action compiles the APK; this ZIP is source code, not a compiled APK. GitHub Action must succeed before an APK will exist.

## Troubleshooting

- If **Artifacts** displays `—`, you probably ran a different workflow (such as `blank.yml`). Only **Build GreenLeaf EXACT DESIGN APK** uploads `GreenLeaf-EXACT-DESIGN-APK`.
- If the UI differs, ensure `assets/index.html` was replaced, not only `lib/main.dart`.
- This build has a **different Android application ID** from previous test builds to avoid conflicting debug certificates from independent GitHub runners.
