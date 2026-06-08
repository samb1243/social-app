# Social Media App (Flutter)

A Twitter-like social media application built with Flutter. Features a feed, posts, user profiles, search, notifications, and thoughts (24-hour disappearing posts).

## Project Architecture

### Technology Stack
- **Framework**: Flutter 3.x
- **State Management**: Riverpod 2.x (with Generator)
- **Navigation**: GoRouter 14.x
- **Storage**: SharedPreferences (posts), file system/in-memory (auth)
- **UI Framework**: Material Design 3

### Directory Structure

```
lib/
├── main.dart                          # App entry point with ProviderScope
├── app.dart                           # Root widget with theme and router setup
├── router/
│   └── router.dart                    # GoRouter configuration and routes
├── models/
│   ├── user_model.dart                # User profile data model
│   ├── post_model.dart                # Post/tweet data model with media support
│   ├── thought_model.dart             # Temporary 24-hour post model
│   ├── video_metadata.dart            # Video attachment metadata
│   └── mock_data.dart                 # Sample data for development
├── services/
│   ├── auth_service.dart              # Account authentication logic
│   ├── auth_storage.dart              # Platform-aware conditional export
│   ├── auth_storage_web.dart          # Web implementation (in-memory)
│   ├── auth_storage_native.dart       # Native implementation (file I/O)
│   └── post_storage_service.dart      # Post persistence via SharedPreferences
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── auth_providers.dart    # Login/register/logout state management
│   │       ├── login_screen.dart      # Login UI
│   │       ├── login_screen_new.dart  # Alternate login UI variant
│   │       └── register_screen.dart   # Registration UI
│   ├── feed/
│   │   └── presentation/
│   │       ├── feed_providers.dart    # Feed state (posts) management
│   │       ├── feed_screen.dart       # Main feed UI
│   │       ├── feed_providers.dart    # Post interactions (like, repost, etc)
│   │       ├── thoughts_providers.dart# Temporary thoughts state
│   │       ├── create_thought_dialog.dart # Create new thought
│   │       ├── thought_card.dart      # Thought display widget
│   │       └── widgets/
│   │           ├── post_card.dart     # Post display widget
│   │           └── post_card_new.dart # Alternate post display variant
│   ├── search/
│   │   └── presentation/
│   │       └── search_screen.dart     # Search UI
│   ├── notifications/
│   │   └── presentation/
│   │       └── notifications_screen.dart # Notifications UI
│   ├── profile/
│   │   └── presentation/
│   │       ├── profile_providers.dart # User profile state
│   │       ├── profile_screen.dart    # Profile view UI
│   │       └── edit_profile_screen.dart # Edit profile UI
│   ├── post_detail/
│   │   └── presentation/
│   │       └── post_detail_screen.dart # Single post detail view
│   └── create_post/
│       └── presentation/
│           └── create_post_screen.dart # Compose new post UI
├── shared/
│   ├── theme/
│   │   └── app_theme.dart             # Material Design 3 themes (light/dark)
│   └── widgets/
│       ├── shell_scaffold.dart        # Bottom nav + FAB wrapper
│       ├── user_avatar.dart           # Reusable user avatar widget
│       ├── post_video_player.dart     # Video playback widget
│       └── [other shared widgets]
└── [other files like analysis_options.yaml, pubspec.yaml, etc]
```

## Key Features

### Authentication
- **Login**: Email/password authentication with validation
- **Registration**: New user account creation with duplicate prevention
- **Admin Login**: Quick test login (for development only)
- **Platform-specific Storage**:
  - Web: In-memory storage (data lost on page refresh)
  - Native: File-based persistent storage (documents directory)

### Feed Management
- Display posts in chronological order
- Like/unlike posts with count updates
- Repost functionality
- Add new posts to feed
- Automatic persistence to device storage

### User Interface
- Material Design 3 theming
- Light and dark mode support (system preference)
- Bottom navigation (Home, Search, Notifications, Profile)
- Floating action button for composing new posts
- Responsive design for web and mobile

### Data Persistence
- **Posts**: Stored per-user using SharedPreferences
- **Accounts**: Stored via platform-specific implementation
- **JSON Serialization**: All models support toJson/fromJson
- **Media Support**: Images and videos stored as base64 or file paths

## Development Workflow

### Running the App
```bash
# Run with hot reload
flutter run

# Build for web
flutter build web

# Build for iOS/Android
flutter build apk
flutter build ios
```

### Building after changes
The app uses code generation for Riverpod. After modifying providers:
```bash
flutter pub run build_runner build
```

