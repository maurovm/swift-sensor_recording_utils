/**
 * \file    recording_state.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 9, 2022
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
     * The list of steps/stages in the recording process life cycle for a
     * device
     */
    enum Recording_state : Equatable
    {
        case disconnected
        case connecting
        case streaming
        case stopping
        case disconnecting
        
        public var name : String
        {
            switch self
            {
                case .disconnected:
                    return "Disconnected"
                    
                case .connecting:
                    return "Connecting ..."
                    
                case .stopping:
                    return "Stopping ..."
                    
                case .disconnecting:
                    return "Disconnecting ..."
                    
                default:
                    return ""
            }
        }
        
    }
    
}
