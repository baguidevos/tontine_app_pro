# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2025-12-22

### Added
- **Authentication System**
  - Implemented `AuthService` with Firebase Auth integration.
  - Created `VendorModel` and `CustomerModel` with Firestore serialization.
  - Added `VendorRepository` for managing business accounts.
  - Implemented `AuthController` handling login, registration, and logout.
  - Created UI pages: `SplashPage` (auto-routing), `LoginPage`, `RegistrationPage`.

- **Core Business Logic (Controllers & Repositories)**
  - **Waves**: `WaveModel`, `WaveRepository`, `WaveController` with CRUD and subscription limit checks.
  - **Products**: `ProductModel`, `ProductRepository`, `ProductController` with duplication feature and vendor filtering.
  - **Orders**: `OrderModel`, `OrderRepository`, `OrderController` for multi-item order management.
  - **Payments**: `PaymentTransactionModel`, `PaymentRepository`, `PaymentController` for granular item-level tracking and history.
  - **Customers**: `CustomerRepository` and `CustomerController` for vendor-isolated customer management.

- **UI & Experience**
  - **Dashboard**: Created `DashboardPage` displaying subscription status, key statistics (Revenue, Debt, Waves), and quick actions.
  - **Navigation**: Implemented `MainLayout` with bottom navigation bar and reactive routing.
  - **Connectivity**: Added `ConnectivityService` and a global `ConnectivityOverlay` to warn users when offline.
  - **Design**: Established `AppTheme` with a soft, modern aesthetic (pastel colors, rounded corners).

- **Subscription System**
  - Implemented `SubscriptionService` to enforce plan limits (Free vs Premium).
  - Added `SubscriptionLimitDialog` to prompt upgrades when limits are reached.

- **Configuration**
  - **Android**: 
    - Updated `applicationId` to `com.zashcode.tontine_pro` to match `google-services.json`.
    - Applied `com.google.gms.google-services` plugin in `build.gradle.kts`.
    - Refactored Kotlin package structure to `com/zashcode/tontine_pro`.
  - **Firebase**: configured safe initialization in `main.dart`.

### Fixed
- Resolved `INSTALL_FAILED_UPDATE_INCOMPATIBLE` by aligning Android package structure with the Application ID.
- Fixed `CardTheme` type mismatch in `AppTheme`.
- Fixed `AuthService` initialization crash when Google Services config is missing in dev environment.

### Changed
- Refactored `main.dart` to use GetX `getPages` for named routing.
- Updated project structure to follow Clean Architecture principles.

## [0.1.1] - 2025-12-22 (Afternoon Session)

### Added
- **Dashboard Enhancements**
  - Created `DashboardController` for real-time statistics aggregation (monthly revenue, pending debt, active waves, total orders).
  - Implemented `MainLayoutController` to manage global navigation state across tabs.
  - Statistics now update dynamically based on orders and waves data.

### Changed
- **OrderDetailsPage Refactoring**
  - Replaced `CustomScrollView` and `ListView.builder` with `SingleChildScrollView` + `Column` for more stable layout.
  - Added comprehensive null safety checks for all `OrderModel` and `OrderItemModel` properties.
  - Simplified widget tree to avoid infinite width constraint errors.
  - Removed redundant null checks based on model guarantees.

### Known Issues
- **Dashboard Layout Errors** 
  - `BoxConstraints forces an infinite width` errors persist on Dashboard.
  - Recent Orders section temporarily disabled to isolate layout issues.
  - Application requires layout debugging for Recent Orders tile component.
- **OrderDetailsPage Lints**
  - Dead code warning at line 100 needs cleanup.
  - Redundant null check operators to be removed.
