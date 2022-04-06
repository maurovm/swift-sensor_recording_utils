/**
 * \file    sensor_label_view.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 7, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


public struct Sensor_label_view: View
{
    
    public let label       : String
    public let is_vertical : Bool
    
    public var body: some View
    {
        GeometryReader
        {
            geo in
            
            ZStack
            {
                
                let corners : UIRectCorner = is_vertical ? [.topLeft, .topRight] : [.topLeft, .bottomLeft]
                let angle : Double = is_vertical ? 0 : -90
                
                Color.white
                    .corner_radius(
                            radius: 10,
                            corners:corners
                        )
                
                Text(label)
                    .font(.custom("Helvetica", size: 10))
                    .italic()
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: angle))
                    .fixedSize()
                    .frame(width: geo.size.width)
            }
            
        }
    }
    
    
    public init(
            label       : String,
            is_vertical : Bool
        )
    {
        self.label       = label
        self.is_vertical = is_vertical
    }
    
}



struct Sensor_label_view_Previews: PreviewProvider
{
    static var previews: some View
    {
        Group
        {
            
        ZStack
        {
            Color.blue
            
            Sensor_label_view(
                    label       : "Nonin",
                    is_vertical : false
                )
                .frame(width: 25, height: 40)
            
        }
        .background(.blue)
        .previewLayout( .fixed(width: 50, height: 60) )
        
        ZStack
        {
            Color.blue
            
            Sensor_label_view(
                    label       : "FLIR",
                    is_vertical : true
                )
                .frame(width: 40, height: 25)
            
        }
        .background(.blue)
        .previewLayout( .fixed(width: 50, height: 60) )
        
        }
    }
    
}
