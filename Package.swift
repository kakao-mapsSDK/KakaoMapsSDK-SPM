// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KakaoMapsSDK_SPM",
    platforms: [.iOS(.v13), .macCatalyst(.v13)],
    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "KakaoMapsSDK_SPM",
            targets: ["KakaoMapsSDK-SPM"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "KakaoMapsSDK-SPM",
            dependencies: ["framework"],
            resources: [.copy("KakaoMapsSDKBundle.bundle/assets")]),
        .binaryTarget(name: "framework", path: "BinaryFramework/KakaoMapsSDK.xcframework")
    ],
    swiftLanguageVersions: [.v5]
)
