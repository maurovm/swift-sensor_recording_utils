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
    @Published public private(set) var interface_orientation : UIDeviceOrientation
    
    /**
     * Handle changes to the scale to preview content
     */
    @Published public private(set) var preview_mode : Device.Content_mode
    
    
    /**
     * To display the time of the recording process
     */
    @Published private(set) var recording_elapsed_time    : TimeInterval = 0
    
    @Published private(set) var system_temperature_state  : Temperature_state
    
    @Published private(set) var system_battery_percentage : Battery_percentage
    
    @Published private(set) var system_battery_state      : Battery_state
    
    
    /**
     * The list of cameras configured for the recording session
     */
    @Published public private(set) var all_cameras : [Device_manager] = []
    
    /**
     * The list of vital sign sensors configured for the recording session
     */
    @Published public private(set) var all_sensors : [Device_manager] = []
    
    
    /**
     * Are we currently recording from all devices?
     */
    @Published private(set) var is_recording = false
    
    /**
     * Has either the start or stop recording process been requested
     */
    @Published private(set) var is_session_in_progress = false
    
    /**
     * Flag that indicates the recording finished successfully, and now
     * we need to transition to the Summary View
     */
    @Published var recording_finished_successfully : Bool = false
    
    
    /**
     * An error occurred in the recording process
     */
    @Published var show_alert_error = false
    private(set) var alert_error : Error?
    
    
    
    public init(
            participant_id            : String ,
            interface_orientation     : UIDeviceOrientation = .portrait,
            preview_mode              : Device.Content_mode = .scale_to_fill,
            recording_elapsed_time    : TimeInterval        = 0,
            is_recording              : Bool                = false,
            is_session_in_progress    : Bool                = false,
            system_temperature_state  : Temperature_state?  = nil,
            system_battery_percentage : Battery_percentage? = nil,
            system_battery_state      : Battery_state?      = nil
        )
    {
        
        self.participant_id         = participant_id
        self.interface_orientation  = interface_orientation
        self.preview_mode           = preview_mode
        self.recording_elapsed_time = recording_elapsed_time
        self.is_recording           = is_recording
        self.is_session_in_progress = is_session_in_progress
        
        
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
    
    
    // MARK: - Private interface to handle adding/removing devices
    
    
    
    public final func add_camera( _ device: Device_manager )
    {
        
        add_device(device)
        all_cameras.append(device)
        
    }
    
    
    public final func add_sensor( _ device: Device_manager )
    {
        add_device(device)
        all_sensors.append(device)
    }
    
    
    /**
     * Add a device to recording set.
     *
     * Check if the device was not previously attached.
     * Chain the publishers for events requested from the UI
     */
    func add_device( _ device: Device_manager )
    {
        
        if all_device_managers.keys.contains(device.identifier)
        {
            fatalError(
                "Cannot add device '\(device.identifier)', it already exists"
            )
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
        
        all_cameras.removeAll()
        all_sensors.removeAll()
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
    
    
    // MARK: - Internal interface to Start/Stop the recording process
    
    
    /**
     * Start or stop the recording session
     */
    func toggle_recording_process()
    {

        // If we already requested to stop, do nothing
        
        if is_session_in_progress
        {
            if is_recording == false
            {
                start_recording_task?.cancel()
            }
            return
        }
        
        
        is_session_in_progress = true
        
        if is_recording
        {
            stop()
        }
        else
        {
            start()
        }
        
    }
    
    
    /**
     * Clean up all resources used by this class
     *
     * The UI will typically call this method
     */
    func end_session()
    {
        
        stop()
        
    }
    
    
    // MARK: - Private state
    
    
    /**
     * The unique identifier of the participant being recorded
     */
    private let participant_id: String
    
    private let system_identifier : Device.ID_type = "Phone"
    
    
    private var start_recording_task : Task<Void, Never>? = nil
    
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
    
    
    /**
     * The list of devices configured for the recording session
     */
    private var all_device_managers = Dictionary<Device.ID_type, Device_manager>()
    
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
    
    
    /**
     * Start the recording process for all the configured devices
     */
    private func start()
    {
            
        if is_recording
        {
            return
        }
        
        
        // Clean up previous tasks and devices if they exist
        
        
        start_recording_task?.cancel()
        start_recording_task = nil
        
        stop_recording_task?.cancel()
        stop_recording_task = nil
        
        remove_all_configured_devices()
        
        
        // Load the configured devices
        
        
        update_system_battery_percentage()
        add_all_configured_devices()
        
        
        // Start the recording process
        
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        start_recording_task = Task
        {
            [weak self] in
               
            let recording_status = await self?.start_data_recording()
            
            self?.is_session_in_progress = false
            
            if let status = recording_status ,
               (status == true)
            {
                self?.is_recording = true
            }
            else
            {
                self?.show_alert_error = true
            }
        }
        
    }
    
    
    // TODO: parallelise this Task
    private func start_data_recording() async -> Bool
    {
        
        if all_device_managers.values.count < 1
        {
            alert_error = Device.Connect_error.no_devices_configured
            return false
        }
        
        let is_recording_started : Bool
        
        do
        {
            subscribe_to_device_manager_events()
            
            try await connect_to_all_device_managers()
            try await start_recording_from_all_device_managers()
            
            start_recording_timer()
            is_recording_started = true
        }
        catch
        {
            is_recording_started = false
            _ = await stop_data_recording()
            alert_error = error
        }
                
        return is_recording_started

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
                    catch let error as Device.Recording_error
                    {
                        throw error
                    }
                    catch
                    {
                        throw  Device.Recording_error.failed_to_start(
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
            throw Device.Recording_error.failed_to_start_from_all_devices
        }
        
    }
    
    
    // MARK: - Private interface to STOP the recording process
    
    
    /**
     * Stop the recording process for all the configured devices
     */
    private func stop(
            there_was_a_previous_error : Bool = false
        )
    {
        
        if is_recording == false
        {
            start_recording_task?.cancel()
            return
        }
        
        
        // Clean up previous stop task if it exists
        
        
        stop_recording_task?.cancel()
        stop_recording_task = nil
        
        
        // Stop the recording process
                
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        stop_recording_task = Task
        {
            [weak self] in
                            
            let is_recording_stopped = await self?.stop_data_recording()
            
            // Clean up tasks
            
            
            self?.stop_recording_task?.cancel()
            self?.stop_recording_task = nil
            
            self?.start_recording_task?.cancel()
            self?.start_recording_task = nil
            
            // Finish recording process
            
            self?.is_recording  = false
            self?.is_session_in_progress = false
            
            // If there was a previous error, do nothing
            
            if let is_stopped = is_recording_stopped ,
               (there_was_a_previous_error == false)
            {
                
                if is_stopped
                {
                    self?.recording_finished_successfully = true
                }
                else
                {
                    self?.show_alert_error = true
                }
                
            }
            
        }
        
    }
    
    
    /**
     * Main asynchronous function to stop recording
     *
     * - Parameter  start_recording_result:  Flag to indicate if the
     *              the recording process started successfully.
     */
    private func stop_data_recording() async -> Bool
    {
        
        let is_recording_stopped      = await stop_recording_from_all_devices()
        let are_managers_disconnected = await discconnect_from_all_devices()
        
        unsubscribe_to_device_manager_events()
        stop_recording_timer()
        cancel_system_event_subscriptions()
        remove_all_configured_devices()
        
        return (is_recording_stopped && are_managers_disconnected)
        
    }
    
    
    /**
     *
     * We stop recording from all device managers one by one, not in parallel
     *
     * Returns: True unless there was an error stopping the recording from
     *          any device.
     *
     *          The last error will be stored in the property `alert_error`
     */
    private func stop_recording_from_all_devices() async -> Bool
    {
        
        var is_recording_stopped = true
        
        for device_manager in all_device_managers.values
        {
            do
            {
                try await device_manager.stop_recording()
            }
            catch let error as Device.Recording_error
            {
                alert_error = error
                is_recording_stopped  = false
            }
            catch
            {
                alert_error = Device.Recording_error.failed_to_stop(
                        device_id   : device_manager.identifier,
                        description : "Unhandled error while " +
                                      "stop recording from " +
                                      "device : " + error.localizedDescription
                    )
                is_recording_stopped = false
            }
        }
        
        return is_recording_stopped
        
    }
    
    
    /**
     *
     * We disconnect from all device managers one by one, not in parallel.
     *
     * Returns: True unless there was an error disconnecting from any device.
     *
     *          The last error will be stored in the property `alert_error`
     */
    private func discconnect_from_all_devices() async -> Bool
    {
        
        var are_all_manager_disconnected = true
        
        for device_manager in all_device_managers.values
        {
            do
            {
                try await device_manager.discconnect()
            }
            catch let error as Device.Disconnect_error
            {
                alert_error = error
                are_all_manager_disconnected  = false
            }
            catch
            {
                alert_error = Device.Disconnect_error.failure(
                        device_id   : device_manager.identifier,
                        description : "Unhandled error while " +
                                      "disconnecting from from device : " +
                                      error.localizedDescription
                    )
                are_all_manager_disconnected = false
            }
        }
        
        return are_all_manager_disconnected
        
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
                    self?.device_manager_event(event)
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
    
    
    private func device_manager_event( _  event : Device_manager_event )
    {
        
        switch event
        {
            case .recording_state_update(_,_):
                break
                
            case .device_disconnected(let device_id, let error):
                
                stop( there_was_a_previous_error: true )
                
                alert_error = Device.Disconnect_error.device_disconnected(
                        device_id   : device_id,
                        description : "\(error ?? "no error")"
                    )
                
                show_alert_error = true
                
            case .device_connect_timeout(let device_id):
                
                stop( there_was_a_previous_error: true )
                
                alert_error = Device.Connect_error.timeout(
                        device_id   : device_id,
                        description : ""
                    )
                
                show_alert_error = true
                
            case .device_start_timeout(let device_id):
                
                stop( there_was_a_previous_error: true )
                
                alert_error = Device.Recording_error.start_timeout(
                        device_id   : device_id,
                        description : ""
                    )
                
                show_alert_error = true
                
            case .fatal_error(
                        let device_id,
                        let description
                    ):
                
                stop( there_was_a_previous_error: true )
                
                alert_error = Device.Recording_error.fatal_error_while_recording(
                        device_id   : device_id,
                        description : description
                    )
                
                show_alert_error = true
                    
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
