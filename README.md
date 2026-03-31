# FitPilot

> AI-powered fitness companion — workout planner, diet coach, hydration tracker, and streak system in a single Flutter app.

---

## Screenshots

> _Screenshots coming soon._

<!-- Replace paths below once images are added to docs/screenshots/
![Overview](docs/screenshots/overview.png)
![Workout](docs/screenshots/workout.png)
![Diet](docs/screenshots/diet.png)
![Water](docs/screenshots/water.png)
-->

---

## Features

| Module | Description |
|--------|-------------|
| **AI Coach** | Claude-powered conversational coach answers training and nutrition questions in real time |
| **Workout Engine** | 3-step wizard (intensity → location → focus) generates a personalised exercise plan; 25+ exercises with CustomPainter illustrations, step-by-step instructions, and common-mistake callouts |
| **Diet Planner** | AI chat tab for meal recommendations; calorie logging tab with meal-type categorisation; weekly bar chart showing intake vs. TDEE target |
| **Water Tracker** | Animated gradient ring, quick-add presets, custom entry, daily log, and goal-reached indicator |
| **Weather Integration** | Live conditions via OpenWeatherMap; weather-themed hero card with rain, snow, and star particles; temperature and local badge |
| **Streak System** | Day-streak counter, 7-dot history, full monthly calendar grid with workout indicators and month navigation |
| **Profile & BMI** | Body-stats form, BMI gauge, goal selector, body-shape picker, supplement and medical-condition inputs |
| **Premium UI** | Animated gradient hero card, per-tile gradient stat cards, rotating avatar ring, shimmer onboarding button, gradient water ring, gradient step indicator, gradient choice cards |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x · Dart 3.x |
| State management | Riverpod 2.x (`NotifierProvider`, `StateProvider`) |
| Navigation | go_router 14.x |
| HTTP | Dio |
| AI | Anthropic Claude API (`claude-sonnet-4-6`) |
| Weather | OpenWeatherMap Current Weather API |
| Persistence | shared_preferences |
| Image picker | image_picker |
| CI / iOS builds | Codemagic |

---

## Architecture

```
lib/
├── core/
│   ├── services/          # WeatherService, AiCoachService
│   ├── storage/           # StorageService (SharedPreferences wrapper)
│   └── theme/             # AppColors, AppTheme, AppTextStyles
├── models/                # BodyProfile, MealEntry, ProgressEntry, WorkoutPlan …
├── providers/             # Riverpod providers — one file per domain
│   ├── profile_provider.dart
│   ├── workout_provider.dart
│   ├── meal_provider.dart
│   ├── water_provider.dart
│   ├── streak_provider.dart
│   └── …
├── screens/
│   ├── onboarding/        # 4-page onboarding wizard
│   ├── overview/          # Home screen — hero card, stats grid, streak, AI coach
│   ├── app_hub/           # WorkoutTab, DietTab, WaterTab, ProfileTab
│   ├── shell/             # MainShell — IndexedStack + NavigationBar
│   └── settings/
├── utils/                 # BmiCalc, date helpers
└── widgets/               # GlowIcon, WaterRing, WeeklyCalorieChart,
                           # ExerciseCard, ExerciseIllustration,
                           # StreakDots, StepIndicator, WeatherCardTheme …
```

**Key design decisions**

- `IndexedStack` in `MainShell` keeps all tab trees alive across switches — no rebuild on re-visit.
- All business logic lives in Riverpod `Notifier` classes; widgets are pure view with no direct storage access.
- `StorageService` wraps `SharedPreferences` behind a thin static API; providers call it directly on every mutation so state survives app restarts without a separate persistence layer.
- `ExerciseIllustration` renders exercise poses using `CustomPainter` with a 100×130 virtual coordinate space and a full-canvas `LinearGradient` shader — each pose is defined as joint offsets with a `Set<_Seg>` glow mask, requiring zero image assets.
- Weather gradients, particles, and glow are derived from a single OWM weather code via `WeatherThemeMapper`, keeping the hero card stateless with respect to theme.

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.19 (`flutter --version` to check)
- Dart SDK ≥ 3.3 (bundled with Flutter)
- An [Anthropic API key](https://console.anthropic.com/) for the AI coach
- An [OpenWeatherMap API key](https://openweathermap.org/api) for weather data

### Environment

Create `lib/core/config.dart` (gitignored) and add your keys:

```dart
class AppConfig {
  static const anthropicApiKey  = 'sk-ant-...';
  static const openWeatherApiKey = '...';
}
```

### Run

```bash
flutter pub get
flutter run                   # debug on connected device or emulator
flutter run --release         # optimised release build
```

### Build

```bash
# Android
flutter build apk --release

# iOS — requires macOS + Xcode, or use Codemagic (see below)
flutter build ios --release
```

### iOS CI via Codemagic

Connect the repository in the [Codemagic dashboard](https://codemagic.io), add your Apple Developer credentials and API keys as environment variables, and trigger a build. The `codemagic.yaml` workflow handles code signing and distribution automatically.

---

## Project Stats

| Metric | Value |
|--------|-------|
| Dart source files migrated | 38 |
| Compilation errors | 0 |
| `flutter analyze` issues | 0 |
| Target platforms | Android · iOS |

---

## Roadmap

- [ ] Push notifications for streak reminders and hydration prompts
- [ ] Apple HealthKit / Google Fit sync
- [ ] Progress photo timeline
- [ ] Barcode scanner for food logging
- [ ] Offline AI fallback (on-device model)

---

## License

MIT © 2026 FitPilot. See [LICENSE](LICENSE) for details.
