# Healix Mobile 🏥

**Healix** is a state-of-the-art, cross-platform Flutter application. It serves as a highly authoritative **Interactive Visual Aid (e-Detailing)** tool for doctors to explore clinical product compositions. This mobile app is a critical component of the broader Healix Enterprise Pharmaceutical platform (which includes a FastAPI/Gemini backend and a React dashboard).

---

## 🌟 Key Features & Accomplishments

### 1. Enterprise "Glassmorphism" UI/UX Design
We completely overhauled the design language to match top-tier pharmaceutical giants (like Pfizer and Sun Pharma), combining authoritative clinical structure with modern 3D Glassmorphism.
- **Sterile Liquid Environments:** Built custom Flutter animated gradients that serve as a clean, clinical background.
- **Frosted Glass Showcase Cards:** Transitioned from basic grids to massive, horizontal "Showcase" cards featuring heavy background blurs (`BackdropFilter`), razor-thin borders, and deep drop shadows.
- **3D Breakout Imagery:** Product images physically "pop out" of the frosted glass with custom drop shadows.

### 2. High-Fidelity Native Animations
Built buttery-smooth, native-feeling interactions replacing basic static widgets:
- **Staggered Entrance:** Used `TweenAnimationBuilder` with `easeOutCubic` curves to create sophisticated cascading load animations for product lists.
- **Physical Press Reactions:** Implemented `AnimatedScale` on gesture taps so cards physically depress into the screen when a doctor interacts with them.
- **Hero & Fade Transitions:** Customized the Flutter `PageRouteBuilder` to execute a combined `FadeTransition` and `SlideTransition` to mimic ultra-premium iOS navigation patterns.

### 3. Responsive Architecture
- **Dynamic Layout Constraints:** Engineered the UI using `MediaQuery` calculations to automatically morph the layout from a massive single-column vertical feed (on iPhones/Android phones) to a multi-column structured grid (on iPads/Tablets) perfectly suited for doctor presentations.
- **Intrinsic Sizing:** Utilized `ListView.separated` combined with `IntrinsicHeight` constraints to ensure product cards hug their text content tightly, eliminating awkward whitespace commonly found in fixed-ratio grids.

---

## 🛠 Tech Stack

### Mobile App (iOS / Android)
- **Framework:** Flutter (Dart)
- **State Management / Architecture:** Reactive UI updates via Stateful widgets and context bindings.
- **Animations:** Custom Flutter `PageRouteBuilder`, `TweenAnimationBuilder`, and `AnimatedScale`.
- **API Integration:** Connects seamlessly to the Healix FastAPI backend for real-time drug catalog updates.

---

## 🚀 How to Run Locally

### Flutter Mobile App
```bash
flutter clean
flutter pub get
flutter run
```

---

*Designed and Developed as a showcase of Enterprise Mobile Engineering and High-End UX/UI Development.*
