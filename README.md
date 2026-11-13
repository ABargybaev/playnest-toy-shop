# 🧸 PlayNest Toys — Flutter toy shop

A colorful **cross-platform Flutter app** (Android, iOS, Web) that communicates with a **real public HTTPS REST API** for **toy-themed products**. The app was made for a university Flutter / BLoC assignment and is separate from the NOVA Store project.

## Requirements checklist

| University requirement | Implementation |
| --- | --- |
| Cross-platform mobile app | Flutter, Android and iOS projects included; web preview available |
| App communicates with server | `Dio` sends HTTP GET to `https://randomapi.dev/api/products?category=toys` |
| GitHub | Ready to commit with `.gitignore`, README and `.github/workflows/flutter_ci.yml` (you must push it yourself) |
| State management | Four BLoCs: `CatalogBloc`, `ToyDetailBloc`, `CartBloc`, `FavoritesBloc` |
| Async | `async` / `await`, `Future`, loading/error states and pull-to-refresh |

## Features

- Beautiful purple / mint / pink pastel theme with **custom teddy-bear app icon**.
- Home banner, product cards with toy illustrations and responsive layouts.
- **Toy-only catalog** retrieved over HTTPS from a free public mock data API.
- Search by toy name, SKU or numeric demo ID.
- Filter by inferred subcategory (plush, puzzles, building blocks, vehicles, figures, educational, other).
- Sort by price and rating.
- Details view: triggers an additional asynchronous server request.
- Favorites and shopping cart controlled through BLoC.
- Increase/decrease quantity, remove items, see total.
- Friendly network errors and retry action.
- Automated model, repository, BLoC and widget tests; GitHub Actions configuration.

**Important honesty note:** This is an educational toy store, not a real commerce service. Product data is *generated mock data from a real public HTTP server*. The provider has no order/payment endpoint. Cart and favorites are stored in memory and are cleared when the application is restarted. Toy pictures are **built-in decorative emoji illustrations** because this API provides only generic placeholder images. The code does *not* pretend to place actual orders.

## API details

**Docs:** https://randomapi.dev/apis/products

**Endpoint:** `GET https://randomapi.dev/api/products`

**Query parameters:**

```
category=toys
count=36
seed=42026
currency=USD
minPrice=8
maxPrice=109
```

To verify communication, paste this URL into your browser:

https://randomapi.dev/api/products?category=toys&count=36&seed=42026&currency=USD&minPrice=8&maxPrice=109

Expected JSON structure (shortened):

```json
{
  "data": [
    {
      "name": "Example Toy Name",
      "category": "toys",
      "price": 25.0,
      "currency": "USD",
      "sku": "TOY-12345-AB",
      "rating": 4.5,
      "inStock": true,
      "imageUrl": "https://randomapi.dev/..."
    }
  ],
  "meta": { "seed": 42026 }
}
```

The toy server creates records dynamically, so the fields and numbers shown above are **illustrative**, not guaranteed to match the live request. The fixed `seed` means the catalog order is reproducible. Because the server does not offer `GET /toys/{id}` or numeric IDs, `ToyApiImpl.getToyById` performs the **same real HTTP GET again** and selects the toy with the requested 1-based demo ID. This is documented transparently and tested.

The API is a third-party service and needs an internet connection. It may be unavailable or rate limited; use the Retry button if the catalog fails. It is not hosted or controlled by the student.

## How the architecture works

```text
Flutter screen / user action
           |
           v
    BLoC event
           |
           v
    CatalogBloc / ToyDetailBloc
           |
           v
        ToyApi (repository)
           |
           v
  Dio HTTP GET + async/await
           |
           v
randomapi.dev REST server (HTTPS)
           |
           v
  JSON -> Toy.fromApi -> BLoC State
           |
           v
  BlocBuilder rebuilds Flutter UI
```

