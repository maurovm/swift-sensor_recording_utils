/**
 * \file    custom_logger.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 26, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation
import os.log


/**
 * A wrapper for Swift's Logger. It has a single global static property
 * that allows to enable the logger for development, and disables it for
 * production releases
 */
public final class Custom_logger
{   

    
    /**
     * Default class initialiser
     */
    public init()
    {
        logger = Logger(subsystem: "", category: "")
    }
    
    
    /**
     * Creates a custom logger for logging to a specific subsystem and
     * category.
     */
    public init(sub_system: String, category: String = "")
    {
        if SensorRecordingUtils.LOGGING_ENABLED
        {
            logger = Logger(subsystem: sub_system, category : category)
        }
        else
        {
            logger = nil
        }
    }
    
    
    // MARK: - Public interface
    
    
    public func is_enabled() -> Bool
    {
        return (logger == nil) ? false : true
    }
    
    /**
     * Writes an informative message to the log.
     */
    public func info(_ message: String)
    {
        logger?.info("\(message)")
    }
    
    /**
     * Writes information about a warning to the log.
     */
    public func warning(_ message: String)
    {
        logger?.warning("\(message)")
    }
    
    /**
     * Writes information about an error to the log.
     */
    public func error(_ message: String)
    {
        logger?.error("\(message)")
    }
    
    
    // MARK: - Private state
    
    
    private let logger: Logger?
    
}
