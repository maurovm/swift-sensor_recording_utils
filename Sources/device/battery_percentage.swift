/**
 * \file    battery_percentage.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 12, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


public struct Battery_percentage : Identifiable, Equatable
{
    
    public let device_id : Device.ID_type
    public var value     : Int
    
    public var id : Device.ID_type
    {
        device_id
    }
    
    public static func == (
            lhs : Battery_percentage,
            rhs : Battery_percentage
        ) -> Bool
    {
        return lhs.id == rhs.id
    }
    
    
    public init(
            device_id : Device.ID_type,
            value     : Int
        )
    {
        self.device_id = device_id
        self.value     = value
    }
    
}
