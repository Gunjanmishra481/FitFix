# FitFix - Your Personal Fashion Assistant

FitFix is an iOS application that helps users manage their wardrobe, get outfit recommendations, and plan their outfits for different occasions. The app uses machine learning models to classify and recommend clothing items.

## Features

- Wardrobe Management
- Outfit Recommendations


## Requirements

- iOS 14.0+
- Xcode 13.0+
- CocoaPods
- Google Cloud Project with Google Sign-In enabled

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Gunjanmishra481/FitFix.git
```

2. Install dependencies using CocoaPods:
```bash
cd FitFix
pod install
```

3. Set up Google Sign-In:
   - Go to the [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project or select an existing one
   - Enable Google Sign-In API
   - Create iOS credentials
   - Download the `GoogleService-Info.plist` file
   - Copy the file to the `FitFix` directory
   - A template file `GoogleService-Info.template.plist` is provided as an example

4. Open `FitFix.xcworkspace` in Xcode.

5. Build and run the project.

## ML Models

This project uses several machine learning models for clothing classification:

- `modelTop.mlpackage`: Model for classifying top wear
- `modelBottom.mlpackage`: Model for classifying bottom wear
- `modelShoes.mlpackage`: Model for classifying footwear
- `displayDailyRecommendation.mlpackage`: Model for outfit recommendations

The models are stored using Git LFS due to their large size. To properly clone the repository with the models:

1. Install Git LFS:
```bash
brew install git-lfs
```

2. Clone the repository with LFS:
```bash
git lfs install
git clone https://github.com/Gunjanmishra481/FitFix.git
```

## Dependencies

- GoogleSignIn
- Instructions
- AppAuth
- GTMAppAuth
- GTMSessionFetcher

## Security

⚠️ Important: The `GoogleService-Info.plist` file contains sensitive API keys and is not included in the repository. You must:
1. Create your own Google Cloud project
2. Enable necessary APIs
3. Generate your own `GoogleService-Info.plist`
4. Add it to the project
5. Never commit this file to version control

