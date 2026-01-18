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

## How to Run the Code in Xcode

### Prerequisites

- **macOS** with Xcode installed (Xcode 15.0 or later recommended)
- **iOS 17.0+** device or simulator for testing
- **Git** (usually pre-installed on macOS)
- Apple Developer account (free account works for simulator testing)

### Step-by-Step Setup Instructions

#### 1. Clone the Repository

**Option A: Using Terminal**

1. Open **Terminal** (Applications → Utilities → Terminal)
2. Navigate to where you want to clone the project:
   ```bash
   cd ~/Desktop  # or wherever you prefer
   ```
3. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Fresh-Fridge.git
   ```
   (Replace `yourusername` with the actual GitHub username/organization)
4. Navigate into the cloned directory:
   ```bash
   cd Fresh-Fridge
   ```

**Option B: Using Xcode**

1. Open **Xcode**
2. Go to **File → Clone Repository...** (or press `⌘⇧O` then select "Clone")
3. Enter the repository URL: `https://github.com/yourusername/Fresh-Fridge.git`
4. Choose a location to save the project
5. Click **Clone**

**Option C: Using GitHub Desktop**

1. Open **GitHub Desktop**
2. Click **File → Clone Repository**
3. Select the repository from GitHub
4. Choose a local path
5. Click **Clone**

#### 2. Create Xcode Project

Since this repository contains source files but not an Xcode project file, you'll need to create one:

1. Open **Xcode**
2. Go to **File → New → Project** (or press `⌘⇧N`)
3. Select **iOS** tab at the top
4. Choose **App** template
5. Click **Next**

#### 3. Configure Project Settings

Fill in the project details:

- **Product Name**: `FreshFridge`
- **Team**: Select your Apple Developer team (or leave as "None" for simulator-only)
- **Organization Identifier**: e.g., `com.yourname` (required)
- **Bundle Identifier**: Will auto-generate from Product Name and Organization Identifier
- **Interface**: Select **SwiftUI**
- **Language**: Select **Swift**
- **Storage**: Select **SwiftData** (important!)
- **Include Tests**: Optional

Click **Next**.

#### 4. Save Project in Cloned Repository

1. Navigate to the cloned `Fresh-Fridge` directory
2. **Important**: Save the project in the root of the repository (same level as the `FreshFridge` source folder)
3. **Do NOT** check "Create Git repository" (the repo already exists)
4. Click **Create**

#### 5. Replace Default Files with Repository Files

1. In Xcode's Project Navigator, delete the default files:
   - Right-click `FreshFridgeApp.swift` → **Delete → Move to Trash**
   - Right-click `ContentView.swift` → **Delete → Move to Trash** (if it exists)

2. Add the source files from the repository:
   - In Finder, navigate to the cloned repository's `FreshFridge` folder
   - Drag the entire `FreshFridge` folder (containing App, Models, Views, etc.) into Xcode's Project Navigator
   - In the dialog that appears:
     - ✅ Check **"Copy items if needed"** (uncheck if you want to reference the original files)
     - ✅ Check **"Create groups"** (not "Create folder references")
     - ✅ Select **FreshFridge** target
     - Click **Finish**

#### 6. Configure Project Settings

1. In the Project Navigator, click on the **FreshFridge** project (blue icon at the top)
2. Select the **FreshFridge** target under "TARGETS"
3. Go to the **General** tab
4. Under **Deployment Info**, set **iOS** to **17.0** (required for SwiftData)

#### 7. Verify Info.plist Permissions

The repository includes an `Info.plist` file with the required permissions. Make sure it's added to your project:

1. In Xcode, locate `Info.plist` in the Project Navigator
2. If it's not there, add it:
   - Right-click on the project → **Add Files to "FreshFridge"...**
   - Navigate to the `FreshFridge` folder in the repository
   - Select `Info.plist`
   - Make sure **"Copy items if needed"** is checked
   - Select **FreshFridge** target
   - Click **Add**

3. Verify the permissions are set:
   - Right-click `Info.plist` → **Open As → Source Code**
   - It should contain:
     ```xml
     <key>NSCameraUsageDescription</key>
     <key>NSPhotoLibraryUsageDescription</key>
     <key>NSPhotoLibraryAddUsageDescription</key>
     ```

#### 8. Build the Project

1. Press **⌘B** (or go to **Product → Build**)
2. Check for any errors in the Issue Navigator (⚠️ icon in left sidebar)
3. If you see errors about missing files, make sure all files from the `FreshFridge` folder are added to the target

#### 9. Run the App

**On iOS Simulator:**

1. At the top of Xcode, click the device selector (next to the play button)
2. Choose an **iPhone** simulator (e.g., "iPhone 15 Pro" or "iPhone 15")
3. Make sure it's running **iOS 17.0 or later**
4. Click the **Play button** (▶️) or press **⌘R**
5. Wait for the simulator to launch and the app to build

**On Physical Device:**

1. Connect your iPhone/iPad via USB
2. Unlock your device and trust the computer if prompted
3. In Xcode, select your device from the device selector
4. You may need to set up code signing:
   - Go to **Signing & Capabilities** tab
   - Select your **Team**
   - Xcode will automatically manage provisioning
5. Click the **Play button** (▶️) or press **⌘R**
6. On your device, go to **Settings → General → VPN & Device Management** and trust the developer certificate

#### 10. First Launch

When you first run the app:

1. The app will request **Camera** permission (for barcode scanning) - tap **Allow**
2. The app will request **Notification** permission - tap **Allow**
3. You'll see the empty home screen with options to add items

### Updating the Code

To pull the latest changes from GitHub:

1. In Terminal, navigate to the repository:
   ```bash
   cd ~/path/to/Fresh-Fridge
   ```
2. Pull the latest changes:
   ```bash
   git pull
   ```
3. In Xcode, the files will update automatically if you didn't check "Copy items if needed"

### Troubleshooting

**Build Errors:**
- Make sure all files from the `FreshFridge` folder are added to the **FreshFridge** target
- Check File Inspector (right sidebar) for each file to verify target membership
- Verify iOS deployment target is set to **17.0**
- Clean build folder: **Product → Clean Build Folder** (⌘⇧K), then rebuild

**Camera Not Working:**
- Simulator doesn't support camera - use a physical device for barcode scanning
- Check that `NSCameraUsageDescription` is in Info.plist

**SwiftData Errors:**
- Ensure iOS deployment target is **17.0 or later**
- Make sure you selected **SwiftData** when creating the project

**Missing Files:**
- Verify all files from the repository's `FreshFridge` folder are added to the Xcode project
- Check that folder structure matches the expected layout
- Make sure files have the correct target membership (check in File Inspector)

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
