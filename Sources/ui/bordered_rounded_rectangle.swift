/**
 * \file    bordered_rounded_rectangle.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 8, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


/**
 * Similar to SwiftUI's RoundedRectangle, but with the option
 * to add a border and a fill
 */
public struct Bordered_rounded_rectangle: View
{
    
    public let cornerRadius : CGFloat
    public let style        : RoundedCornerStyle
    public let fill_color   : Color
    public let stroke_color : Color
    public let stroke_width : CGFloat
    
    public var body: some View
    {
        RoundedRectangle(cornerRadius: cornerRadius, style: style)
            .fill(fill_color)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: style)
                    .strokeBorder(stroke_color, lineWidth: stroke_width)
              )
    }
    
    
    public init(
            cornerRadius : CGFloat,
            style        : RoundedCornerStyle,
            fill_color   : Color,
            stroke_color : Color,
            stroke_width : CGFloat
        )
    {
        self.cornerRadius = cornerRadius
        self.style        = style
        self.fill_color   = fill_color
        self.stroke_color = stroke_color
        self.stroke_width = stroke_width
    }
    
}

struct Bordered_rounded_rectangle_Previews: PreviewProvider
{
    static var previews: some View
    {
        Bordered_rounded_rectangle(
            cornerRadius: 10,
            style:        .continuous,
            fill_color:   .yellow,
            stroke_color: .blue,
            stroke_width: 4.0
        )
    }
}
