/**
 * \file    background_panel.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 17, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


/**
 * Generic panel used as a base component for main UI elements, such as
 * the toolbar or list of sensors
 */
public struct Background_panel: View
{
    
    public var body: some View
    {
        panel_colour
            .cornerRadius(panel_radius)
            .shadow(
                color:  shadow_color,
                radius: panel_radius,
                x:      shadow_offset,
                y:      shadow_offset
            )
            .opacity(panel_opacity)
    }
    
    public init()
    {
    }
    
    
    // MARK: - Private state
    
    
    private let panel_colour  : Color = .cyan
    private let panel_radius  : CGFloat = 10.0
    private let panel_opacity : CGFloat = 0.4
    
    private let shadow_offset : CGFloat = 10.0
    private let shadow_color  : Color   = .gray
    
    
}


struct Background_panel_Previews: PreviewProvider
{
    static var previews: some View
    {
        Background_panel()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
