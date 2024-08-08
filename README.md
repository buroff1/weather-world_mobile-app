# WeatherWorld Mobile App 🌦️

## 🧪 Demo
![Picture7-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/7eae0eb8-9924-4ef4-8e1b-dcce6939608e)

## 📝 Content

- [Overview](#%EF%B8%8Foverview)
- [Technologies](#technologies)
- [Features](#features)
- [Project Structure](#%EF%B8%8Fproject-structure)
- [Run Project](#run-project)
- [Managing API Keys](#managing-api-keys)
- [Contributing](#contributing)
- [Contact](#contact)

## 🗺️Overview

The WeatherWorld Mobile App is a cross-platform application providing real-time weather updates and forecasts worldwide, utilizing the OpenWeatherMap API.

## 👨‍💻Technologies

- **Flutter**: Main SDK for building the application.
- **Dart**: Programming language used.
- **Provider**: State management for managing application state.
- **HTTP**: For making network requests.

## 👀Features

- **Real-Time Weather Data**: Users can view current weather conditions.
- **Forecasting**: Access to hourly and daily weather forecasts.
- **Favorites**: Users can save favorite locations for quick access.
- **Detailed Weather Information**: Details on wind, humidity, and more.

## 🗃️Project Structure

- **`/android` and `/ios`**: Native app directories containing platform-specific configurations.
- **`/lib`**:
  - `main.dart`: Entry point of the application.
  - `homePage.dart`: Main screen displaying weather data.
  - `detailPage.dart`: Shows detailed weather information for a location.
  - `database_helper.dart`: Handles local database interactions for storing favorite locations.
  - `dataset.dart`: Manages data models and business logic.
  - `extraWeather.dart`: Additional utilities for handling weather data.
  - `favoriteCitiesScreen.dart`: Manages and displays user's saved favorite cities.
  - `unit_provider.dart`: Provides unit conversion functionalities across the app.
- **`/assets`**: Contains images and other assets used by the application.
- **`/test`**: Contains Dart test files for automated testing of the application.

## ✅Run Project

1. **Clone the repository**:
```
https://github.com/buroff1/weather-world_mobile-app.git
cd weather-world_mobile-app
```
2. **Install dependencies**:
`flutter pub get`
3. **Launch the app**:
`flutter run`

## 🔑Managing API Keys

Ensure to store API keys in the `.env` file and ignore it in version control by updating `.gitignore`.

## 🤝Contributing

Interested in contributing? Follow these steps:

1. Fork the repo.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a pull request.

## 📧Contact

- Email: [artem.burov0205@gmail.com](mailto:artem.burov0205@gmail.com)
- GitHub: [buroff1](https://github.com/buroff1)

