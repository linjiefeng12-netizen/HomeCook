# HomeCook

HomeCook is an iOS cooking application developed with SwiftUI, supporting multiple languages to help users select ingredients and kitchenware for recipe recommendations.

<img src="HomeCookUI/Welcome.PNG" alt="WelcomeView" width="200" height="400">

## Features
### 🏠  Home
- **Ingredient Selection**: Adjustable from 1 to 10 servings.
- **Kitchenware Selection**: Randomly generate recipe combinations.
- **Recommended Recipes**: Based on selected ingredients and kitchenware, recommend relevant recipes.

<img src="HomeCookUI/Home.PNG" alt="HomeView" width="200" height="400">

### 🎲 Flavor Gacha
- **Serving Adjustment**: Adjustable from 1 to 10 servings.
- **Random Recipe Generation**: Randomly generate recipe combinations based on selected ingredients and kitchenware.
- **Recipe Display**: Show recommended recipes in a card format.

<img src="HomeCookUI/FlavorGacha.PNG" alt="FlavorGachaView" width="200" height="400">

### 👤 Profile
- **User Profile**: Display user avatar, name, and membership status.
- **Cooking History**: View cooking history.
- **My Favorites**: Manage favorited recipes.
- **Settings**: Share, feedback, and other settings options.

<img src="HomeCookUI/Profile.PNG" alt="ProfileView" width="200" height="400">

### ❤️ Favorite
- **Like View**: Show liked recipes in a card format.

<img src="HomeCookUI/Favorite.PNG" alt="FavoriteView" width="200" height="400">
    
## Multi-Language Support
The application supports the following 8 languages:
- 🇨🇳 Chinese (simple)
- 🇺🇸 English
- 🇩🇪 German
- 🇪🇸 Spanish
- 🇯🇵 Japanese
- 🇰🇷 Korean
- 🇫🇷 French
- 🇷🇺 Russian

## Technical Architecture

### Frameworks and Technologies
- **SwiftUI**: User interface framework
- **SwiftData**: Data persistence
- **Localization**: Supports multiple languages
- **MVVM Architecture**: Clear code structure

### Data Models
- `Recipe`: Recipe model
- `Ingredient`: Ingredient model
- `Kitchenware`: Kitchenware model
- `Item`: Base data model

### View Structure
```
MainTabView
├── HomeView (主页)
├── FlavorGachaView (风味抽卡)
└── ProfileView (个人中心)
    └── HistoryView (历史记录)
```

## Installation and Running

### System Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Running Steps
1. Open `HomeCook.xcodeproj`
2. Select the target device or simulator
3. Click the run button or use `Cmd+R`

### Build Command
```bash
cd HomeCook
xcodebuild -scheme HomeCook -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build
```

## Project Structure

```
HomeCook/
├── HomeCookApp.swift          # Application entry point
├── ContentView.swift          # Main view
├── Item.swift                 # Base data model
├── Models/
│   └── Recipe.swift           # Recipe related data models
├── Views/
│   ├── MainTabView.swift      # Main tab view
│   ├── HomeView.swift         # Home view
│   ├── FlavorGachaView.swift  # Flavor gacha view
│   ├── ProfileView.swift      # Profile view
│   └── HistoryView.swift      # History view
├── ViewModels/
├── Utils/
│   └── LocalizationHelper.swift # Localization helper
├── Resources/                 # Resource directory
│   ├── Localizable.strings    # Default localization file
│   ├── zh-Hans.lproj/         # Chinese (Simplified)
│   │   └── Localizable.strings
│   ├── en.lproj/              # English
│   │   └── Localizable.strings
│   ├── de.lproj/              # German
│   │   └── Localizable.strings
│   ├── es.lproj/              # Spanish    
│   │   └── Localizable.strings
│   ├── ja.lproj/              # Japanese
│   │   └── Localizable.strings
│   ├── ko.lproj/              # Korean 
│   │   └── Localizable.strings
│   ├── fr.lproj/              # French
│   │   └── Localizable.strings
│   └── ru.lproj/              # Russian
│       └── Localizable.strings
└── Assets.xcassets/           # Application assets
    ├── AppIcon.appiconset/    # Application icon
    └── AccentColor.colorset/  # Theme color
```

## Design Features

### UI/UX Design
- **Modern Interface**: Adopts iOS 17 design language
- **Intuitive Operation**: Easy-to-use interaction design
- **Responsive Layout**: Adapts to different screen sizes
- **Theme Color**: Orange is the main color, warm and friendly

### Interaction Design
- **Tab Navigation**: Bottom tab bar for quick switching between views
- **Recipe Display**: Recipes are shown in card format
- **Button Feedback**: Visual feedback for selected states
- **Animation Effects**: Smooth transition animations
- **User Experience**: Clear and intuitive user interface

## Development Specifications

### Code Style
- Follows Swift official coding conventions
- Adopts SwiftUI best practices
- Clear naming conventions
- Comprehensive comment documentation

### File Organization
- Organize files by feature modules
- Separate views and data models
- Unified localization management
- Resource files are centralized in the Resources directory

## Future Extensions
- [ ] Add recipe search functionality
- [ ] Implement user authentication
- [ ] Enable cloud data synchronization
- [ ] Add social sharing features
- [ ] Develop a smart recommendation algorithm
- [ ] Display nutritional information
- [ ] Add a shopping list feature

### Planned Features
- [ ] Recipe Details Page
- [ ] User Authentication System
- [ ] Cloud Data Synchronization
- [ ] Social Sharing Features
- [ ] Smart Recommendation Algorithm
- [ ] Nutritional Information Display
- [ ] Shopping List Feature

### Technical Optimizations
- [ ] Performance Optimization
- [ ] Offline Support
- [ ] Image Caching
- [ ] Data Analytics

## License

This project is licensed under the MIT License.

## Contributions

Contributions are welcome! Please submit issues and pull requests to help improve this project.

---

**HomeCook** - Make cooking simpler and more fun! 🍳✨
