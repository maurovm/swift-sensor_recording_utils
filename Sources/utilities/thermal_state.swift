/**
 * \file    thermal_state.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 18, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


public extension ProcessInfo.ThermalState
{
    
    var flag : String
    {
        switch self
        {
            case .nominal:
                return "N"
                
            case .fair:
                return "F"
                
            case .serious:
                return "S"
                
            case .critical:
                return "C"
                
            @unknown default:
                return "U"
        }
    }
    
    
    var name : String
    {
        switch self
        {
            case .nominal:
                return "Nominal"
                
            case .fair:
                return "Fair"
                
            case .serious:
                return "Serious"
                
            case .critical:
                return "Critical"
                
            @unknown default:
                return "Unknown"
        }
    }
    
    
    var color : Color
    {
        switch self
        {
            case .nominal:
                return .green
                
            case .fair:
                return .yellow
                
            case .serious:
                return .orange
                
            case .critical:
                return .red
                
            @unknown default:
                return .gray
        }
    }
    
    
    static func from_name( _ name: String) -> ProcessInfo.ThermalState?
    {
        let state :  ProcessInfo.ThermalState?
        
        switch name
        {
            case "Nominal":
                state = .nominal
                
            case "Fair":
                state = .fair
                
            case "Serious":
                state = .serious
                
            case "Critical":
                state = .critical
                
            default:
                state = nil
        }
        
        return state
        
    }
    
}


public extension ProcessInfo.ThermalState //: RawRepresentable
{
    
    // MARK: - Comparison operators
    
    
    static func < (
            lhs : ProcessInfo.ThermalState,
            rhs : ProcessInfo.ThermalState
        ) -> Bool
    {
        return lhs.rawValue  <  rhs.rawValue
    }
    
    
    static func <=  (
            lhs : ProcessInfo.ThermalState,
            rhs : ProcessInfo.ThermalState
        ) -> Bool
    {
        return lhs.rawValue  <=  rhs.rawValue
    }
    
    
    static func >  (
            lhs : ProcessInfo.ThermalState,
            rhs : ProcessInfo.ThermalState
        ) -> Bool
    {
        return lhs.rawValue  >  rhs.rawValue
    }
    
    
    static func >=  (
            lhs : ProcessInfo.ThermalState,
            rhs : ProcessInfo.ThermalState
        ) -> Bool
    {
        return lhs.rawValue  >=  rhs.rawValue
    }
    
}
