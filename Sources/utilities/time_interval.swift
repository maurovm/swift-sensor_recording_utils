/**
 * \file    time_interval_utils.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 11, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


public extension TimeInterval
{
    
    // MARK: - Time constants
    
    static var seconds_per_day    : Double { return 24 * 60 * 60 }
    static var seconds_per_hour   : Double { return 60 * 60 }
    static var seconds_per_minute : Double { return 60 }

    
    // MARK: - Initialisers from day contants
    
    
    /**
     * Creates a TimeInterval from the time expressed in days
     */
    static func days(_ value: Double) -> TimeInterval
    {
        return value * seconds_per_day
    }

    /**
     * Creates a TimeInterval from the time expressed in hours
     */
    static func hours(_ value: Double) -> TimeInterval
    {
        return value * seconds_per_hour
    }

    /**
     * Creates a TimeInterval from the time expressed in minutes
     */
    static func minutes(_ value: Double) -> TimeInterval
    {
        return value * seconds_per_minute
    }

    /**
     * Creates a TimeInterval from the time expressed in seconds
     */
    static func seconds(_ value: Double) -> TimeInterval
    {
        return value
    }

    
    // MARK: - Methods to format time intervals
    
    
    /**
     * return the value of the TimeInterval as a formatted string, the
     * format is:
     *           hh:mm:ss
     */
    func to_formatted_hours_string(
            _ truncate_empty : Bool = false
        ) -> String
    {
        
        let hh = Int( floor( self / .seconds_per_hour) );
        
        let reminder = self.truncatingRemainder(dividingBy: .seconds_per_hour)
        
        let mm = Int( floor( reminder / .seconds_per_minute) );
        
        let ss = Int( reminder.truncatingRemainder(dividingBy: .seconds_per_minute) )
        
        var formatted_interval = String(format: "%02d:%02d", mm, ss)
        
        if hh > 0  || truncate_empty == false
        {
            let hh_str = String(format: "%02d", hh)
            formatted_interval = "\(hh_str):\(formatted_interval)"
        }
        
        return formatted_interval
        
    }
    
    
    /**
     * Convert a time interval from seconds to nanoseconds
     */
    func to_nanoseconds() -> UInt64
    {
        return UInt64( self * 1_000_000_000 )
    }
    
}
