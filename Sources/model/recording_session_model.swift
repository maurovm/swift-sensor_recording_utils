/**
 * \file    recording_session_model.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 4, 2021
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation
import UIKit
import Combine


/**
 * The main class that will manage the entire recording process. It will
 * controll the capture tasks for all the devices we are configuring
 */
@MainActor
open class Recording_session_model : ObservableObject
{
    
    /**
     * Handle changes to the interface orientation
     */
    @Published final public private(set) var interface_orientation : UIDeviceOrientation
    
    /**
     * Handle changes to the scale to preview content
     */
    @Published final public private(set) var preview_mode : Device.Content_mode
    
    
    /**
     * To display the time of the recording process
     */
    @Published private(set) var recording_elapsed_time    : TimeInterval = 0
    
    @Published private(set) var system_temperature_state  : Temperature_state
    
    @Published private(set) var system_battery_percentage : Battery_percentage
    
    @Published private(set) var system_battery_state      : Battery_state
    
    
    /**
     * The list of devices configured for the recording session
     */
    @Published final public private(set) var all_device_managers =
        Dictionary<Device.ID_type, Device_manager>()
    
    /**
     * The list of cameras configured for the recording session
     */
    final public var all_video_cameras : [Device_manager]
    {
        all_device_managers.values.filter
        {
            $0.sensor_type == .video_camera
        }
    }
    
    /**
     * The list of vital sign sensors configured for the recording session
     */
    final public var all_pulse_oximeters : [Device_manager]
    {
        all_device_managers.values.filter
        {
            $0.sensor_type == .pulse_oximeter
        }
    }
    
    
    private(set) var recording_state : Device.Recording_state
    
    
    /**
     * An error occurred in the recording process
     */
    @Published var show_recording_alert = false
    
    private(set) var recording_error : Error? = nil
    
    @Published var recording_finished_successfully = false
    
    
    /**
     * An error occurred in the recording process
     */
    @Published var show_device_manager_alert = false
    private(set) var device_manager_error: Error? = nil
    
    
    
    public init(
            participant_id            : String ,
            interface_orientation     : UIDeviceOrientation    = .portrait,
            preview_mode              : Device.Content_mode    = .scale_to_fill,
            recording_elapsed_time    : TimeInterval           = 0,
            recording_state           : Device.Recording_state = .disconnected,
            system_temperature_state  : Temperature_state?     = nil,
            system_battery_percentage : Battery_percentage?    = nil,
            system_battery_state      : Battery_state?         = nil
        )
    {
        
        self.participant_id         = participant_id
        self.interface_orientation  = interface_orientation
        self.preview_mode           = preview_mode
        self.recording_elapsed_time = recording_elapsed_time
        self.recording_state        = recording_state
        
        
        self.recording_state = .disconnected
        
        
        if let temperature_state = system_temperature_state
        {
            self.system_temperature_state = temperature_state
        }
        else
        {
            self.system_temperature_state = .init(
                    device_id: system_identifier, value: .nominal
                )
        }
        
        
        if let battery_percentage = system_battery_percentage
        {
            self.system_battery_percentage = battery_percentage
        }
        else
        {
            self.system_battery_percentage = .init(
                    device_id: system_identifier, value: 0
                )
        }
        
        
        if let battery_state = system_battery_state
        {
            self.system_battery_state = battery_state
        }
        else
        {
            self.system_battery_state = .init(
                    device_id: system_identifier, value: .unknown
                )
        }
        
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
    }
    
    
    // MARK: - Public interface to handle adding/removing devices
    
    
    /**
     * Add a device to recording set.
     *
     * Check if the device was not previously attached.
     * Chain the publishers for events requested from the UI
     */
    final public func add_device( _ device: Device_manager )
    {
        
        if all_device_managers.keys.contains(device.identifier)
        {
            return
        }
        
        
        $interface_orientation
            .assign(to: \.interface_orientation, on: device)
            .store(in: &ui_changes_subscriptions)
        
        $preview_mode
            .assign(to: \.preview_mode, on: device)
            .store(in: &ui_changes_subscriptions)
        
        all_device_managers[device.identifier] = device
        
    }
    
    
    func remove_all_configured_devices()
    {
        
        for subscriptions in ui_changes_subscriptions
        {
            subscriptions.cancel()
        }
        ui_changes_subscriptions.removeAll()
        
        all_device_managers.removeAll()
        
    }
    
    
    /**
     * Add all configured devices to the recording set
     */
    open func add_all_configured_devices()
    {
        preconditionFailure("This method must be overridden")
    }
    
    
    
