# Employee Management App

A production-ready Flutter Employee Management application built with **Clean Architecture**, **BLoC state management**, **Firebase Authentication**, **REST API integration**, and **offline caching**.

Designed and engineered following enterprise Flutter best practices and scalable architecture patterns.

---

## 📱 Features

- **Splash & Initialization**
  - Custom animated splash screen with logo transitions
  - Auto-checks authentication state and routes seamlessly to Login or Dashboard

- **Authentication & Security**
  - Firebase Authentication with Email & Password (Sign In, Register, Forgot Password, Sign Out)
  - Google Sign-In with seamless credential handling
  - Reactive Auth State routing guard with GoRouter
  - Form validation with real-time feedback (regex-based email, minimum password length, password matching, 10-digit mobile)

- **Employee Management (CRUD)**
  - **Read**: Browse employees with responsive card grid / list layout
  - **Search**: Search employee by unique ID directly via API
  - **Filter**: Expandable filter panel with multi-field filtering (Name, Email, Mobile, Country)
  - **Create**: Add new employees with dynamic country selection fetched from MockAPI
  - **Update**: Edit existing employee details with pre-populated form values
  - **Delete**: Safe deletion with custom destructive confirmation dialog

- **Offline Support & Resilience**
  - Local caching via SharedPreferences
  - Transparent fallback to cached data when remote API fails or device is offline
  - Dynamic in-app offline status banner

- **Theming & Responsiveness**
  - Theme switching (Light & Dark mode) persisted across sessions
  - Adaptive UI supporting Mobile, Tablet, and Desktop screen widths
  - Zero overflow design with responsive wraps and flex constraints

---

## 🏗️ Architecture & Folder Structure

Following Clean Architecture principles with separation of concerns:

```
lib/
├── app.dart                          # App root with MultiBlocProvider & MaterialApp.router
├── locator.dart                      # Dependency injection (GetIt) registration
├── main.dart                         # Initialization (Firebase, DI) & runApp
├── application/                      # BLoC / State Management Layer
│   ├── auth/                         # AuthBloc, AuthEvent, AuthState
│   ├── employee/                     # EmployeeBloc, EmployeeEvent, EmployeeState
│   └── theme/                        # ThemeBloc, ThemeEvent, ThemeState
├── domain/                           # Pure Business Domain Layer
│   ├── auth/
│   │   ├── entities/app_user.dart
│   │   └── repository/i_auth_repository.dart
│   ├── core/
│   │   ├── error/failures.dart & exceptions.dart
│   │   ├── network/network_info.dart
│   │   └── validators/validators.dart
│   └── employee/
│       ├── entities/employee.dart & country.dart
│       └── repository/i_employee_repository.dart
├── infrastructure/                   # Data & External Implementations
│   ├── auth/
│   │   ├── data_source/auth_remote.dart
│   │   └── repository/auth_repository.dart
│   ├── core/
│   │   └── network/api_client.dart (Dio with logging & error interceptors)
│   └── employee/
│       ├── data_source/employee_remote.dart & employee_local.dart
│       ├── dtos/employee_dto.dart & country_dto.dart
│       └── repository/employee_repository.dart
└── presentation/                     # UI Presentation Layer
    ├── auth/                         # Login, Register, Forgot Password screens
    ├── splash/                       # Animated splash screen with auth routing
    ├── core/                         # Reusable design system widgets & themes
    │   ├── theme/app_colors.dart, text_styles.dart, app_theme.dart
    │   └── widgets/app_text_field.dart, primary_button.dart, loading_view.dart,
    │               error_view.dart, empty_state_view.dart, confirmation_dialog.dart,
    │               employee_card.dart, app_drawer.dart
    ├── employee/                     # EmployeeListScreen, EmployeeDetailScreen, EmployeeFormScreen
    │   └── widget/employee_search_bar.dart, employee_filter.dart
    └── route/                        # router.dart (GoRouter with auth guard)
```

---

## 🌐 API Contract, Error Handling & Offline Strategy

### MockAPI Contract & Endpoints
The application connects to a cloud-hosted REST API on MockAPI (`https://669b3f09276e45187d34eb4e.mockapi.io`):

| Method | Endpoint | Description | Request Body | Response Code |
|---|---|---|---|---|
| `GET` | `/api/v1/country` | Retrieve all available countries | None | `200 OK` |
| `GET` | `/api/v1/employee` | Retrieve full employee roster | None | `200 OK` |
| `GET` | `/api/v1/employee/:id` | Fetch single employee by unique ID | None | `200 OK` / `404 Not Found` |
| `POST` | `/api/v1/employee` | Create a new employee entry | JSON `EmployeeDto` | `201 Created` / `400 Bad Request` |
| `PUT` | `/api/v1/employee/:id` | Update existing employee profile | JSON `EmployeeDto` | `200 OK` / `400 Bad Request` |
| `DELETE` | `/api/v1/employee/:id` | Delete employee record permanently | None | `200 OK` / `404 Not Found` |

### Rate Limiting & Timeout Configuration
- **Rate Limiting**: Public MockAPI endpoints enforce a tier limit of 100 requests per minute per IP address. The application implements debounce filters on client-side search queries (300ms) to prevent unnecessary network load.
- **Connection & Read Timeouts**: All HTTP requests managed via `HttpService` enforce strict 15-second timeouts (`connectTimeout: 15s`, `receiveTimeout: 15s`, `sendTimeout: 15s`) configured through Dio `BaseOptions`.

