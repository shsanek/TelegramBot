// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TelegramBot",
    products: [
		.executable(name: "Bot", targets: ["Bot"])
    ],
	dependencies: [
		.package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0")),
		.package(url: "https://github.com/shsanek/SwiftTelegramApi", .branch("master"))
	],
    targets: [
		.target(name: "Bot", dependencies: ["TelegramAPI", "Swifter"])
    ]
)