    // MARK: - Internal interface to change UI orientation and Zoom
    
    
    /**
     * Changes the zoom level of all the devices that support it
     */
    func toggle_device_preview()
    {
        
        preview_mode = preview_mode.toggle()
        
    }
    
    
    /**
     * Change interface orientation
     */
    func change_interface_orientation(_ orientation: UIDeviceOrientation)
    {
        
        if  (orientation.isValidInterfaceOrientation)  &&
            (orientation != .unknown)
        {
            interface_orientation = orientation
        }
        
    }
    
    
    // MARK: - Internal interface to respond to system events
    
    
    func register_for_system_events()
    {
        
        register_for_system_battery_percentage_changes()
        register_for_system_battery_state_changes()
        register_for_system_temperature_state_changes()
        
    }
    
    
    func cancel_system_event_subscriptions()
    {
        
        for subscription in system_event_subscriptions
        {
            subscription.cancel()
        }

        system_event_subscriptions.removeAll()
        
    }
    
    
    // MARK: - Public interface to Start/Stop the recording process
    
    
    func toggle_recording_process() async
    {
        
        do
        {
            if recording_state == .disconnected
            {
                try await start_recording()
            }
            else if (recording_state == .connecting) ||
                    (recording_state == .streaming)
            {
                try await stop_recording()
                recording_finished_successfully = true
            }
            else
            {
                // do nothing
            }
        }
        catch
        {
            recording_error = error
            show_recording_alert = true
        }
        
    }
    
    
    func end_recording_session() async -> Bool
    {
        let result : Bool
        
        do
        {
            try await stop_recording()
            result = true
        }
        catch
        {
            result = false
            recording_error = error
            show_recording_alert = true
        }
        
        return result
    }
    
    
    // MARK: - Private state
    
    
    /**
     * The unique identifier of the participant being recorded
     */
    private let participant_id: String
    
    private let system_identifier : Device.ID_type = "Phone"
    
    
    private var recording_task : Task<Void, Error>? = nil
    
    private var stop_recording_task  : Task<Void, Never>? = nil
    
    
    /**
     * The reference timestamp from which we will compute the elapsed
     * recording time
     */
    private var recording_starting_time = Date()
    
    /**
     * The actual timer task
     */
    private var recording_timer : AnyCancellable?
    
    /**
     * The recording timer counter will run every second
     */
    private let recording_timer_interval : TimeInterval = 1.0
    
    
    /**
     * The battery reader timer counter will run every 30 seconds
     */
    private let system_battery_timer_interval : TimeInterval = 1.0
    
    
    /**
     * Subscription to system event, such as : battery level, thermal state,
     * etc
     */
    private var system_event_subscriptions = Set<AnyCancellable>()
    
    /**
     * The collection of subscriptions to publishers for events from the UI
     */
    private var ui_changes_subscriptions = Set<AnyCancellable>()
    
