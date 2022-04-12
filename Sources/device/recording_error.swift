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
     * If there was any error during the recording life of a device
     */
    enum Recording_error : Error, Equatable
    {
        
        case device_disconnected(
                device_id   : String,
                description : String
            )
        
        case connection_timeout(
                device_id   : String,
                description : String
            )
        
        case start_timeout(
                device_id   : Device.ID_type,
                description : String
            )
        
        case fatal_error_while_recording(
                device_id   : Device.ID_type,
                description : String
            )
        
    }

}
