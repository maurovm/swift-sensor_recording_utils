/**
 * \file    disconnect_error.swift
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
     * If there was any error when disconnecting from a device
     */
    enum Disconnect_error : Error, Equatable
    {
        
        case failed_to_disconnect(
                device_id   : String,
                description : String
            )
        
        case device_disconnected(
                device_id   : String,
                description : String
            )
        
        case failure(
                device_id   : String,
                description : String
            )
        
    }

}
