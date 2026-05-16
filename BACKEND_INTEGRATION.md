# Gospel Backend Integration Guide

This Flutter frontend is now fully connected to the **GospelBackend** API running on your desktop.

## Architecture Overview

```
Gospel Flutter App
  ├── UI Layer (Screens & Widgets)
  ├── State Management (AppState with Provider)
  ├── Service Layer
  │   ├── BackendService (HTTP client for API calls)
  │   ├── AppConfig (Environment & URL configuration)
  │   └── AppState (Business logic & state)
  └── Data Models
      ├── ContentItem
      └── ChatMessage
```

## Setup Instructions

### Prerequisites
- GospelBackend running on `http://localhost:3000`
- Flutter SDK installed
- VS Code with Flutter extension

### 1. Install Dependencies

```bash
cd c:\Users\DELL\Desktop\Gospel
flutter pub get
```

This installs the new `http` package required for API communication.

### 2. Start the Backend

```bash
cd c:\Users\DELL\Desktop\GospelBackend
npm install  # if not already done
npm run dev
```

The backend will run on `http://localhost:3000`.

### 3. Run the App

```bash
# For web
flutter run -d chrome

# For mobile simulator
flutter run -d "device_name"

# For desktop (Windows)
flutter run -d windows
```

## API Integration Points

### Content Loading
- **Endpoint**: `GET /api/content`
- **Trigger**: App startup (in `main.dart`)
- **Handled by**: `BackendService.fetchContent()`
- **State**: `AppState.content` list is populated
- **Fallback**: Offline demo data is used if backend unavailable

### Chat Messages
- **Endpoint**: `GET /api/chat/{contentId}/messages`
- **Trigger**: When user navigates to video detail screen
- **Handled by**: `BackendService.fetchMessages()`
- **Auto-refresh**: Call `AppState.refreshChat()` to reload

### Likes
- **Endpoint**: `POST /api/content/{id}/like`
- **Trigger**: User clicks like button
- **Handled by**: `BackendService.likeContent()`
- **Optimistic Update**: UI updates immediately; reverts on error

### Send Message
- **Endpoint**: `POST /api/chat/{contentId}/messages`
- **Trigger**: User submits chat message
- **Handled by**: `BackendService.postMessage()`
- **Optimistic Update**: Temp message shown; replaced with real message from backend

## File Structure

```
lib/
├── config/
│   └── app_config.dart          # Backend URL configuration
├── services/
│   ├── backend_service.dart     # HTTP API client (NEW)
│   └── app_state.dart           # State management with backend integration
├── models/
│   ├── content_item.dart        # Updated with fromJson/toJson
│   └── chat_message.dart        # Updated with fromJson/toJson
├── screens/
│   ├── home_screen.dart         # Updated with loading state
│   ├── video_detail_screen.dart # Updated with chat async loading
│   └── creator_screen.dart
├── widgets/
│   └── glass_card.dart
└── main.dart                    # Updated with app initialization
```

## Key Changes from Previous Version

### 1. AppState (`lib/services/app_state.dart`)
- **Before**: Used hardcoded local demo data
- **After**: 
  - Fetches content from `GET /api/content` on app startup
  - Fetches chat from `GET /api/chat/{contentId}/messages` per video
  - `toggleLike()` now calls backend and does optimistic updates
  - `sendMessage()` now calls backend with temp message sync
  - Added `initializeApp()` and `refreshChat()` methods
  - Added `isLoading` and `errorMessage` state for UI feedback

### 2. Models (ContentItem & ChatMessage)
- Added `fromJson()` factory constructors for parsing backend responses
- Added `toJson()` methods for sending data to backend
- Extended fields to match backend schema:
  - ContentItem: Added `description`, `category`, `contentUrl`, `createdAt`
  - ChatMessage: Added `authorAvatar`, `contentId`

### 3. Backend Service (`lib/services/backend_service.dart` - NEW)
- Centralized HTTP client for all API calls
- Handles base URL configuration via `AppConfig`
- All methods parse JSON responses into domain models
- Includes error handling and logging

### 4. App Configuration (`lib/config/app_config.dart` - NEW)
- Centralized backend URL management
- Smart URL selection based on platform:
  - **Web**: `http://localhost:3000/api`
  - **Android emulator**: `http://10.0.2.2:3000/api` (special Android host)
  - **Other platforms**: `http://localhost:3000/api`

### 5. UI Screens
- **HomeScreen**: Added loading spinner and error handling with retry
- **VideoDetailScreen**: 
  - Fetches messages from backend when screen opens
  - Empty state message when no chat yet
  - Async message sending

### 6. Dependencies
- Added `http: ^1.1.0` to `pubspec.yaml`

## Development Workflow

### Making API Changes
If the backend API changes:

1. Update `BackendService` methods to match new endpoints
2. Update model `fromJson()` constructors if response schema changes
3. Test with `flutter run` — fallback data allows testing offline

### Adding Authentication
The integration is ready for auth. To add:

```dart
// In BackendService methods, add token to headers:
final headers = {
  'Authorization': 'Bearer $token',
  ...
};
```

Store token in AppState and pass to all authenticated endpoints.

### Custom Queries
Extend `BackendService` methods with query parameters:

```dart
static Future<List<ContentItem>> fetchContent({
  int limit = 40,
  String? type,
  String? category,
}) async {
  final query = {'limit': '$limit'};
  if (type != null) query['type'] = type;
  if (category != null) query['category'] = category;
  
  final uri = _buildUri('/content', query);
  // ... rest of method
}
```

## Troubleshooting

### "Failed to fetch content"
- Verify backend is running: `curl http://localhost:3000/health`
- Check if port 3000 is in use
- On Android emulator, use `10.0.2.2` instead of `localhost`

### Chat not loading
- Verify backend has chat routes enabled
- Check that `contentId` is valid MongoDB ObjectId
- Look at console logs with `flutter run --verbose`

### Messages not persisting
- Ensure MongoDB is running and connected
- Backend logs will show database errors
- Check user authentication (currently not required by default)

### CORS issues (Web only)
- Backend CORS is configured in `GospelBackend/src/index.js`
- Add web port to `ALLOWED_ORIGINS` in `.env` if needed

## Performance Optimization

### Caching
Messages are fetched fresh each time. For better performance:

```dart
// Add to AppState:
final Map<String, List<ChatMessage>> _chatCache = {};

Future<void> refreshChat() async {
  if (_chatCache.containsKey(selectedVideoId)) {
    chat = _chatCache[selectedVideoId]!;
  }
  // ... fetch and cache
}
```

### Pagination
Backend supports pagination. Implement in AppState:

```dart
int _contentPage = 1;

Future<void> loadMoreContent() async {
  final moreContent = await BackendService.fetchContent(limit: 40, page: _contentPage++);
  content.addAll(moreContent);
  notifyListeners();
}
```

## Production Deployment

### Environment Variables
Create a `.env` file in the app root (not tracked by git):

```env
API_BASE_URL=https://api.gospel-platform.com
```

Load in `main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final apiUrl = dotenv.env['API_BASE_URL'];
```

### Certificate Pinning (HTTPS)
For production, add certificate pinning to prevent MITM attacks:

```dart
// In BackendService:
HttpClient client = HttpClient()
  ..badCertificateCallback = (cert, host, port) => false;
```

## Next Steps

1. ✅ Backend integration complete
2. 📝 Add user authentication (login/signup)
3. 🎬 Implement video player with backend URLs
4. 🔊 Integrate audio player with streaming
5. 📤 Add file upload for creators
6. 🔔 Implement push notifications
7. 📊 Add analytics and tracking
