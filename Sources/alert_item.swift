/**
 * \file    alert_item.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 12, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


/**
 * The data to be sent with alerts.
 */
public struct Alert_item : Identifiable
{
    
    public let id      : UUID    = UUID()
    public let title   : String
    public let message : String
    public var actions : [Action] = []
    
    
    /**
     * This is used to construct buttons for alerts
     */
    public struct Action : Identifiable
    {
        public let id     : UUID        = UUID()
        public let label  : String
        public let role   : ButtonRole?
        public let action : () -> Void
        
        public init(
                label  : String,
                action : @escaping () -> Void
            )
        {
            self.label  = label
            self.role   = nil
            self.action = action
        }
        
        public init(
                label  : String,
                role   : ButtonRole?,
                action : @escaping () -> Void
            )
        {
            self.label = label
            self.role  = role
            self.action = action
        }
    }
    
    
    public init (
            title   : String   = "Error",
            message : String   = "Unknown error",
            actions : [Action] = []
        )
    {
        self.title   = title
        self.message = message
        self.actions = actions
    }
    
}
