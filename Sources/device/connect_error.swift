/**
 * \file    connect_error.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 13, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


public extension Device
{
    
    /**
     * If the device is properly configured or not
     */
    enum Connect_error : Error, Equatable
    {
        
        case no_devices_configured
        
        case failed_to_connect_to_all_devices
        
        case not_authorised(
                device_id   : String
            )
        
        case authorisation_failure(
                device_id   : String,
                description : String
            )
        
        case create_output_folder(
                device_id   : String,
                path        : String,
                description : String
            )
        
        case empty_configuration(
                device_id : String
            )
        
        case unsupported_configuration(
                device_id   : String,
                description : String
            )
        
        case recording_not_supported(
                device_id   : String,
                description : String
            )
        
        case failed_to_apply_configuration(
                device_id   : String,
                description : String
            )
        
        
        case timeout(
                device_id   : String,
                description : String
            )
        
        case connection_cancelled(
                device_id   : String,
                description : String
            )
        
        
        case input_device_unavailable(
                device_id   : String,
                description : String
            )
        
        case failed_to_connect_to_device(
                device_id   : String,
                description : String
            )
        
        case failed_to_add_output_device(
                device_id   : String,
                description : String
            )
        
        case output_file_exists(
                device_id   : String,
                path        : String,
                description : String
            )
        
        
        case failure(
                device_id   : String,
                description : String
            )
        
    }
    
}
