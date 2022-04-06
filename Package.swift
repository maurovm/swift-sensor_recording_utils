// swift-tools-version:5.5

import PackageDescription

let package = Package(
    
    name      : "SensorRecordingUtils",
    platforms : [ .iOS("15.2") ],
    products  :
        [
            .library(
                name    : "SensorRecordingUtils",
                targets : ["SensorRecordingUtils"]
            ),
        ],
    dependencies: [],
    targets:
        [
            .target(
                name         : "SensorRecordingUtils",
                dependencies : [],
                path         : "Sources"
            )
        ]

)
