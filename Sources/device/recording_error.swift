/**
 * \file    recording_error.swift
 * \author  Mauricio Villarroel
 * \date    Created: Feb 21, 2022
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
     * If there was any error when starting to record from a device
     */
    enum Recording_error : Error, Equatable
    {
        
        case failed_to_start_from_all_devices
        
        case not_connected(
                device_id   : Device.ID_type
            )
        
        
        case start_timeout(
                device_id   : Device.ID_type,
                description : String
            )
        
        
        case failed_to_start(
                device_id   : Device.ID_type,
                description : String
            )
        
        case failed_to_stop(
                device_id   : Device.ID_type,
                description : String
            )
        
        case fatal_error_while_recording(
                device_id   : Device.ID_type,
                description : String
            )
        
    }

}
