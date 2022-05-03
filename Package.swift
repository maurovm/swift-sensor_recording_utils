// swift-tools-version:5.5

import PackageDescription

let package = Package(
    
    name      : "swift-sensor_recording_utils",
    platforms : [ .iOS("15.4") ],
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