    private var device_manager_event_subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - Private utility methods to handle system state changes
    
    
    private func register_for_system_battery_percentage_changes()
    {
        
        update_system_battery_percentage()
        
        if system_event_subscriptions.isEmpty == false
        {
            return
        }
        
        Timer.publish(
                every : system_battery_timer_interval,
                on    : .main,
                in    : .common
            )
            .autoconnect()
            .sink
            {
                [weak self] _ in
                
                self?.update_system_battery_percentage()
            }
            .store(in: &system_event_subscriptions)
        
    }
    
    
    private func register_for_system_battery_state_changes()
    {
        
        update_system_battery_state()
        
        if system_event_subscriptions.isEmpty == false
        {
            return
        }
        
        NotificationCenter.Publisher(
                center : .default,
                name   : UIDevice.batteryStateDidChangeNotification
            )
            .receive(on: RunLoop.main)
            .sink
            {
                [weak self] _ in
                
                self?.update_system_battery_state()
            }
            .store(in: &system_event_subscriptions)
          
    }
    
    
    private func register_for_system_temperature_state_changes()
    {
        
        update_system_temperature_state()
        
        if system_event_subscriptions.isEmpty == false
        {
            return
        }
        
        NotificationCenter.Publisher(
                center : .default,
                name   : ProcessInfo.thermalStateDidChangeNotification
            )
            .receive(on: RunLoop.main)
            .sink
            {
                [weak self] _ in
                
                self?.update_system_temperature_state()
            }
            .store(in: &system_event_subscriptions)
        
    }
    
    
    private func update_system_battery_percentage()
    {
        
        let percentage = Int(UIDevice.current.batteryLevel * 100)
        system_battery_percentage.value = percentage
        
    }
    
    
    @objc private func update_system_battery_state()
    {

        system_battery_state.value = UIDevice.current.batteryState
        
    }
    
    
    @objc private func update_system_temperature_state()
    {
                
        system_temperature_state.value = ProcessInfo.processInfo.thermalState
        
    }
    
    
    // MARK: - Private interface to START the recording process
    
    
    private func start_recording() async throws
    {
        
        if recording_state != .disconnected
        {
            return
        }
        
        
        UIApplication.shared.isIdleTimerDisabled = true
        recording_state = .connecting
        
        
        recording_task = Task
        {
            [weak self] in
            
            guard let self = self
                else
                {
                    throw Device.Connect_error.task_cancelled
                }
            
            self.add_all_configured_devices()
            
            if self.all_device_managers.isEmpty
            {
                throw Device.Connect_error.no_devices_configured
            }
            
            self.subscribe_to_device_manager_events()
            
            try await self.connect_to_all_device_managers()
            
            //do{ try await Task.sleep(seconds: 5) } catch {}
            
            try await self.start_recording_from_all_device_managers()
        }
        
        
        do
        {
            
            defer
            {
                recording_task = nil
            }
            
            guard let local_task = recording_task
                else
                {
                    throw Device.Connect_error.task_cancelled
                }
            
            let result = await local_task.result
            
            if local_task.isCancelled == false
            {
                try result.get()
                
                start_recording_timer()
                recording_state = .streaming
            }
            
        }
        catch
        {
            
            do
            {
                try await stop_recording()
            }
            catch
            {
            }
            
            throw error
        }
        
    }
    
    
    /**
     *
     * Throws: In case of failure, it throws `Device.Connect_error`
     */
    private func connect_to_all_device_managers() async throws
    {
        
        let recording_session_id = participant_id + "-" + current_timestamp()

        let number_of_connected_managers = try await withThrowingTaskGroup(
                of        : Bool.self,
                returning : Int.self
            )
        {
            task_group -> Int in

            for device_manager in all_device_managers.values
            {
                let task_added = task_group.addTaskUnlessCancelled()
                {

                    var is_connected = false

                    do
                    {
                        is_connected = try await device_manager.connect(
                                session_id: recording_session_id
                            )
                    }
                    catch let error as Device.Connect_error
                    {
                        throw error
                    }
                    catch
                    {
                        throw  Device.Connect_error.failure(
                                device_id   : device_manager.identifier,
                                description : "Unhandled error while " +
                                              "connecting to device : " +
                                              error.localizedDescription
                            )
                    }

                    return is_connected
                }

                if task_added == false
                {
                    break
                }
            }

            var connected_managers_count = 0

            for try await manager_connected in task_group
            {
                connected_managers_count += ( manager_connected ? 1 : 0 )
            }

            return connected_managers_count
        }


        if (number_of_connected_managers != all_device_managers.values.count)
        {
            throw Device.Connect_error.failed_to_connect_to_all_devices
        }
        
    }
    
    
    /**
     * Start recording from all devices
     *
     * We use two do-catch blocks so we can handle the case when a device
     * throws an unknown error, we then stop recording from all other
     * devices
     */
    private func start_recording_from_all_device_managers() async throws
    {
            
        let number_of_started_managers = try await withThrowingTaskGroup(
                of        : Bool.self,
                returning : Int.self
            )
        {
            task_group -> Int in
                        
            for device_manager in all_device_managers.values
            {
                let device_id = device_manager.identifier
                
                let task_added = task_group.addTaskUnlessCancelled()
                {
                    var is_started = false
                    
                    do
                    {
                        is_started = try await device_manager.start_recording()
                    }
                    catch let error as Device.Start_recording_error
                    {
                        throw error
                    }
                    catch
                    {
                        throw  Device.Start_recording_error.failed_to_start(
                                device_id   : device_id,
                                description : "Unhandled error while " +
                                              "starting to record from " +
                                              "device : " +
                                              error.localizedDescription
                            )
                    }
                    
                    return is_started
                }
                
                if task_added == false
                {
                    break
                }
            }
            
            var started_managers_count = 0

            for try await manager_started in task_group
            {
                started_managers_count += ( manager_started ? 1 : 0 )
            }
            
            return started_managers_count
        }
        
        if (number_of_started_managers != all_device_managers.values.count)
        {
            throw Device.Start_recording_error.failed_to_start_from_all_devices
        }
        
    }
    
    
    // MARK: - Private interface to STOP the recording process
    
    
    /**
     * Stop the recording process for all the configured devices
     */
    private func stop_recording() async throws
    {
        
        if recording_state == .disconnected
        {
            return
        }
        
        recording_state = .stopping
        
        
        if let local_task = recording_task
        {
            local_task.cancel()
            let _ = await local_task.result
        }
        
        let stop_result = await stop_recording_from_all_devices()
        
        recording_state = .disconnecting
        
        let disconnect_result = await discconnect_from_all_devices()
        
        unsubscribe_to_device_manager_events()
        stop_recording_timer()
        cancel_system_event_subscriptions()
        remove_all_configured_devices()
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        try stop_result.get()
        try disconnect_result.get()
        
        recording_state = .disconnected
        
    }
    
    
    /**
     *
     * We stop recording from all device managers one by one, not in parallel
     *
     * Returns: .success unless there was an error stopping the recording from
     *          any device
     */
    private func stop_recording_from_all_devices() async -> Result<Void, Error>
    {
        
        var result : Result<Void, Error> = .success( () )
        
        for device_manager in all_device_managers.values
        {
            do
            {
                try await device_manager.stop_recording()
            }
            catch let error as Device.Stop_recording_error
            {
                result = .failure(error)
            }
            catch
            {
                let new_error = Device.Stop_recording_error.failed_to_stop(
                        device_id   : device_manager.identifier,
                        description : "Unhandled error while " +
                                      "stop recording from " +
                                      "device : " + error.localizedDescription
                    )
                result = .failure(new_error)
            }
        }
        
        return result
        
    }
    
    
    /**
     *
     * We disconnect from all device managers one by one, not in parallel.
     *
     * Returns: True unless there was an error disconnecting from any device.
     *
     *          The last error will be stored in the property `alert_error`
     */
    private func discconnect_from_all_devices() async -> Result<Void, Error>
    {
        
        var result : Result<Void, Error> = .success( () )
        
        for device_manager in all_device_managers.values
        {
            do
            {
                try await device_manager.discconnect()
            }
            catch let error as Device.Disconnect_error
            {
                result = .failure(error)
            }
            catch
            {
                let new_error = Device.Disconnect_error.failure(
                        device_id   : device_manager.identifier,
                        description : "Unhandled error while " +
                                      "disconnecting from from device : " +
                                      error.localizedDescription
                    )
                result = .failure(new_error)
            }
        }
        
        return result
        
    }

    
    // MARK: - Private interface to handle device manager events
    
    
    private func subscribe_to_device_manager_events()
    {
        
        for device_manager in all_device_managers.values
        {
            device_manager.$manager_event
                .sink
                {
                    [weak self] event in
                    self?.new_event_from_device_manager(event)
                }
                .store(in: &device_manager_event_subscriptions)
        }
        
    }
    
    
    private func unsubscribe_to_device_manager_events()
    {
        
        for subscription in device_manager_event_subscriptions
        {
            subscription.cancel()
        }
        
        device_manager_event_subscriptions.removeAll()
        
    }
    
    
    private func new_event_from_device_manager( _  event : Device_manager_event )
    {
        
        switch event
        {
            case .not_set:
                device_manager_error = nil
                
            case .recording_state_update(_,_):
                device_manager_error = nil
                
            case .device_disconnected(let device_id, let error):
                
                device_manager_error = Device.Recording_error.device_disconnected(
                        device_id   : device_id,
                        description : "\(error ?? "no error")"
                    )
                show_device_manager_alert = true
                
            case .device_connect_timeout(let device_id):
                
                device_manager_error = Device.Recording_error.connection_timeout(
                        device_id   : device_id,
                        description : ""
                    )
                show_device_manager_alert = true
                
            case .device_start_timeout(let device_id):
                
                device_manager_error = Device.Recording_error.start_timeout(
                        device_id   : device_id,
                        description : ""
                    )
                show_device_manager_alert = true
                
            case .fatal_error(
                        let device_id,
                        let description
                    ):
                
                device_manager_error = Device.Recording_error.fatal_error_while_recording(
                        device_id   : device_id,
                        description : description
                    )
                show_device_manager_alert = true
                    
        }
        
    }
    
    
    // MARK: - System event methods
    
    
    /**
     * Recreate the recording timer and start sreaming the elapsed time
     * counter to any subscriber
     */
    private func start_recording_timer()
    {
        
        stop_recording_timer()
        recording_starting_time  = Date()
        
        recording_timer = Timer.publish(
                every : recording_timer_interval,
                on    : .main,
                in    : .common
            )
            .autoconnect()
            .map
            {
                [weak self] new_timestamp in
                let start_time = self?.recording_starting_time ?? Date()
                return new_timestamp.timeIntervalSince(start_time)
            }
            .sink
            {
                [weak self] value in
                self?.recording_elapsed_time = value
            }
        
    }
    
    
    /**
     * Stop the recording counter
     */
    private func stop_recording_timer()
    {
        
        recording_timer?.cancel()
        
    }
    
    
    
    // MARK: - Utility methods
    
    
    /**
     * Return the current date/time as a formatted string
     */
    private func current_timestamp() -> String
    {
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy_MM_dd-HH_mm_ss"
        
        return formatter.string(from: Date())
    }
    
    
}
