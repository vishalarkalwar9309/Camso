# CAMSO — Full Project Backup Repository

Comprehensive full-stack backup of the **CAMSO** application platform, containing both the production-ready Node.js Express backend and the cross-platform Flutter frontend.

---

## 1. Repository Layout

```
Camso/
├── backend/                       # Node.js Express 5 + Prisma ORM backend
│   ├── prisma/
│   │   ├── migrations/            # All 7 tracked PostgreSQL schema migrations
│   │   ├── schema.prisma          # Database schema definitions (28 models)
│   │   ├── seed.demo.js           # Multi-persona idempotent demo seeder
│   │   └── seed.js                # Initial catalogue data seed
│   ├── src/
│   │   ├── config/                # Environment, Database, Supabase, Firebase config
│   │   ├── core/                  # Security middleware, logger, storage & translation utils
│   │   ├── modules/               # Domain modules (auth, documents, products, dealers, cms)
│   │   ├── routes/                # Central API router (/api/v1/...)
│   │   └── server.js              # Server entry point with graceful shutdown
│   ├── tests/                     # 500 unit and integration tests across 47 suites
│   ├── docs/                      # Architectural specs & deployment documentation
│   ├── .env.example               # Safe template for local environment configuration
│   ├── render.yaml                # Render Web Service deployment blueprint
│   ├── Dockerfile                 # Minimal Node.js 20 Alpine container image
│   └── package.json               # Dependencies and scripts (start, build, test, seed)
│
├── frontend/                      # Flutter 3 cross-platform mobile and web client
│   ├── lib/
│   │   ├── core/                  # ApiClient, AuthService, Token handling
│   │   ├── models/                # Typed domain models (Product, Document, Dealer, User)
│   │   ├── repositories/          # Data access repositories with API integration
│   │   ├── screens/               # Complete application screens
│   │   ├── widgets/               # Reusable UI widgets and layout components
│   │   └── main.dart              # Application entry point
│   ├── test/                      # 96 widget, integration, and RBAC test cases
│   ├── android/                   # Native Android host configuration
│   ├── ios/                       # Native iOS host configuration
│   ├── web/                       # Web entry point and PWA manifest
│   ├── pubspec.yaml               # Flutter dependencies and asset definitions
│   └── analysis_options.yaml      # Static analysis rules (0 warnings)
│
├── .gitignore                     # Monorepo root ignore blocking secrets and build artifacts
└── README.md                      # Full project overview and operating guide
```

---

## 2. Key Features & Integrated Systems

### Backend (`backend/`)
* **Framework:** Express 5 on Node.js (v20+ / v24+).
* **Database & ORM:** PostgreSQL managed on Supabase with Prisma 6. Includes 7 safe migrations and 28 relational models.
* **Storage Integration:** Integrated with private Supabase Storage bucket (`Camso documents`) generating time-limited signed URLs (`expiresIn: 3600`) for authorized role-based downloads.
* **Role-Based Access Control (RBAC):** Strict guards for `END_USER`, `DEALER`, `DISTRIBUTOR`, `OEM_PARTNER`, and `ADMIN`.
* **Testing:** 100% test coverage with **500 of 500 passing tests** across 47 test suites.
* **Production Deployment:** Optimized for Render Web Service co-located in Singapore (`ap-southeast-1`) via [`render.yaml`](file:///c:/Users/visha/OneDrive/Desktop/CEAT/Camso/backend/render.yaml).

### Frontend (`frontend/`)
* **Framework:** Flutter (Web, Android, iOS, Desktop).
* **Dynamic API Targeting:** Base URL dynamically configurable via build-time flag:
  `--dart-define=API_BASE_URL=https://<hosted-backend-domain>/api/v1` (defaults to local development).
* **Features Preserved:**
  * **1-Click Fast Login:** Demo authentication supporting Admin, Dealer, Distributor, and OEM Partner personas.
  * **Interactive Dealer Locator:** OpenStreetMap & GPS nearest-dealer finder with Haversine distance calculations and search filtering.
  * **Technical Document Library:** Role-aware document viewer and secure file downloader.
  * **Offline Support:** SharedPreferences session persistence and cached document metadata.

---

## 3. Quick Start Guide

### Running the Backend Locally
```bash
cd backend
npm install
npm run build           # Generates Prisma client
cp .env.example .env    # Configure your local DATABASE_URL and JWT secrets
npm run dev             # Starts server on http://localhost:4000
npm test                # Executes the 500-test backend suite
```

### Running the Frontend Locally
```bash
cd frontend
flutter pub get
flutter test            # Executes 96 Flutter integration and widget tests
flutter run -d chrome   # Runs Flutter Web locally
```

### Building Release APK
```bash
cd frontend
flutter build apk --release --dart-define=API_BASE_URL=https://<your-hosted-backend-url>/api/v1
```

---

## 4. Security & Exclusions

This repository is sanitized and safe for source control:
* **No credentials or secrets** (`.env`, private keys, service account JSONs) are tracked.
* **No database backups or dumps** (`*.sql`, `backups/`) are included.
* **No build outputs or cache directories** (`node_modules/`, `build/`, `.dart_tool/`) are tracked.
