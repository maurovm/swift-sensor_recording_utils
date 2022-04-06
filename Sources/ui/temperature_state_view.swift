/**
 * \file    temperature_state_view.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 16, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


public struct Temperature_state_view: View
{
    
    public enum Display_style
    {
        case icon_style
        
        case normal_style
        
    }
    
    
    public var thermal_state : ProcessInfo.ThermalState
    
    
    public var body: some View
    {
        
        GeometryReader
        {
            geo in
            
            VStack(spacing: 0)
            {
                
                let title_size_factor = (view_style == .normal_style) ?  0.4 : 0
                
                if view_style == .normal_style
                {
                    Text(device_id).font(.body)
                        .frame(maxWidth: .infinity)
                        .frame(
                            height   : geo.size.height * title_size_factor,
                            alignment: .center
                        )
                }
                
                
                let image_panel_height = geo.size.height * ( 1 - title_size_factor)

                ZStack
                {
                    thermal_state.color.cornerRadius(5)
                    
                    HStack(spacing: image_spacing)
                    {
                        Image(systemName: "thermometer")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .white)
                            .font(.title2)
                        
                        Text(message)
                            .font(.body)
                            .foregroundColor(.white)
                            .fontWeight(font_weight)
                    }
                    
                }
                .frame(height: image_panel_height, alignment: .center)
                
            }
            
        }
        
    }
    
    
    public init(
            device_id     : Device.ID_type,
            thermal_state : ProcessInfo.ThermalState,
            view_style    : Temperature_state_view.Display_style
        )
    {
        
        self.device_id     = device_id
        self.thermal_state = thermal_state
        self.view_style    = view_style
        
    }
    
    
    // MARK: - Private state
    
    
    private let device_id   : Device.ID_type
    private let view_style  : Temperature_state_view.Display_style
    
    
    
    private var message : String
    {
        switch view_style
        {
            case .icon_style:
                return thermal_state.flag
            case .normal_style:
                return thermal_state.name
        }
    }
    
    
    private var font_weight : Font.Weight
    {
        switch thermal_state
        {
            case .nominal:
                return .regular
                
            case .fair:
                return .regular
                
            case .serious:
                return .bold
                
            case .critical:
                return .heavy
                
            @unknown default:
                return .regular
        }
    }
    
    
    private var image_spacing : CGFloat
    {
        switch view_style
        {
            case .icon_style:
                return 1
            case .normal_style:
                return 10
        }
    }
    
}




struct Thermal_state_view_Previews: PreviewProvider
{
    
    static let view_width_icon    : CGFloat = 35
    static let view_height_icon   : CGFloat = 35
    
    static let view_width_normal  : CGFloat = 120
    static let view_height_normal : CGFloat = 80
    
    static var previews: some View
    {
        
        Temperature_state_view(
                device_id    : "Phone",
                thermal_state: .nominal,
                view_style   : .icon_style
            )
            .previewLayout(.fixed(
                    width: view_width_icon, height: view_height_icon
                ))
        
        Temperature_state_view(
                device_id    : "Phone",
                thermal_state: .nominal,
                view_style   : .normal_style
            )
            .previewLayout(.fixed(
                    width: view_width_normal, height: view_height_normal
                ))
        
        
        
        Temperature_state_view(
                device_id    : "Phone",
                thermal_state: .fair,
                view_style   : .icon_style
            )
            .previewLayout(.fixed(
                    width: view_width_icon, height: view_height_icon
                ))
        
        Temperature_state_view(
                device_id    : "Phone",
                thermal_state: .fair,
                view_style   : .normal_style
            )
            .previewLayout(.fixed(
                    width: view_width_normal, height: view_height_normal
                ))
        
        
        
        Temperature_state_view(
                device_id    : "Phone",
                thermal_state: .serious,
                view_style   : .icon_style
            )
            .previewLayout(.fixed(
                    width: view_width_icon, height: view_height_icon
                ))
        
        Temperature_state_view(
                device_id    : "Phone",
                thermal_state: .serious,
                view_style   : .normal_style
            )
            .previewLayout(.fixed(
                    width: view_width_normal, height: view_height_normal
                ))

        
        
        Temperature_state_view(
                device_id    : "Phone",
                thermal_state: .critical,
                view_style   : .icon_style
            )
            .previewLayout(.fixed(
                    width: view_width_icon, height: view_height_icon
                ))
        
        Temperature_state_view(
                device_id    : "Phone",
                thermal_state: .critical,
                view_style   : .normal_style
            )
            .previewLayout(.fixed(
                    width: view_width_normal, height: view_height_normal
                ))

    }
    
}
