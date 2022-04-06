// swift-tools-version:5.5

import PackageDescription

let package = Package(
    
    name      : "sensor_recording_utils",
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