### Error Contract & Status Code Mapping
The application encapsulates all external exceptions into strongly typed domain failures (`AppFailure`):
- `200 OK / 201 Created`: Deserialized into clean immutable domain models (`Employee`, `Country`).
- `400 Bad Request`: Mapped to `ServerFailure("Bad Request (400)")` with validation message.
- `401 Unauthorized / 403 Forbidden`: Mapped to `AuthFailure` prompting user re-authentication.
- `404 Not Found`: Mapped to `ServerFailure("Not Found (404)")` indicating resource absence.
- `429 Too Many Requests`: Mapped to `ServerFailure("Too Many Requests (429)")`.
- `5xx Internal Server Error`: Mapped to `ServerFailure("Server error (500)")`.
- `SocketException / ConnectionError`: Mapped to `NetworkFailure("No internet connection")`.
- `TimeoutException / ConnectionTimeout`: Mapped to `NetworkFailure("Connection timed out")`.

### Offline Fallback Strategy
1. **Cache-on-Success**: When `getEmployees()` completes a successful remote fetch, data is immediately serialized and persisted to device storage using `SharedPreferences`.
2. **Transparent Fallback**: When an offline or network failure occurs during `getEmployees()`, the repository seamlessly loads the cached dataset, flags `isOffline = true`, and returns the local data.
3. **Visual Feedback**: The UI detects the offline state and displays a prominent in-app offline banner with a manual retry option.

---

## 🛠️ Toolchain Compatibility Matrix

The application's build system and dependencies are verified for compatibility across modern Flutter and Android toolchains:

| Component | Pinned Version / Range | Notes & Verification |
|---|---|---|
| **Flutter SDK** | `^3.7.0` (Pinned revision: `f6ff1529fd6d8af5f706051d9251ac9231c83407`) | Verified on Flutter 3.29.0 / 3.38.5 Stable Channel |
| **Dart SDK** | `>=3.7.0 <4.0.0` | Configured in `pubspec.yaml` environment |
| **Android Gradle Plugin (AGP)** | `8.11.1` | Configured in `android/settings.gradle.kts` |
| **Kotlin Compiler** | `2.2.20` | Configured in `android/settings.gradle.kts` |
| **Gradle Distribution** | `8.14-all` | Configured in `android/gradle/wrapper/gradle-wrapper.properties` |
| **Java Development Kit (JDK)** | Java 17 | JVM target and compiler compatibility in `build.gradle.kts` |
| **Android Compile / Target SDK** | Android 35 (`flutter.compileSdkVersion`) | Latest modern Android platform target |
| **Android Min SDK** | Android 21 (`flutter.minSdkVersion`) | Fully compatible with Firebase Auth and Google Play Services |

---

## 🔐 Security & Production Release Signing

### Firebase Configuration & Secret Management
- **Client Configuration Files**: `android/app/google-services.json` and `lib/firebase_options.dart` provide client-side identification (Firebase App ID, Project ID, and client API keys) required for Firebase client SDK initialization.
- **API Key Security**: In Firebase, client API keys identify the app project and do not grant administrative backend access. Backend data security is strictly enforced through Firebase Security Rules and OAuth 2.0 token verification.
- **OAuth Fingerprints**: Google Sign-In requires SHA-1 and SHA-256 certificate fingerprints registered in the Firebase Console and Google Cloud Credentials dashboard for both Debug and Release signing certificates.

### Production Release Keystore Configuration
Production builds use a dedicated release signing configuration in `android/app/build.gradle.kts`:
- Keystore credentials are securely loaded from `android/key.properties` (which is excluded from Git via `.gitignore`).
- A reference template is provided in `android/key.properties.example`:
  ```properties
  storePassword=<your-store-password>
  keyPassword=<your-key-password>
  keyAlias=<your-key-alias>
  storeFile=<path-to-keystore.jks>
  ```
- When `key.properties` is absent in CI or local developer machines, safe fallback defaults are utilized so builds succeed without exposing production keys.

---

## 🧪 Testing

The codebase includes **73 automated tests** covering unit and widget behavior:

- **Unit Tests**:
  - `validators_test.dart`: Complete edge-case validation checks
  - `auth_bloc_test.dart`: Sign in, sign up, Google sign in, forgot password, sign out flows
  - `employee_bloc_test.dart`: Load, search, filter, create, update, delete states
  - `auth_repository_test.dart`: Remote data source to domain entity mapping & exception translation
  - `employee_repository_test.dart`: Remote fetching, local caching, cache fallback on failure
  - `google_sign_in_test.dart`: Success, user cancellation, and network error handling
- **Widget Tests**:
  - `splash_screen_test.dart`: Logo animations, app branding, loading indicator, and auth route transition
  - `login_screen_test.dart`: Form rendering, validation triggers, BLoC dispatch, loading states
  - `employee_list_screen_test.dart`: Loading indicator, error view with retry, empty state, loaded cards, offline banner
  - `delete_confirmation_test.dart`: Dialog display, cancel action, confirm action

### Running Tests

```bash
# Run all unit and widget tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run analyzer
flutter analyze
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.7.0` (Dart `^3.7.0`)
- Android Studio / Xcode for device simulation
- Firebase project configured (configured in `lib/firebase_options.dart`)

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone <repo-url>
   cd flutter-developer-as-final-83614-tushar
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify analyzer & tests**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```
