/**
 * \file    setup_error.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 23, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


/**
 * The type of error during the initial stage of the application,
 * before start recording
 */
public enum Setup_error: Error, Equatable
{
    // Generic errors:
    
    case no_participant_id
    
    case no_sensors_configured
    
    
    // Camera errors
    
    case no_camera_access
    
    
    // System error
    
    case system_thermal_state(maximum: ProcessInfo.ThermalState)
    
    case system_battery_level(minimum: Int)
    
    
    // Thermal camera
    
    case no_thermal_camera_access
    
    
    // Bluetooth errors:
    
    case no_bluetooth_access
    
    case ble_empty_configuration
    
    case ble_services_not_supported(_ services : String)
    
    case ble_characteristics_not_supported(_ characteristics : String)
    
    case ble_no_characteristics_configured(_ services : String)
    
}
