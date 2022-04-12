/**
 * \file    stop_recording_error.swift
 * \author  Mauricio Villarroel
 * \date    Created: Apr 12, 2022
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
     * If there was any error when stopping to record from a device
     */
    enum Stop_recording_error : Error, Equatable
    {
        
        case stop_in_progress
        
        case failed_to_stop(
                device_id   : Device.ID_type,
                description : String
            )
    }
    
}
