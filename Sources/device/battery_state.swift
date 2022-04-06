/**
 * \file    battery_state.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 22, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation
import UIKit


public struct Battery_state : Identifiable, Equatable
{
    
    public let device_id  : Device.ID_type
    public var value      : UIDevice.BatteryState
    
    public var id : Device.ID_type
    {
        device_id
    }
    
    public static func == (
            lhs : Battery_state,
            rhs : Battery_state
        ) -> Bool
    {
        return lhs.id == rhs.id
    }
    
    
    public init(
            device_id : Device.ID_type,
            value     : UIDevice.BatteryState
        )
    {
        self.device_id = device_id
        self.value     = value
    }
    
}
