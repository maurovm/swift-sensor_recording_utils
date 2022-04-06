/**
 * \file    device_settings.swift
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


/**
 * Typical settings for a generic input device
 */
open class Device_settings
{

    /**
     * The key-value data store where all the settings are kept
     */
    public final private(set) var store = UserDefaults.standard
    
    
    /**
     * Is recording from the device enabled?
     */
    public final var recording_enabled : Bool
    {
        get
        {
            return store.bool(forKey: recording_key)
        }
        
        set(new_value)
        {
            store.set(new_value, forKey: recording_key)
        }
    }
    
    
    /**
     * Type innitialiser
     */
    public init( key_prefix : String )
    {
        
        self.key_prefix = key_prefix
        
        recording_key = self.key_prefix + "recording_enabled"

    }
    
    
    // MARK: - Private state
    
    
    /**
     * The prefix of the name for all the keys for the device
     */
    private let key_prefix    : String
    private let recording_key : String
    
}
