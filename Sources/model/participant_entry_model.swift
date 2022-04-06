/**
 * \file    participant_entry_model.swift
 * \author  Mauricio Villarroel
 * \date    Created: Apr 1, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI
import Combine


@MainActor
open class Participant_entry_model: ObservableObject
{
    
    
    @Published public final var participant_id          : String = ""
    
    @Published public final var all_temperature_states  : [Temperature_state]  = []
    
    @Published public final var all_battery_percentages : [Battery_percentage] = []
    
    @Published public final var all_battery_states      : [Battery_state]      = []
        
    @Published public final var system_message          : String? = nil
    
    
    public final var setup_error       : Setup_error?   = nil
    
    public final let system_identifier : Device.ID_type = "Phone"
    
    
    public init()
    {
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
    }
    
    
    public convenience init(
            temperature_state  : [Temperature_state]  = [],
            battery_percentage : [Battery_percentage] = [],
            battery_state      : [Battery_state]      = [],
            system_message     : String?              = nil
        )
    {
        
//        print( "Participant_entry_model : init")
        
        self.init()
                
        
        if temperature_state.isEmpty == false
        {
            self.all_temperature_states.append(contentsOf: temperature_state)
        }
        
        
        if battery_percentage.isEmpty == false
        {
            self.all_battery_percentages.append(contentsOf: battery_percentage)
        }
        
        
        if battery_state.isEmpty == false
        {
            self.all_battery_states.append(contentsOf: battery_state)
        }
         
        
        self.system_message = system_message
        
    }
    
    
//    deinit
//    {
//
//        print( "Participant_entry_model : deinit")
//
//    }
    
    
    // MARK: - Responde system events
    
    
    
    open func register_for_system_events()
    {

//        print( "Participant_entry_model : register_for_system_events")
        
        register_for_system_battery_percentage_changes()
        register_for_system_battery_state_changes()
        register_for_system_temperature_state_changes()
        
    }
    
    
    open func cancel_system_event_subscriptions()
    {
        
//        print( "Participant_entry_model : cancel_system_event_subscriptions")
        
        for subscription in system_event_subscriptions
        {
            subscription.cancel()
        }

        system_event_subscriptions.removeAll()
        
    }
    
    
    // MARK: - Validation of recording settings
    
    
    /**
     * Verify all the information required is valid before start recoding
     * data
     */
    open func is_configuration_valid() async -> Bool
    {
        
//        print( "Participant_entry_model : is_configuration_valid")
        
        // Check system state

        if is_temperature_state_high()
        {
            setup_error = .system_thermal_state(
                    maximum: settings.maximum_thermal_state
                )
            return false
        }


        if is_battery_level_low()
        {
            setup_error = .system_battery_level(
                    minimum: settings.minimum_battery_percentage
                )
            return false
        }


        // Check the user entered all the required information


        format_participant_id()
        if is_participant_id_empty()
        {
            setup_error = .no_participant_id
            return false
        }
        
        
        save_last_particpant_id()
        
        return true
        
    }
    
    
    /**
     * Replace invalid characters in the participant ID string
     */
    func format_participant_id()
    {
        
        participant_id = participant_id.trimmingCharacters(
                in: .whitespacesAndNewlines)
        
        participant_id = participant_id.replacingOccurrences(
                of: " ", with: "_")
        
    }
    
    
    // MARK: - Loading configuration settings
    
    
    public func load_settings_bundle()
    {
        
        if is_first_time_running()
        {
            copy_configuration_from_settings_bundle()
            save_application_version()
        }
        
    }
    
    
    /**
     * For convinience, load the ID of the last participant recorded from
     * UserDefaults data store
     */
    public func load_last_particpant_id()
    {
        
        if let value = UserDefaults.standard.string(forKey: participant_id_key)
        {
            participant_id = value
        }
        
    }
    
    
    
    // MARK: - Private state
    
    
    /**
     * The name of the key, in the UserDefaults data store, of the ID
     * of the last participant recorded
     */
    private let participant_id_key = "participant_id"
    
    /**
     * Application settings
     */
    private let settings = Recording_settings()
    
    /**
     * The battery reader timer counter will run every 30 seconds
     */
    private let system_battery_timer_interval : TimeInterval = 1.0
    
    /**
     * Subscription to system event from the phone
     */
    private var system_event_subscriptions = Set<AnyCancellable>()

    
    // MARK: - Private interface
    
    
    /**
     * Check if this is the first time this version of the application
     * is running.
     */
    public func is_first_time_running() -> Bool
    {
                
        let application_version = get_application_version()
        let installed_version   = settings.application_version
        
        let result = application_version.compare(
                installed_version, options: .numeric
            )

        return (result == .orderedDescending) ? true : false
        
    }
    
    
    /**
     * Copy the default values
     * for all the keys found in the Root.plist in the main Settings bundle
     * to the application UserDefaults
     */
    private func copy_configuration_from_settings_bundle()
    {
        
        // Get the main default values from the Root.plist
        
        guard let settings_bundle = Bundle.main.url(
                    forResource: "Settings", withExtension: "bundle"
                )
            else
            {
                fatalError("Could not find Settings.bundle")
            }
        
        guard let root_settings = NSDictionary(
                contentsOf: settings_bundle.appendingPathComponent("Root.plist")
                )
            else
            {
                fatalError("Couldn't find Root.plist in settings bundle")
            }
        
        guard let preferences = root_settings.object(
                    forKey: "PreferenceSpecifiers"
                ) as? [[String: AnyObject]]
            else
            {
                fatalError("Root.plist has an invalid format")
            }
        
        // Copy the default values if they are not already set
        
        for p in preferences
        {
            if let key = p["Key"] as? String,
               let default_value = p["DefaultValue"]
            {
                if UserDefaults.standard.object(forKey: key) == nil
                {
                    UserDefaults.standard.set(default_value, forKey: key)
                }
            }
        }
        
    }
    
    
    /**
     * Save the current application version to the UserDefaults
     */
    private func save_application_version()
    {
        
        //let new_settings = Recording_settings()
        settings.application_version = get_application_version()
        
    }
    
    
    /**
     * For convinience, save the ID of the the current participant to the
     * UserDefaults data store
     */
    private func save_last_particpant_id()
    {
        
        UserDefaults.standard.set(participant_id, forKey: participant_id_key)
        
    }
    
    
    /**
     * Get the applicaiton version from the main bundle dictionary
     *
     * @returns  the version and build number such as 0.1.3
     */
    private func get_application_version() -> String
    {
        
        guard let dictionary = Bundle.main.infoDictionary ,
              let version    = dictionary["CFBundleShortVersionString"] as? String ,
              let build      = dictionary["CFBundleVersion"] as? String
        else
        {
            fatalError("Cannot read the application version and build")
        }
        
        return "\(version).\(build)"
        
    }
    
    
    private func is_temperature_state_high() -> Bool
    {
        
        var is_high = false
        
        for temperature in all_temperature_states
        {
            if temperature.value > settings.maximum_thermal_state
            {
                is_high = true
                break
            }
        }
        
        return is_high
        
    }
    
    
    private func is_battery_level_low() -> Bool
    {
        
        var is_low = false
        
        for device_battery in all_battery_percentages
        {
            if device_battery.value < settings.minimum_battery_percentage
            {
                is_low = true
                break
            }
        }
        
        return is_low
        
    }
    
    
    /**
     * Check the user entered all the required information
     */
    private func is_participant_id_empty() -> Bool
    {
        
        format_participant_id()
        return participant_id.isEmpty
        
    }
    
    
    // MARK: - Utility methods for the system state changes
    
    
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
                
                self?.update_system_battery_state() //new_battery_state(notification)
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
                
                self?.update_system_temperature_state() //new_thermal_state(notification)
            }
            .store(in: &system_event_subscriptions)
        
    }
    
    
    private func update_system_battery_percentage()
    {
        
        let percentage = Int(UIDevice.current.batteryLevel * 100)

        if let index = all_battery_percentages.firstIndex(
                where: {$0.device_id == system_identifier}
               )
        {
            all_battery_percentages[index].value = percentage
        }
        else
        {
            all_battery_percentages.append( .init(
                    device_id : system_identifier,
                    value     : percentage
                ))
        }
        
    }
    
    
    @objc private func update_system_battery_state()
    {

        let state = UIDevice.current.batteryState
        
        if let index = all_battery_states.firstIndex(
                where: {$0.id == system_identifier}
           )
        {
            all_battery_states[index].value = state
        }
        else
        {
            all_battery_states.append(.init(
                    device_id : system_identifier,
                    value     : state
                ))
        }
        
    }
    
    
    @objc private func update_system_temperature_state()
    {
        
        let temperature = ProcessInfo.processInfo.thermalState
        
        if let index = all_temperature_states.firstIndex(
                where: { $0.id == system_identifier }
            )
        {
            all_temperature_states[index].value = temperature
        }
        else
        {
            all_temperature_states.append(.init(
                    device_id : system_identifier,
                    value     : temperature
                ))
        }
        
    }
    
}