Cart and Favorites use their own BLoCs with **local state** (they don't write to the server).

### Main files

| File | Purpose |
| --- | --- |
| `lib/main.dart` | Dependency injection, BLoCs and MaterialApp |
| `lib/data/toy.dart` | Toy model, JSON parsing, category inference |
| `lib/data/toy_api.dart` | Real HTTP API, repository contract, async methods and readable errors |
| `lib/bloc/catalog_bloc.dart` | Loading, query, filter, sort, network status |
| `lib/bloc/toy_detail_bloc.dart` | Async product-by-demo-ID detail request |
| `lib/bloc/cart_bloc.dart` | Add/remove items, quantity, totals |
| `lib/bloc/favorites_bloc.dart` | Toggle favorites |
| `lib/screens/` | Catalog, details, cart, favorites, navigation |
| `lib/widgets/` | Reusable cards, illustrations, empty states |
| `test/` | Unit and widget tests, fake server responses |

## Run on Windows with Flutter

### 1. Open this exact folder in VS Code

Open the folder containing **`pubspec.yaml`** (the `PlayNest_Toy_Shop` folder).

### 2. Install Flutter dependencies

```powershell
flutter pub get
```

If Flutter is not in your Windows PATH, run the commands with the full path to the SDK installed earlier:

```powershell
& "D:\VScode projects\flutter\bin\flutter.bat" pub get
```

### 3. Launch Web preview

```powershell
flutter run -d chrome
```

Or with full SDK path:

```powershell
& "D:\VScode projects\flutter\bin\flutter.bat" run -d chrome
```

The browser will display the toy shop. Internet access is required for products to load. During `flutter run` the terminal stays busy; open a second VS Code terminal for other commands, or press `q` to stop.

### 4. Run checks

```powershell
flutter analyze --no-fatal-infos
flutter test
```

**Why `--no-fatal-infos`?** Flutter 3.50 reports informational deprecation notices for `package:flutter/material.dart`. Those are not application logic errors. All tests in `test/` use fakes and do not need network access. The two widget tests scroll down to the asynchronously rendered toy cards before interacting with them.

For a separate, optional migration to Flutter 3.50 standalone design packages, see https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui. Do not replace imports without also adding the `material_ui` dependency and re-running both checks.

### 5. Run on Android

Android SDK is required to compile; you can use a friend's computer with Flutter + Android SDK if you prefer not to install Android Studio. Connect a phone / start an emulator:

```powershell
flutter devices
flutter run
```

To build the APK:

```powershell
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`.

**iOS** requires macOS + Xcode for compilation; it is not possible to build iOS apps on Windows alone.

## Upload to a separate GitHub repository

Create an **empty** repository (for example `playnest-toy-shop`) on GitHub, without adding a README or .gitignore on GitHub. From this project folder run:

```bash
git init
git branch -M main
git add .
git commit -m "Build PlayNest toy store in Flutter with BLoC and REST API"
git remote add origin https://github.com/YOUR_USERNAME/playnest-toy-shop.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username. This is a **new repo**, independent from NOVA Store. Do not add `build/`, `.dart_tool/`, secrets, or APK binaries to Git; `.gitignore` already excludes generated folders. Open the **Actions** tab after push to inspect CI checks.

## Short defense explanation (Russian)

> PlayNest Toys — кроссплатформенное приложение на Flutter. Оно загружает список игрушек с внешнего HTTPS REST API при помощи Dio и асинхронного `await`. Для управления состоянием используются четыре BLoC. Когда пользователь открывает каталог, `CatalogBloc` посылает запрос через `ToyApi`, получает JSON и обновляет `CatalogState`. `BlocBuilder` перестраивает экран после загрузки. Поиск и фильтры работают локально по полученным данным. Экран деталей делает новый запрос; корзина и избранное управляются отдельными BLoC. Исходный код и тесты размещаются на GitHub.

### Troubleshooting

- **Cannot find Flutter:** use `flutter --version` or full path `D:\VScode projects\flutter\bin\flutter.bat`.
- **No toys loaded:** verify the API URL directly in the browser, check internet access, tap Retry; server may be temporarily unavailable.
- **Android SDK not found:** web preview works without Android SDK; compile APK on a machine with Android tools.
- **Material import info warnings:** these may appear under recent SDKs; the GitHub workflow treats *infos* as nonfatal, while genuine analyzer errors still fail.

---

PlayNest Toys — educational demo. API data © respective provider. No payments or real orders.
