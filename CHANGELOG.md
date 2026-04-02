# Changelog

All notable changes to this project will be documented in this file.

## [0.5.0] - 2026-04-02

### Added
- **Rebranding to Paya**
  - New app name: "Paya - La tontine simplifiée"
  - New brand identity with modern color palette
  - Updated all references from "Tontine App Pro" to "Paya"
  - New Paya brand colors (payaBlue, payaLightBlue, payaCream, etc.)
  - Legacy color aliases maintained for backward compatibility

### Changed
- **App Identity**
  - Package name: `tontine_app` → `paya_app`
  - Android applicationId: `com.zashcode.tontine_pro` → `com.paya.app`
  - Android namespace: `com.zashcode.tontine_pro` → `com.paya.app`
  - App title: "TontineManager Pro" → "Paya"
  - Main app class: `TontineApp` → `PayaApp`

- **Theme & Design**
  - Primary brand color: Deep Blue (#1a237e)
  - Secondary color: Light Blue (#534ba6)
  - Background: Warm Cream (#faf7f0)
  - Updated all UI components to use new Paya colors
  - Maintained backward compatibility with legacy color names

### Technical
- Updated `pubspec.yaml` version to 0.5.0+8
- Updated all documentation (README, VERSIONING, BRANDING)
- Created `BRANDING_PAYA.md` with complete brand guidelines
- Created `NOMMING.md` with naming research and alternatives

---

## [0.4.0] - 2026-04-01

### Added
- **Wave-Products Linking (Many-to-Many)**
  - Added `productIds: List<String>` field to `WaveModel` for linking multiple products to waves
  - Made `waveId` optional in `ProductModel` for backward compatibility
  - Created `getProductsByIds()` and `watchProductsByIds()` in `ProductRepository` for fetching products by ID list
  - Added `addProductToWave()`, `removeProductFromWave()`, and `setWaveProducts()` in `WaveRepository`

- **Product Selection UI**
  - Created `ProductSelectionSheet` - a modern bottom sheet with multi-select product picker
  - Two-tab interface: "Produits existants" (searchable list) and "Nouveau produit"
  - Real-time selection feedback with animated checkboxes and border highlights
  - Validation button with dynamic counter showing selected items count
  - Direct navigation to product creation from the sheet

- **Wave Creation/Editing Enhancement**
  - Integrated product selection in `CreateWaveDialog`
  - Visual list of linked products with remove buttons
  - Products persist automatically when wave is created or updated

- **Wave Details Page - Products Section**
  - New "Produits liés" section displaying all products linked to a wave
  - Product cards showing name, price, and stock count
  - Add/remove products directly from wave details
  - Confirmation dialog before removing products
  - Loading spinner during product refresh for better UX
  - Empty state with helpful message when no products linked

- **Enhanced State Management**
  - Added `selectedProductIds` and `linkedProducts` reactive lists in `WaveController`
  - Methods: `setSelectedProducts()`, `addSelectedProduct()`, `removeSelectedProduct()`, `loadLinkedProducts()`
  - Proper isolation of wave-specific data to prevent cross-contamination between waves

### Changed
- **Product Creation Simplification**
  - Removed wave selection dropdown from `CreateProductPage`
  - Removed stock field (defaults to 0)
  - Products now created independently and linked to waves afterwards via wave details
  - Simplified form focuses on essentials: name, price, image
  - Updated `ProductController.createProduct()` signature: `waveId` and `stock` now optional

- **Data Architecture**
  - Migrated from single `waveId` in Product to many-to-many relationship via `productIds` in Wave
  - `setWaveProducts()` now directly updates Firestore without reading document first (prevents race conditions)
  - Exposed `productRepository` and `waveRepository` as public fields in controllers for external access

- **UX Enhancements**
  - Added loading spinner in WaveDetailsPage products section
  - Real-time product selection feedback in ProductSelectionSheet
  - Improved error handling and loading states

### Fixed
- **Critical**: All waves showing same products issue
  - Root cause: Shared `waveController.linkedProducts` state across all wave instances
  - Solution: Each `WaveDetailsPage` now maintains its own `_products` list loaded from `wave.productIds`
- **Critical**: Products not loading in Wave Details
  - Changed from `getProductsByWave(waveId)` (uses old `waveId` field) to `getProductsByIds(productIds)` (uses new `productIds` field)
- **Critical**: Wave object not updating after adding products
  - Added Firestore refresh in `_loadProducts()` to get latest `productIds` before loading products
- **UI**: BottomSheet not closing after validation
  - Changed from `Get.back()` to `Navigator.of(context).pop()` for reliable closure
- **UI**: Selection state not reflecting in real-time
  - Each product item now has its own `Obx` wrapper for immediate visual updates
- **UI**: Loading spinner not rotating
  - Added `AnimationController` with `RotationTransition` for proper spinner animation
- **State**: `LateInitializationError` in `WaveDetailsPage`
  - Changed `late final WaveModel wave` to `late WaveModel wave` to allow reassignment

### Technical Debt
- Added callback mechanism (`onProductsUpdated`) in `ProductSelectionSheet` for parent notification
- Proper separation of concerns: Wave data vs Product data loading
- Consistent use of reactive programming patterns with GetX
- Added `SingleTickerProviderStateMixin` for animation support in WaveDetailsPage

- **UI/UX Improvements**
  - **CreateOrderPage**: Fixed controller initialization conflicts
    - Changed from `Get.put()` to `Get.find()` to use binding-provided instances
    - Added loading indicator for wave dropdown while data loads
    - Proper waiting for async data before rendering dropdowns
  - **ProductSelectionSheet**: Each product item wrapped in individual `Obx` for instant visual feedback
  - **WaveDetailsPage**: Uses local `_products` list instead of shared controller state to avoid cross-wave contamination

- **Code Quality**
  - Fixed Hero tag collision in `WavesPage` by adding unique `heroTag`
  - Resolved GetX reactive state issues by using local state for wave-specific data
  - Added proper async/await handling in product loading
  - Improved error handling and loading states throughout

### Fixed
- **Critical**: All waves showing same products issue
  - Root cause: Shared `waveController.linkedProducts` state across all wave instances
  - Solution: Each `WaveDetailsPage` now maintains its own `_products` list loaded from `wave.productIds`
- **Critical**: Products not loading in Wave Details
  - Changed from `getProductsByWave(waveId)` (uses old `waveId` field) to `getProductsByIds(productIds)` (uses new `productIds` field)
- **Critical**: Wave object not updating after adding products
  - Added Firestore refresh in `_loadProducts()` to get latest `productIds` before loading products
- **UI**: BottomSheet not closing after validation
  - Changed from `Get.back()` to `Navigator.of(context).pop()` for reliable closure
- **UI**: Selection state not reflecting in real-time
  - Each product item now has its own `Obx` wrapper for immediate visual updates
- **State**: `LateInitializationError` in `WaveDetailsPage`
  - Changed `late final WaveModel wave` to `late WaveModel wave` to allow reassignment

### Technical Debt
- Added callback mechanism (`onProductsUpdated`) in `ProductSelectionSheet` for parent notification
- Proper separation of concerns: Wave data vs Product data loading
- Consistent use of reactive programming patterns with GetX

---

### Added
- **Wave-Orders Linking**
  - Added `waveId` field to `OrderModel` for linking orders to delivery waves
  - Created `getOrdersByWave()` and `watchOrdersByWave()` in `OrderRepository`
  - Added wave selection dropdown in `CreateOrderPage` (shows active waves only)
  - Wave name displayed in `OrdersPage` and `OrderDetailsPage` with wave icon

- **Wave Details Page**
  - New `WaveDetailsPage` showing all orders linked to a specific wave
  - Statistics dashboard per wave (total, paid, pending, cancelled orders)
  - Revenue tracking (collected vs remaining)
  - Empty state with "Create Order" button when no orders exist
  - Navigation from `WavesPage` to wave details on tap

- **Enhanced Navigation**
  - Added `/waves/details` route in `main.dart`
  - `OrderBinding` now covers wave details page

### Changed
- **UI/UX Improvements**
  - **Bottom Navigation Bar**: Complete redesign with custom animated items
    - Individual item backgrounds with rounded corners
    - Animated icon sizes (24px → 28px when selected)
    - Animated text sizes (11px → 13px) and font weights
    - Better visual feedback for selected tabs
  - **Orders Page**: Added quick actions section inspired by Dashboard
    - Horizontal scrollable action chips (New Client, View Clients, Waves, Stats)
    - Custom TabBar with icons (pending, completed, cancelled)
    - Search and filter buttons in AppBar (placeholders)
  - **Inventory Page**: Similar enhancements
    - Quick actions (New Wave, New Order, New Client, Stats)
    - Custom TabBar with icons (Waves, Products)
    - Search and filter buttons in AppBar

- **Profile Page Enhancement**
  - Added proper loading state management with `AuthService.isLoading`
  - Three-state UI: loading spinner, not-logged-in message, logged-in content
  - "Not Connected" state with reconnection button
  - Fixed infinite loading spinner issue

- **Code Quality**
  - Fixed Tab overflow issues with `Flexible` widgets and `TextOverflow.ellipsis`
  - Removed unused imports across multiple files
  - Fixed deprecated `withOpacity` warnings (minor)

### Fixed
- **WaveDetailsPage**: Fixed state management issues
  - Converted from `StreamBuilder` to `StatefulWidget` with local observable list
  - Eliminated cross-page side effects from shared controller state
  - Proper error handling and empty state display
- **ProfilePage**: Fixed infinite loading spinner
  - Added `isLoading` state to `AuthService`
  - Proper timeout handling for vendor data loading
  - Clear error state when vendor data unavailable

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
