// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SubleaseFinder",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SubleaseFinder",
            targets: ["SubleaseFinder"]
        )
    ],
    dependencies: [
        // Firebase SDK
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        
        // Optional: For better image processing
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        
        // Optional: For better networking (alternative to URLSession)
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        
        // Optional: For better logging
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0")
    ],
    targets: [
        .target(
            name: "SubleaseFinder",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "SubleaseFinderTests",
            dependencies: ["SubleaseFinder"]
        )
    ]
)
