/**
 * \file    temperature_state.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 31, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


public struct Temperature_state : Identifiable
{
    
    public let device_id : Device.ID_type
    public var value     : ProcessInfo.ThermalState
    
    public var id : Device.ID_type
    {
        device_id
    }
    
    
    public init(
            device_id  : Device.ID_type,
            value      : ProcessInfo.ThermalState
        )
    {
        self.device_id = device_id
        self.value     = value
    }
    
}
