# MGIT Smart Canteen

MGIT Smart Canteen is a local-first Flutter MVP for a student-friendly campus food-ordering experience. It demonstrates browsing a sample menu, managing a persistent cart, placing local demo orders, and following the order status through **Placed → Preparing → Ready**.

## Run locally

1. Install the Flutter stable SDK.
2. From the project directory, run `flutter pub get`.
3. Run `flutter run` and select an available device or browser.

The app starts with a short onboarding screen and then opens the home screen directly. No account or roll number is required.

## Features

- Material 3 interface with Home, Menu, My Orders, and Profile tabs.
- Search and category filters for sample food items, including Chicken Biryani, and illustrative prices.
- Food detail sheets, availability handling, and graceful image fallbacks.
- Persistent favorite dishes with a Favorites menu filter.
- Provider-managed cart with quantity controls and live totals.
- Locally persisted cart, profile display name, onboarding state, and order history.
- Readable order IDs, order confirmation, recent orders, and automatic status tracking.
- Order cancellation while the status is still Placed.
- A latest-order Home banner, animated progress tracker, and pickup countdown.
- A custom campus-and-food brand mark used throughout the app.
- Responsive menu grid and accessible empty states.

## Project structure

- `lib/models/` — food, cart, and order data models.
- `lib/data/` — sample menu data (not a representation of the live MGIT menu).
- `lib/providers/` — cart, order, and local profile state.
- `lib/services/` — SharedPreferences-backed local storage.
- `lib/screens/` — onboarding, tab destinations, cart, confirmation, and tracking.
- `lib/widgets/` — shared food, category, cart, empty-state, and tracking components.
- `lib/theme/` — Material 3 app theme.
- `test/` — cart/order behavior and navigation tests.

## Demo limitations

This version has no backend authentication, payment flow, staff dashboard, or live inventory. Orders are stored only on the current device and **are not sent to MGIT canteen staff**. Order status changes and cancellations are local simulations; cancellation is available only while an order is Placed. Food names, prices, and availability are illustrative sample data and do not claim to reflect the actual canteen menu.

## Checks

```shell
flutter analyze
flutter test
```

## Deploy to Render

The root `render.yaml` configures this repository as a Render Static Site. In Render, choose **New + → Blueprint**, connect this GitHub repository, and approve deployment of the `mgit-smart-canteen` service. Render installs the Flutter stable SDK during its build, compiles the web app, and publishes `build/web`; the rewrite rule supports app navigation on refresh.

The deployed app remains a local-first demo: orders and favorites are saved in each visitor's browser and are not shared with canteen staff.
