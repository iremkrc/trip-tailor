# Trip Tailor 🧳✈️

A Flutter-based mobile application that helps users plan trips and get personalized outfit suggestions based on weather conditions and their closet inventory.

## Overview

Trip Tailor is your personal travel companion that combines trip planning, weather forecasting, and AI-powered outfit recommendations. Whether you're planning a weekend getaway or a month-long adventure, Trip Tailor helps you pack smart and dress right.

### Key Features

- **Trip Management**: Create, view, and manage your trips with detailed itineraries
- **Smart Outfit Suggestions**: Get AI-powered outfit recommendations based on real-time weather
- **Closet Management**: Organize your clothing items and manage your digital closet
- **Weather Integration**: View current and forecast weather for trip destinations
- **Location Discovery**: Find points of interest (POI) and popular destinations
- **User Profiles**: Manage your profile and personalization preferences
- **Notifications**: Get reminded about upcoming trips and outfit suggestions
- **Map View**: Visualize trip locations on interactive maps

## Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework (iOS, Android, Web)
- **Material Design** - Google's design system for UI components
- **Flutter Widgets** - Custom widgets for enhanced UI/UX

### Backend & Services
- **Firebase** - Backend-as-a-service platform
  - **Firebase Authentication** - User authentication and account management
  - **Firebase Realtime Database** - Real-time data synchronization
  - **Firebase Storage** - Cloud storage for images and user data
  - **Firebase Messaging** - Push notifications
- **Google APIs**
  - **Google Places API** - Location search and discovery
  - **Google Calendar API** - Calendar integration
  - **Google Sign-In** - OAuth authentication

### APIs & Data Services
- **OpenWeatherMap API** - Weather data and forecasts
- **Open-Meteo API** - Alternative weather data source
- **Remove.bg API** - Background removal for clothing images

### Machine Learning
- **PyTorch Lite** - On-device ML inference for outfit suggestions
- **Pre-trained Models** - Color matching and clothing compatibility models

### Location & Maps
- **Flutter Map** - Interactive map widget
- **Geolocator** - Device location services
- **Google Maps Integration** - Location visualization and navigation

### Additional Libraries
- **http** - HTTP client for API requests
- **intl** - Internationalization and date/time formatting
- **image_picker** - Image selection and camera access
- **permission_handler** - Runtime permissions management
- **country_picker** - Country selection widget
- **firebase_auth** - Firebase authentication
- **google_sign_in** - Google OAuth integration
- **timezone** - Timezone management
- **flutter_dotenv** - Environment variable management
- **share_plus** - Social sharing functionality
- **flutter_html** - HTML rendering
- **palette_generator** - Color palette generation from images

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── api_client.dart          # HTTP API client
├── page/                    # UI pages/screens
│   ├── home_page.dart
│   ├── trip_page.dart
│   ├── trip_detail_page.dart
│   ├── outfit_page.dart
│   ├── closet_page.dart
│   ├── profile_page.dart
│   ├── weather_page.dart
│   ├── map_view_page.dart
│   ├── POI_page.dart
│   └── ...
├── services/                # Business logic & external services
│   ├── weather_service.dart
│   ├── location_service.dart
│   ├── city_location_service.dart
│   ├── notification_service.dart
│   ├── google_calendar_service.dart
│   └── color_service.dart
├── controllers/             # State management
│   ├── user_controller.dart
│   └── model_controller.dart
├── models/                  # Data models
│   ├── weather_model.dart
│   └── city_location_model.dart
├── constants/               # App constants
│   ├── api_constants.dart
│   ├── color.dart
│   └── text_style.dart
└── widgets/                 # Reusable widgets
    └── custom_paint.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.3.0 <4.0.0)
- Dart SDK
- iOS Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/iremkrc/trip-tailor.git
   cd trip-tailor
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   - Copy `.env.example` to `.env`
   - Add your API keys to `.env`:
     ```
     OPENWEATHER_API_KEY=your_key_here
     PLACES_API_KEY=your_key_here
     CITY_IMAGE_API_KEY=your_key_here
     REMOVEBG_API_KEY=your_key_here
     ```

4. **Set up Firebase**
   - Create a Firebase project
   - Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Configure Firebase in your project

5. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Environment Variables

The app uses `.env` file for sensitive configuration. See `.env.example` for the required variables:

- `OPENWEATHER_API_KEY` - OpenWeather API key for weather data
- `PLACES_API_KEY` - Google Places API key for location search
- `CITY_IMAGE_API_KEY` - API key for city images
- `REMOVEBG_API_KEY` - Remove.bg API key for image processing

**Note**: The `.env` file is git-ignored for security. Never commit API keys to version control.

### Firebase Configuration

1. Set up Firebase Authentication
2. Configure Firebase Realtime Database rules for user data
3. Set up Firebase Storage for image uploads
4. Enable Firebase Cloud Messaging for notifications

## Features in Detail

### Trip Management
- Create new trips with destination, dates, and itinerary
- View all trips categorized as upcoming and past
- Edit trip details and itineraries
- Delete trips
- Share trip information

### Outfit Suggestions
- AI-powered outfit recommendations based on:
  - Current and forecast weather
  - Clothing items in user's closet
  - Color combination preferences
  - Temperature and weather conditions
- Multiple color harmony options (same, close, similar, moderate)

### Closet Management
- Add clothing items with photos
- Organize by clothing type (Winter Coat, Jacket, Hoodie, etc.)
- Store color information for outfit matching
- Edit and delete clothing items

### Weather Integration
- Real-time weather data for trip destinations
- 7-day weather forecast
- Hourly weather details
- Weather-appropriate outfit recommendations

### Location Discovery
- Search for popular destinations
- View points of interest (restaurants, attractions, hotels)
- See location details and images
- Navigate to locations

## API Integrations

### Weather APIs
- **OpenWeatherMap**: Real-time weather and geocoding
- **Open-Meteo**: Historical and forecast weather data

### Google APIs
- **Places API**: Location search, details, and photos
- **Calendar API**: Integration with Google Calendar
- **Sign-In**: OAuth authentication

### Firebase APIs
- **Authentication**: User signup, login, password reset
- **Realtime Database**: User profiles, trips, closet items
- **Storage**: Profile pictures, clothing images
- **Cloud Messaging**: Push notifications

## Development

### Building for Production

**Android**:
```bash
flutter build apk --release
```

**iOS**:
```bash
flutter build ios --release
```

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

## Security

- API keys are stored in `.env` file (git-ignored)
- Firebase security rules protect user data
- OAuth authentication for Google services
- HTTPS for all API communications

## Performance

- Lazy loading for trip lists and images
- Efficient database queries with Firebase indexing
- On-device ML inference using PyTorch Lite
- Image caching and optimization
- Pagination for large datasets

## Future Enhancements

- Real-time collaboration for group trips
- Integration with more weather services
- Advanced outfit recommendations with ML
- Trip cost tracking and budgeting
- Packing list generation
- Itinerary suggestions based on location

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is private and not open for public use.

## Support

For issues and questions, please create an issue in the GitHub repository.

## Author

Created by iremkrc

---

**Made with ❤️ for better trip planning and outfit suggestions**
