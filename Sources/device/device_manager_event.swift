/**
 * \file    device_manager_event.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 8, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


/**
 * Events triggered by a device manager that have no associated action
 * requests. For example, when a device is abruptly disconnected by the
 * user without the software requesting to disconnect. Subscribers to these
 * published events will take the appropriate action when they are notified
 * of the unusual activity
 */
public enum Device_manager_event
{
    
    case recording_state_update(
                device_id : Device.ID_type,
                state     : Device.Recording_state
            )
    
    case device_disconnected(
                device_id   : Device.ID_type,
                description : String?
            )
    
    case device_connect_timeout(
                _  device_id : Device.ID_type
            )
    
    case device_start_timeout(
                _  device_id : Device.ID_type
            )
    
    case fatal_error(
                device_id   : Device.ID_type,
                description : String
            )
    
    
    
    
    
}
