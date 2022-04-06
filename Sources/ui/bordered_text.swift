/**
 * \file    bordered_text.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 11, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


/**
 * A fancy version of SwiftUI's Text View with rounded borders
 */
public struct Bordered_text: View
{
    public let label            : String
    public let font             : Font
    public let font_color       : Color
    public let background_color : Color
    public let border_color     : Color
    public let border_width     : CGFloat
    public let radius           : CGFloat
    
    
    public var body: some View
    {
        border_color
            .cornerRadius(radius)
            .overlay(
                background_color.cornerRadius(radius).padding(border_width)
            )
            .overlay(
                Text(String(label)).font(font).foregroundColor(font_color)
            )
            
    }
    

    public init(
            _   label            : String,
                font             : Font    = .system(.body),
                font_color       : Color   = .black,
                background_color : Color   = .white,
                border_color     : Color   = .black,
                border_width     : CGFloat = 2.0,
                radius           : CGFloat = 15.0
        )
    {
        self.label = label
        self.font  = font
        self.font_color       = font_color
        self.background_color = background_color
        self.border_color     = border_color
        self.border_width     = border_width
        self.radius           = radius
    }
    
}


struct Round_border_text_Previews: PreviewProvider
{
    static var previews: some View
    {
        Bordered_text("Hello World!")
            .previewInterfaceOrientation(.landscapeRight)
            .previewLayout(.fixed(width: 120, height: 50))
    }
}
