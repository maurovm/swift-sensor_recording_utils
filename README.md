# SensorRecordingUtils

A module containing shared utility methods and classes used by the other
modules and application to record raw data from sensors such as video cameras,
and pulse oximeters


SensorRecordingUtils is free software: you can redistribute it or modify it
under the terms of the GNU General Public License as published by the Free 
Software Foundation, version 2 only. Please check the file [COPYING](COPYING) 
for more information on the license and copyright.

If you use this app in your projects and publish the results, please cite the 
following manuscript:

> Villarroel, M. and Davidson, S. "Open-source software mobile platform for
physiological data acquisition". arXiv (In preparation). 2022

---

Examples of other modules making use of SensorRecordingUtils are:

- [swift-async_bluetooth](https://github.com/maurovm/swift-async_bluetooth): 
A Swift Package that replicates some of the functionality provided by Apple's
CoreBluetooth module, but using Swift's latest async/await concurrency features.
- [swift-async_pulse_ox](https://github.com/maurovm/swift-async_pulse_ox): A 
Swift Package containing the functionality to connect and record time-series 
data from devices that support Bluetooth Low Energy (BLE) protocol, such as 
heart rate monitors and pulse oximeters. Examples of supported time-series are
heart rate, peripheral oxygen saturation (SpO<sub>2</sub>), Photoplethysmogram
(PPG), battery status and more.
- [swift-waveform_plotter](https://github.com/maurovm/swift-waveform_plotter): 
A library to plot physiological time-series such as the Photoplethysmogram (PPG).
- [swift-thermal_camera](https://github.com/maurovm/swift-thermal_camera): The
main module that has all the functionality to connect and record data from
thermal cameras. 
- [swift-ios_thermal_sdk](https://github.com/maurovm/swift-ios_thermal_sdk): A
Swift Package wrapping the multi-plaftform XCFrameworks for FLIR Mobile SDK.

Examples of other applications making use of the above Swift Packages are:

- [swift-pulse_ox_recorder](https://github.com/maurovm/swift-pulse_ox_recorder):
Application to record time-series data from devices that support Bluetooth 
Low Energy (BLE) protocol, such as heart rate monitors and pulse oximeters.
- [swift-thermal_recorder](https://github.com/maurovm/swift-thermal_recorder): 
The main application (XCode, Settings.bundle, etc) to record video from the 
thermal cameras such as the FLIR One Pro.
- [swift-waveform_plotter_example](https://github.com/maurovm/swift-waveform_plotter_example): Example application to plot time-series data.
