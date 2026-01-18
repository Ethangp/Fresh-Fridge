# Fresh Fridge - Food Expiration Tracking App

A native iOS app built with SwiftUI and SwiftData to track food expiration dates, prevent waste, and help users know what to use next.

## Features

- **Barcode Scanning**: Scan UPC/EAN barcodes to quickly add items using OpenFoodFacts API
- **Manual Entry**: Fast manual entry with quick templates for common produce
- **FIFO Batch Tracking**: Automatically tracks batches and consumes oldest items first
- **Smart Dashboard**: Urgency-based grouping (Use Today, Next 3 Days, This Week, etc.)
- **Smart Notifications**: Category-based notification timing (produce: 1-2 days, fridge: 2-3 days, pantry: 14-30 days)
- **Search & Filter**: Search by name, filter by storage location
- **Photo Support**: Optional photos for visual reference
- **One-Handed UX**: Optimized with bottom sheets and haptic feedback

## Project Structure

```
FreshFridge/
├── App/
│   └── FreshFridgeApp.swift          # App entry point with SwiftData container
├── Models/
│   ├── FoodItem.swift                # SwiftData model with batch tracking
│   └── StorageLocation.swift         # Enum: pantry, fridge, freezer, other
├── ViewModels/
│   ├── HomeViewModel.swift           # Dashboard grouping and filtering logic
│   ├── AddItemViewModel.swift        # Item creation state management
│   └── BarcodeScannerViewModel.swift # Scanner state and API integration
├── Views/
│   ├── HomeView.swift                # Main dashboard with urgency sections
│   ├── AddItemView.swift             # Manual entry form
│   ├── BarcodeScannerView.swift      # Camera-based barcode scanner
│   ├── ItemDetailView.swift          # Item actions (consume, edit, delete)
│   ├── ItemRowView.swift             # List item component
│   └── Components/
│       └── UrgencySection.swift      # Grouped urgency sections
├── Services/
│   ├── OpenFoodFactsService.swift    # API client for product lookup
│   ├── NotificationService.swift     # Notification scheduling
│   └── FIFOService.swift             # Batch consumption logic
└── Utilities/
    ├── DateExtensions.swift          # Date helpers
    ├── Constants.swift               # App constants
    └── HapticFeedback.swift          # Haptic feedback helpers
```

## Setup Instructions

### 1. Create Xcode Project

1. Open Xcode
2. Create a new iOS App project
3. Set Product Name to "FreshFridge"
4. Choose SwiftUI for Interface
5. Choose SwiftData for Storage
6. Set minimum deployment to iOS 17.0 (for SwiftData)

### 2. Add Files

Copy all files from this directory structure into your Xcode project, maintaining the folder structure.

### 3. Configure Info.plist

Add the following keys to your `Info.plist` (or use the provided Info.plist):

- `NSCameraUsageDescription`: "We need camera access to scan barcodes on food products."
- `NSPhotoLibraryUsageDescription`: "We need photo library access to save photos of your food items."
- `NSPhotoLibraryAddUsageDescription`: "We need permission to save photos of your food items."

### 4. Build and Run

The app should build and run. On first launch, it will request camera and notification permissions.

## Key Implementation Details

### Data Model

- `FoodItem` uses SwiftData `@Model` macro
- Each item has a unique `batchId` for FIFO tracking
- `storageLocation` is stored as a String and converted via computed property

### FIFO Logic

When consuming items:
1. Find all items with the same name
2. Sort by `dateAdded` (oldest first)
3. Reduce quantity of oldest batch
4. Delete item if quantity reaches 0

### Notifications

- Scheduled when items are added/updated
- Cancelled when items are consumed/deleted
- Timing based on category and storage location
- Capped at 1 per day (except same-day expiration)

### Urgency Categories

- **Use Today**: Expires today
- **Next 3 Days**: Expires in 1-3 days
- **This Week**: Expires in 4-7 days
- **Expiring Soon**: Expires in 8-14 days
- **Later**: Expires in 15+ days
- **Expired**: Past expiration (hidden by default)

## Testing

To test the app:

1. **Barcode Scanning**: Use a real product barcode or test with OpenFoodFacts test codes
2. **Manual Entry**: Add items manually with different expiration dates
3. **FIFO**: Add multiple batches of the same item with different dates, then consume
4. **Notifications**: Add items with near-term expiration dates and verify notifications
5. **Search/Filter**: Test search by name and filter by location

## Future Enhancements (Out of MVP Scope)

- Recipe suggestions based on expiring items
- Receipt scanning
- Household sharing/cloud sync
- AI photo recognition
- Advanced analytics

## License

This project is part of the Fresh Fridge app implementation.
