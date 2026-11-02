<div align="center">

# 🍛 MGIT Smart Canteen

### Your campus cravings, just a few taps away.

<p>
  <img src="https://img.shields.io/badge/Flutter-App-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Built with Flutter">
  <img src="https://img.shields.io/badge/Material_3-Design-6750A4?style=for-the-badge" alt="Material 3">
  <img src="https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS-16A085?style=for-the-badge" alt="Supported platforms">
</p>

**Browse the menu · Save your favorites · Track your order**

[🚀 Open the live app](https://mgit-smart-canteen.onrender.com) ·
[📦 GitHub repository](https://github.com/vyshnavichandra7/smart_canteen)

</div>

---

## 🌈 About

MGIT Smart Canteen is a colorful, local-first Flutter MVP for a student-friendly campus food-ordering experience. Explore a sample menu, build a cart, place a demo order, and follow it through **Placed → Preparing → Ready**.

> **No sign-in required.** Open the app and start exploring.

## ✨ Features

| 🍽️ Discover | 🛒 Order | 💛 Track |
|---|---|---|
| Search and filter a responsive menu | Manage quantities and view live cart totals | Follow animated Placed → Preparing → Ready progress |
| Chicken Biryani and other sample dishes | Save your cart locally | See an estimated pickup countdown |
| Food details and image fallbacks | Place and cancel eligible demo orders | Find your latest order right from Home |
| Favorite dishes and a Favorites filter | Keep order history on your device | Browse recent orders and their status |

Also includes a custom campus-inspired logo, Material 3 styling, accessible empty states, and a profile tab.

## 🧑‍🍳 Run it locally

1. Install the [Flutter stable SDK](https://docs.flutter.dev/get-started/install).
2. Open a terminal in this project folder.
3. Fetch packages and launch:

   ```shell
   flutter pub get
   flutter run
   ```

Choose any available device or browser when prompted.

## 🧪 Run checks

```shell
flutter analyze
flutter test
```

## 🚀 Deploy on Render

This repository includes a [`render.yaml`](./render.yaml) Blueprint for a Render Static Site.

1. In Render, choose **New + → Blueprint**.
2. Connect `vyshnavichandra7/smart_canteen`.
3. Review the `mgit-smart-canteen` service and deploy.

Render builds the Flutter web app and publishes `build/web`. The rewrite rule supports reloading app routes. The live app is at **[mgit-smart-canteen.onrender.com](https://mgit-smart-canteen.onrender.com)**.

## 🗂️ Project map

| Folder | What you'll find |
|---|---|
| `lib/models/` | Food, cart, and order models |
| `lib/data/` | Illustrative sample menu |
| `lib/providers/` | Cart, favorites, orders, and profile state |
| `lib/services/` | SharedPreferences-backed local storage |
| `lib/screens/` | Onboarding, menu, cart, orders, profile, and tracking |
| `lib/widgets/` | Shared food, logo, cart, and order UI |
| `lib/theme/` | Material 3 app theme |
| `test/` | Cart, order, cancellation, and navigation tests |

## ⚠️ Demo notes

This is a **front-end demo**, not a live canteen ordering system. It has no backend, staff dashboard, payment flow, authentication, or live inventory. Carts, favorites, and orders are saved in each visitor's browser/device and **are not sent to MGIT canteen staff**. Order status is simulated. Menu items, prices, and availability are illustrative and may not match the actual canteen menu.

---

<div align="center">

Made with 💛 and Flutter

</div>
