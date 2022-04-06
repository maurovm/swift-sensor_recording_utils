/**
 * \file    date-epoch_in_nanseconds.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 10, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


public typealias Epoch_timestamp = UInt64


public extension Epoch_timestamp
{
    var to_seconds : Double
    {
        Double(self) / 1_000_000_000.0
    }
    
}

public extension Date
{
    
    @inline(__always)
    func epoch() -> TimeInterval
    {
        return self.timeIntervalSince1970
    }
    
    
    @inline(__always)
    static func epoch_in_nanseconds() -> Epoch_timestamp
    {
        return epoch_in_nanseconds( from: Date() )
    }
    
    
    @inline(__always)
    static func epoch_in_nanseconds(from  date : Date) -> Epoch_timestamp
    {
        let epoch = date.timeIntervalSince1970
        return UInt64( epoch * 1_000_000_000 )
    }
    
}
