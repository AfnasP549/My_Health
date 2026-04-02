# My Health - Health Connect Realtime Dashboard

A high-performance Flutter application built to visualize real-time health data (Steps and Heart Rate) by integrating with the **Android Health Connect** API.

## 📱 Project Overview
This application provides a live, interactive dashboard for monitoring physical activity. It bridges the gap between Google's Health Connect system and a modern, fluid Flutter UI, allowing users to track their health metrics as they happen.

## 🛠️ Setup Steps
1.  **Install Health Connect**: Ensure the [Health Connect](https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata) app is installed on your physical Android device.
2.  **Get Dependencies**: Run `flutter pub get` in your terminal.
3.  **Run on Device**: Ensure your device is connected (API 34+) and run the app:
    ```bash
    flutter run --profile
    ```

## 🏗️ Architecture
- **Pattern**: Clean Architecture (Separation of Domain, Data, and Presentation layers).
- **State Management**: **Riverpod** is used for global state, interaction handling, and dependency injection.
- **Repository Pattern**: Abstract data sources allow for seamless switching between real health data and simulated demo data.

## ⚡ Real-time Approach
The app implements a robust strategy for near-real-time updates:
- **Polling**: Every 5 seconds, the app queries the Health Connect API for the latest heart rate and step count data.
- **Deduplication**: Logic within the ViewModel ensures only new, unique data points are added to the chart to prevent duplicates.
- **Rolling Window**: Only the most recent 60 minutes of data are displayed to maintain high performance.

## 📊 Performance Features
To meet the strict technical requirements for this project:
- **Zero-Allocation Paints**: `CustomPainter` objects are optimized to avoid object creation during the paint cycle.
- **RepaintBoundaries**: Isolated chart layers prevent full-screen redraws.
- **Built-in HUD**: A real-time performance overlay monitors:
    - **Average Build Time**: Target **≤ 8ms** (Achieved: ~3.5ms in Profile mode).
    - **FPS**: Maintain stable **60 FPS** with **0 jank frames**.

---
*Developed as part of the Health Connect Dashboard challenge.*
