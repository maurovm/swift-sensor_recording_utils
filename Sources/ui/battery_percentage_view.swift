/**
 * \file    battery_percentage_view.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 10, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


public struct Battery_percentage_view: View
{
    
    public enum Display_style
    {
        case icon_style
        
        case normal_style
        
    }
    
    
    public var percentage    : Int
    public var battery_state : UIDevice.BatteryState
    
    
    public var body: some View
    {
        
        GeometryReader
        {
            geo in
                
            ZStack(alignment: .center)
            {
                Color.white.cornerRadius(5)
                
                if is_vertical
                {
                    VStack(spacing: 0)
                    {
                        Battery_view(
                                width  : geo.size.width,
                                height : geo.size.height
                            )
                    }
                }
                else
                {
                    HStack(spacing: 0)
                    {
                        Battery_view(
                                width : geo.size.width,
                                height: geo.size.height
                            )
                    }
                }
            }
                    
        }
        
    }
    
    
    public init(
            device_id      : Device.ID_type,
            percentage     : Int   = 0,
            show_device_id : Bool  = false,
            is_vertical    : Bool  = false,
            view_style     : Battery_percentage_view.Display_style = .icon_style,
            battery_state  : UIDevice.BatteryState = .unknown
        )
    {
        
        self.device_id      = device_id
        self.percentage     = percentage
        self.show_device_id = show_device_id
        self.is_vertical    = is_vertical
        self.view_style     = view_style
        self.battery_state  = battery_state
        
    }
    
    
    // MARK: - Body Views
    
    
    @ViewBuilder
    private func Battery_view(
            width  : CGFloat,
            height : CGFloat
        ) -> some View
    {
        
        let id_size_factor = show_device_id ?  0.3 : 0
        
        if show_device_id
        {
            let id_width  = is_vertical ? width : width * id_size_factor
            let id_height = is_vertical ? height * id_size_factor : height
            
            Text( "\(device_id)" )
                .font(id_font)
                .rotationEffect(.init(degrees: angle))
                .frame(width: id_width, height: id_height, alignment: .center)
        }
        
        
        let icon_size_factor = show_device_id ?  0.3 : 0.4
        let icon_width  = is_vertical ? width : width * icon_size_factor
        let icon_height = is_vertical ? height * icon_size_factor : height
            
        if is_vertical
        {
        
            Image(systemName: battery_image_name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.green, .black, .white)
                .rotationEffect(.init(degrees: angle))
                .frame(width: icon_width, height: icon_height, alignment: .center)
                .padding(.top, 3)
        }
        else
        {
            
            Image(systemName: battery_image_name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.green, .black, .white)
                .rotationEffect(.init(degrees: angle))
                .frame(width: icon_width, height: icon_height, alignment: .center)
        }
        
        let value_size_factor = 1 - icon_size_factor - id_size_factor
        let value_width  = is_vertical ? width : width * value_size_factor
        let value_height = is_vertical ? height * value_size_factor : height
        
        Text("\(percentage)%")
            .font(value_font)
            .frame(width: value_width, height: value_height, alignment: .center)
        
    }
    
    
    // MARK: - Private state
    
    
    private let device_id      : Device.ID_type
    private let show_device_id : Bool
    private let is_vertical    : Bool
    private let view_style     : Battery_percentage_view.Display_style
    
    
    
    private var battery_image_name : String
    {
        if battery_state == .charging  || battery_state == .full
        {
            return "battery.100.bolt"
        }
        
        if percentage >= 95
        {
            return "battery.100"
        }
        else if percentage >= 75
        {
            return "battery.75"
        }
        else if percentage >= 50
        {
            return "battery.50"
        }
        else if percentage >= 25
        {
            return "battery.25"
        }
        else
        {
            return "battery.0"
        }
        
    }
    
    
    private var value_font : Font
    {
        switch view_style
        {
            case .icon_style:
                return .caption
                
            case .normal_style:
                return .title2
        }
    }
    
    private var id_font : Font
    {
        switch view_style
        {
            case .icon_style:
                return .caption
                
            case .normal_style:
                return .body
        }
    }
    
    
    private var angle : Double
    {
        is_vertical ? 0  : -90
    }
    
    
}


struct Battery_percentage_view_Previews: PreviewProvider
{
    
    static let view_width_icon  : CGFloat = 60
    static let view_height_icon : CGFloat = 35
    static let extra_icon       : CGFloat = 30
    
    static let view_width_normal  : CGFloat = 120
    static let view_height_normal : CGFloat = 50
    static let extra_normal       : CGFloat = 50
    
    static var previews: some View
    {
            
        Battery_percentage_view(
                device_id      : "Flir",
                percentage     : 100,
                show_device_id : false,
                is_vertical    : false,
                view_style     : .icon_style
            )
            .previewLayout(.fixed(
                    width: view_width_icon, height: view_height_icon
                ))
        
        Battery_percentage_view(
                device_id      : "Flir",
                percentage     : 70,
                show_device_id : false,
                is_vertical    : false,
                view_style     : .icon_style,
                battery_state  : .charging
            )
            .previewLayout(.fixed(
                    width: view_width_icon, height: view_height_icon
                ))

        Battery_percentage_view(
                device_id      : "Flir",
                percentage     : 50,
                show_device_id : false,
                is_vertical    : false,
                view_style     : .normal_style
            )
            .previewLayout(.fixed(
                    width: view_width_normal, height: view_height_normal
                ))


        
        Battery_percentage_view(
                device_id      : "Flir",
                percentage     : 70,
                show_device_id : true,
                is_vertical    : false,
                view_style     : .icon_style
            )
            .previewLayout(.fixed(
                    width: view_width_icon + extra_icon, height: view_height_icon
                ))

        Battery_percentage_view(
                device_id      : "Flir",
                percentage     : 5,
                show_device_id : true,
                is_vertical    : false,
                view_style     : .normal_style
            )
            .previewLayout(.fixed(
                    width: view_width_normal + extra_normal, height: view_height_normal
                ))



        Battery_percentage_view(
                device_id      : "Flir",
                percentage     : 74,
                show_device_id : true,
                is_vertical    : true,
                view_style     : .icon_style
            )
            .previewLayout(.fixed(
                    width: view_width_icon, height: view_height_icon + 30
                ))

        Battery_percentage_view(
                device_id      : "Flir",
                percentage     : 74,
                show_device_id : true,
                is_vertical    : true,
                view_style     : .normal_style
            )
            .previewLayout(.fixed(
                    width: view_width_normal, height: view_height_normal + 50
                ))

        
        
        Battery_percentage_view(
                device_id      : "Flir",
                percentage     : 27,
                show_device_id : false,
                is_vertical    : true,
                view_style     : .icon_style
            )
            .previewLayout(.fixed(
                    width: view_width_icon, height: view_height_icon
                ))

        Battery_percentage_view(
                device_id      : "Flir",
                percentage     : 27,
                show_device_id : false,
                is_vertical    : true,
                view_style     : .normal_style
            )
            .previewLayout(.fixed(
                    width: view_width_normal, height: view_height_normal
                ))
    }

}
