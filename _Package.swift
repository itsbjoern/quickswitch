// // swift-tools-version:5.0
// // The swift-tools-version declares the minimum version of Swift required to build this package.

// import PackageDescription

// let package = Package(
//   name: "vechsel",
//   platforms: [
//     // Platforms declare which platforms this package can be used on.
//     .macOS(.v10_14)  // macOS 10.14 is the minimum supported version
//   ],

//   targets: [
//     // Targets are the basic building blocks of a package. A target can define a module or a test suite.
//     // Targets can depend on other targets in this package, and on products in packages which this package depends on.
//     .target(
//       name: "vechsel",

//       dependencies: ["ApplicationsOrdered", "SkyLight"],
//       path: "src/app"
//     ),
//     .target(
//       name: "ApplicationsOrdered",
//       path: "src/libc/ApplicationsOrdered"
//     ),
//     .target(
//       name: "SkyLight",
//       path: "src/libc/SkyLight"
//     ),
//   ]
// )
