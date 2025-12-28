# Changelog

All notable changes to this project will be documented in this file.

## [0.2.1] - 2025-12-28
 
### Added
- **Enhanced Dialogs System**
  - **Waves**: Implemented a modern `CreateWaveDialog` with `AppTheme` styling, chip-based status selection, and improved responsiveness.
  - **Orders**: Created `QuantityDialog` featuring counter controls, manual input support, stock validation, and live price calculation.
  - **Confirmations**: Added reusable `ConfirmationDialog` for critical actions (cancelling orders, removing items), supporting "danger" mode styling.
  - **Payment Entry**: Created dedicated `PaymentEntryDialog` for recording partial payments with validation against remaining balance.
  - **Wave Selection**: Implemented `WaveSelectionDialog` for product duplication, offering a clean list view of available target waves.

### Changed
- **UI & UX Refinements**
  - **Wave Management**: 
    - Replaced `PopupMenuButton` in `WavesPage` with a rigorous `ModalBottomSheet` for options (Edit, Close, Delete).
    - Updated wave deletion flow to use the standardized `ConfirmationDialog`.
  - Updated `CreateOrderPage` to use the new `QuantityDialog`.
  - Updated `OrderDetailsPage` to use `ConfirmationDialog` for consistent validation flows.
  - General visual alignment with the "Premium" aesthetic (rounded corners, warm cream backgrounds, chip selectors).

## [0.2.0] - 2025-12-27

- **Profile Page Implementation**
  - Created `ProfilePage` UI with business info editing and subscription status.
  - Created `ProfileController` for handling vendor data updates and logout.
  - Added `ProfileBinding` in `lib/presentation/bindings/profil_controller.dart`.
  - Integrated `ProfilePage` as the 4th tab in `MainLayout`.
- **Order Management Enhancements**
  - Added `cancelOrder` to `OrderController` to allow marking orders as cancelled.
  - Added `removeItemFromOrder` to `OrderController` with automatic recalculation of total amounts and paid balances.
  - Added individual item deletion buttons in `OrderDetailsPage` with confirmation dialogs.
  - Added "Annuler" button in `OrderDetailsPage` header for full order cancellation.
- **Data Integrity & Validation**
  - Implemented payment validation in `PaymentController` to prevent overpayment on articles (fixes negative balance issues).
  - Added `copyWith` method to `OrderModel` for efficient state updates and immutability management.
- **Customer Retrieval**
  - Added `getCustomer(id)` helper in `CustomerController` for targeted customer data retrieval.

### Changed
- **Automated Workflow**
  - Orders now automatically switch to `completed` when fully paid.
  - Orders revert to `pending` when a payment is deleted or an item is removed (if total balance becomes positive again).
- **UI & Experience Improvements**
  - Standardized order display in `OrdersPage`: now shows `Client: [Name] (#ID)` for improved clarity.
  - Refactored `OrdersPage` filtering logic using a robust `switch` statement for better state handling across tabs.
  - Cleaned up controller initialization and variable scoping in `OrdersPage` and `CreateOrderPage`.
- **Theme & Feedback Standardization**
  - Unified snackbar notifications across multiple controllers using standard `AppTheme` colors.
  - Updated `AppTheme.successGreen` to a more vibrant and visible shade.

### Fixed
- Resolved `orderController` undefined errors in `OrdersPage` caused by scoping issues.
- Fixed multiple missing `material.dart` imports causing compilation errors.
- Fixed syntax errors and price display regressions introduced during UI refactoring of `OrderDetailsPage`.


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

## [0.1.2] - 2025-12-23

### Added
- **GetX Bindings Implementation**
  - Created `MainLayoutBinding` to centralize dependency injection for the main application shell and its tabs.
  - Created specialized bindings: `DashboardBinding`, `OrderBinding`, `InventoryBinding`, and `CustomerBinding`.
  - Integrated bindings into `GetMaterialApp` routes to automate controller lifecycle management.

### Changed
- **Dependency Management Refactor**
  - Migrated from manual `Get.put()` initialization in widgets to GetX `Bindings`.
  - Updated `MainLayout`, `DashboardPage`, `OrdersPage`, `WavesPage`, and `ProductsPage` to use `Get.find()` for controller access.
- **Code Quality**
  - Cleaned up unused imports across multiple files (`lib/main.dart`, `lib/presentation/widgets/main_layout.dart`, etc.).
  - Resolved lint warnings in page widgets.

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
