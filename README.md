# FitFix - Your Personal Fashion Assistant

FitFix is an iOS application that helps users manage their wardrobe, get outfit recommendations, and plan their outfits for different occasions. The app uses machine learning models to classify and recommend clothing items.

## Features

- Wardrobe Management
- Outfit Recommendations



## Requirements

- iOS 14.0+
- Xcode 13.0+
- CocoaPods

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

3. Open `FitFix.xcworkspace` in Xcode.

4. Build and run the project.

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

## License

This project is licensed under the MIT License - see the LICENSE file for details. 