### Adding New Features
1. Create data models in `lib/models/`
2. Create providers in feature `presentation/` folders
3. Create screens/widgets in feature folders
4. Add routes to `lib/router/router.dart`
5. Update navigation in `lib/shared/widgets/shell_scaffold.dart` if adding new tab

## State Management with Riverpod

### Key Providers
- **authProvider**: Current logged-in user (UserModel?)
  - Methods: login(), register(), loginAdmin(), logout()
- **feedProvider**: List of posts (List<PostModel>)
  - Methods: initializePosts(), toggleLike(), toggleRepost(), addPost()

### Usage in Widgets
```dart
// Watch state (rebuilds on change)
final user = ref.watch(authProvider);
final posts = ref.watch(feedProvider);

// Read state once (no rebuild)
final user = ref.read(authProvider);

// Call methods on notifier
await ref.read(authProvider.notifier).login(email, password);
await ref.read(feedProvider.notifier).toggleLike(postId);
```

## Routing with GoRouter

### Route Structure
- **Auth Routes**: /login, /register (redirected to /feed if logged in)
- **Main Routes** (in ShellRoute):
  - /feed - Main timeline
  - /search - Search screen
  - /notifications - Notifications
  - /profile - User profile
- **Detail Routes** (outside shell):
  - /post/:id - Single post detail
  - /compose - Create new post
  - /edit-profile - Edit user profile

### Navigation
```dart
// Push to new screen
context.push('/post/123');

// Replace current screen
context.go('/feed');

// Pop current screen
context.pop();
```

## Data Models

### UserModel
- id, username, displayName
- Optional: bio, avatarUrl, bannerUrl, pronouns, age
- Follower/following counts
- copyWith() for immutable updates

### PostModel
- id, author, content, createdAt
- Engagement: likesCount, repliesCount, repostsCount
- Flags: isLiked, isReposted
- Media: imageBytes, imageUrl, or videoMetadata
- Optional replyToId for threaded conversations
- JSON serialization with base64 media encoding

### ThoughtModel
- Similar to PostModel but with 24-hour expiration
- Properties: isExpired (boolean), timeRemaining (Duration)

### VideoMetadata
- path, duration, thumbnailBytes, fileSizeBytes
- durationDisplay getter for formatted time string

## Important Notes

### Security
⚠️ **WARNING**: Passwords are stored in PLAIN TEXT for development purposes. This is NOT suitable for production. In production:
- Use secure credential storage (Keychain on iOS, Keystore on Android)
- Never store passwords in shared preferences or files
- Use OAuth or other secure authentication methods

### Platform Differences
The app uses conditional compilation to support different storage backends:
- `dart.library.io` check routes to native implementation (iOS, Android, Windows, Linux, macOS)
- Web platform uses in-memory storage (temporary, lost on page refresh)

### Dependencies
- **flutter_riverpod**: State management and dependency injection
- **go_router**: Navigation and routing
- **shared_preferences**: Local data persistence
- **path_provider**: Access to documents directory (native only)
- **image_picker**: Select images/videos from device
- **video_player**: Play videos in feed
- **uuid**: Generate unique IDs
- **intl**: Internationalization support
- **timeago**: Relative timestamps ("2 hours ago")

## Extending the App

### Adding a New Screen
1. Create a new directory in `lib/features/[feature_name]/presentation/`
2. Create your screen widget file
3. Create a providers file if you need state management
4. Add route to `lib/router/router.dart`
5. Import and use the provider/route

### Adding API Support
1. Create a service layer in `lib/services/`
2. Update providers to call the service methods
3. Add loading/error states to the provider
4. Update UI to show loading/error states

### Adding Animations
1. Use Flutter's built-in animation APIs
2. Consider using AnimatedBuilder or implicit animations
3. Add to post_card and thought_card widgets

## Testing
The app currently uses mock data from `lib/models/mock_data.dart`. To test:
1. Log in with admin account (admin login button)
2. Or register a new account
3. The feed will populate with mock posts
4. Test features like liking, reposting, creating posts

## Future Improvements
- [ ] Connect to real backend API
- [ ] Add proper authentication (OAuth, JWT tokens)
- [ ] Implement real-time updates (WebSocket, Firebase)
- [ ] Add image/video upload to server
- [ ] User search and follow functionality
- [ ] Direct messaging
- [ ] Hashtags and trending topics
- [ ] Retweet quotes with comments
- [ ] User recommendations
- [ ] Bookmarks/saved posts
