/**
 * \file    recording_settings.swift
 * \author  Mauricio Villarroel
 * \date    Created: Apr 2, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


/**
 * Main configuration for the recording process.
 *
 * In the future, this class should be presented as the main App settings,
 * with a customised UI so the user can configure the APP
 */
open class Recording_settings
{
    
    /**
     * The key-value data store where all the settings are kept
     */
    final public var store = UserDefaults.standard
    
    
    // MARK: - Global settings
    
    
    /**
     * The unique ID for configured BLE peripheral
     */
    final public var application_version : String
    {
        get
        {
            return store.string(forKey: app_version_key) ?? "0.0.0"
        }
        
        set(new_value)
        {
            store.set(new_value, forKey: app_version_key)
        }
    }
    
    
    /**
     * The maximum time (in seconds) to wait to connect to a device
     */
    final public var connection_timeout : Int
    {
        get
        {
            return store.integer(forKey: timeout_key)
        }
        
        set(new_value)
        {
            store.set(new_value, forKey: timeout_key)
        }
    }
    

    /**
     * The maximum temperature profile the phone needs to be in, before
     * launching the application
     */
    final public var maximum_thermal_state : ProcessInfo.ThermalState
    {
        get
        {
            if let key_value = store.string(forKey: maximum_thermal_state_key) ,
               let state  = ProcessInfo.ThermalState.from_name(key_value)
            {
                return state
            }
            else
            {
                return .fair
            }
        }
        
        set(new_value)
        {
            store.set(new_value.name, forKey: maximum_thermal_state_key)
        }
    }
    
    
    /**
     * The mimimum battery level percentage the phone needs to be in, before
     * launching the application
     */
    final public var minimum_battery_percentage : Int
    {
        get
        {
            return store.integer(forKey: minimum_battery_percentage_key)
        }
        
        set(new_value)
        {
            store.set(new_value, forKey: minimum_battery_percentage_key)
        }
    }
    
    
    // MARK: - Public interface
    
    
    /**
     * Type innitialiser
     */
    public init()
    {
        
        let key_prefix = "app_"
        
        app_version_key                = key_prefix + "version"
        timeout_key                    = key_prefix + "connection_timeout"
        maximum_thermal_state_key      = key_prefix + "maximum_thermal_state"
        minimum_battery_percentage_key = key_prefix + "minimum_battery_percentage"
        
    }
    
    
    // MARK: - Private state
    
    
    private let app_version_key                 : String
    private let timeout_key                     : String
    private let maximum_thermal_state_key       : String
    private let minimum_battery_percentage_key  : String
    
}
