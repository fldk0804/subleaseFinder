# SubleaseFinder 🏠

A comprehensive iOS app for finding and posting sublease listings in the Bay Area. Built with SwiftUI and modern iOS development practices.

## 🎯 What This App Does

**SubleaseFinder** connects people who need temporary housing with those who have available subleases. Perfect for:

- **Students** looking for semester housing
- **Interns** needing summer accommodations  
- **Traveling professionals** seeking short-term rentals
- **Property owners** with temporary vacancies

## ✨ Key Features

### 🔍 **Smart Search & Browse**
- **Map-first interface** showing listings by location
- **Advanced filters** (price, bedrooms, dates, amenities)
- **Real-time search** with debounced input
- **List/Map toggle** for different viewing preferences

### 📝 **Easy Listing Creation**
- **4-step wizard** (Basics → Details → Photos → Review)
- **Photo upload** with compression and optimization
- **Auto-save drafts** so you never lose progress
- **Smart validation** with helpful error messages

### 💾 **Favorites & Offline**
- **Save listings** you're interested in
- **Offline browsing** with cached results
- **Sync across devices** when signed in
- **Quick access** to your saved properties

### 🔐 **Flexible Authentication**
- **Guest browsing** - no account required
- **Email/Password** sign up and sign in
- **Anonymous mode** for privacy
- **Secure token-based** API authentication

### 🗺️ **Location Intelligence**
- **Interactive maps** with custom pins
- **Proximity search** for nearby listings
- **Walking time** calculations to amenities
- **Neighborhood insights** and local info

## 🏗️ Architecture Overview

### Tech Stack
- **Frontend**: SwiftUI + Combine/async–await
- **Maps**: MapKit for location-based features
- **Images**: PhotosUI for image selection and processing
- **Authentication**: Firebase Auth (Apple, Google, Email/Password, Anonymous)
- **Networking**: URLSession with custom APIClient (no third-party dependencies)
- **Data**: Codable for JSON serialization
- **Backend**: AWS API Gateway → Lambda (TypeScript/Node) → DynamoDB + S3

### Architecture Pattern
- **MVVM per feature** with a light Flow/Coordinator pattern for navigation
- **Protocol-based services** for dependency injection and testability
- **Read-through caching** with on-disk persistence
- **Offline-first** with queue-based retry mechanisms

## 📱 Current Demo Data

The app includes **6 realistic sample listings** across the Bay Area:

1. **Cozy Studio in Downtown SF** - $2,200/month
2. **Spacious 2BR Near UC Berkeley** - $3,200/month  
3. **Modern 1BR in Palo Alto** - $2,800/month
4. **Shared Room in Student House** - $1,200/month
5. **Luxury Condo in San Jose** - $3,800/month
6. **Charming House in Mountain View** - $4,500/month

Each listing includes:
- ✅ High-quality photos from Unsplash
- ✅ Detailed descriptions and amenities
- ✅ Accurate pricing and availability dates
- ✅ Real Bay Area locations with coordinates
- ✅ Property details (bedrooms, bathrooms, square footage)

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+

### Quick Start
1. **Clone the repository**
2. **Open in Xcode**
3. **Build and run** (⌘R)
4. **Explore the app** with sample data

### What You Can Try
- **Browse listings** in map and list views
- **Search and filter** by price, location, amenities
- **View listing details** with photo galleries
- **Sign in/up** with mock authentication
- **Post a listing** using the 4-step wizard
- **Save favorites** and manage your profile

## 🔧 Development Setup

### Option 1: Continue Without Firebase (Current)
The app works perfectly with mock authentication and sample data. Great for:
- ✅ Development and testing
- ✅ UI/UX exploration
- ✅ Feature development
- ✅ Demo presentations

### Option 2: Add Firebase (Production Ready)
Follow the [Firebase Setup Guide](FIREBASE_SETUP.md) to add real authentication:
- Real user accounts and authentication
- Cloud storage for images
- Analytics and crash reporting
- Production-ready backend integration

## 📊 App Structure

```
subleaseFinder/
├── Models/
│   ├── SubleaseListing.swift          # Core data models
│   └── SampleData.swift               # Demo listings
├── Services/
│   ├── APIClient.swift               # Network layer
│   ├── AuthService.swift             # Authentication
│   └── ListingService.swift          # Business logic
├── Flows/
│   └── AppFlow.swift                 # Navigation coordinator
├── Views/
│   ├── AppShellView.swift            # Main tab interface
│   ├── BrowseView.swift              # Search & browse
│   ├── PostView.swift                # Listing creation
│   ├── SavedView.swift               # Favorites
│   ├── ProfileView.swift             # User account
│   └── ListingDetailView.swift       # Detailed view
├── Config/
│   └── AppConfig.swift               # Environment settings
└── subleaseFinderApp.swift           # App entry point
```

## 🎨 User Experience

### Modern iOS Design
- **SwiftUI** with smooth animations
- **Dynamic Type** support for accessibility
- **Dark Mode** ready
- **iPhone & iPad** optimized

### Intuitive Navigation
- **Tab-based** main interface
- **Modal sheets** for detailed views
- **Swipe gestures** for quick actions
- **Contextual menus** for options

### Performance Optimized
- **Lazy loading** for images and lists
- **Debounced search** to reduce API calls
- **Image compression** for faster uploads
- **Cached results** for offline browsing

## 🔒 Privacy & Security

### Data Protection
- **HTTPS enforcement** for all network requests
- **Token-based authentication** with auto-refresh
- **Image upload** only via secure pre-signed URLs
- **PII filtering** in logs and analytics

### User Privacy
- **Location permission** with clear usage explanation
- **Photo access** limited to user selection
- **Anonymous browsing** without account requirement
- **Data export/deletion** capabilities

## 🧪 Testing

### Current Demo Features
- ✅ **Browse 6 sample listings** with real photos
- ✅ **Map view** with interactive pins
- ✅ **Search and filter** functionality
- ✅ **Listing details** with photo galleries
- ✅ **Authentication flow** (mock)
- ✅ **Post listing wizard** (4 steps)
- ✅ **Favorites system** (local storage)
- ✅ **Profile management** (mock)

### Ready for Production
- 🔄 **Real Firebase authentication**
- 🔄 **AWS backend integration**
- 🔄 **Live data and user accounts**
- 🔄 **Analytics and monitoring**

## 🚀 Deployment

### App Store Ready
- **Production configuration** available
- **Environment-specific** settings
- **Feature flags** for gradual rollout
- **Analytics integration** ready

### Backend Integration
- **AWS Lambda** functions ready
- **DynamoDB** schema defined
- **S3** image storage configured
- **API Gateway** endpoints mapped

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Follow coding standards
4. Add tests for new functionality
5. Submit pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**SubleaseFinder** - Making temporary housing simple and accessible! 🏠✨ 