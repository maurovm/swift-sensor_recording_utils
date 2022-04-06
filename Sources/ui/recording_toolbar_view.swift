/**
 * \file    recording_toolbar_view.swift
 * \author  Mauricio Villarroel
 * \date    Created: Apr 5, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


struct Recording_toolbar_view : View
{
    
    @ObservedObject var model: Recording_session_model
    
    var close_window_action : () -> Void
    
    
    var body: some View
    {
        ZStack(alignment: .top)
        {
            Background_panel()
            
            HStack(alignment: .center)
            {
                
                Recording_timer_view
                    .frame(width: 70)
                
                
                Temperature_state_view(
                        device_id     : model.system_temperature_state.id,
                        thermal_state : model.system_temperature_state.value,
                        view_style    : .icon_style
                    )
                    .frame(width: 35)
                
                
                Battery_percentage_view(
                        device_id      : "Phone",
                        percentage     : model.system_battery_percentage.value,
                        show_device_id : false,
                        is_vertical    : false,
                        view_style     : .icon_style,
                        battery_state  : model.system_battery_state.value
                    )
                    .frame(width: 55)
                
                Spacer()
                
                Divider()
                
                Preview_scale_button
                
                Quit_recording_button
                
                Start_stop_recording_button
                    .frame(width: 90)
                
            }
        }
        
    }
    
    
    // MARK: - Body Views
    
    
    /**
     * Contents for the timer counter, shown as text with rounded borders
     */
    private var Recording_timer_view: some View
    {
        
        Bordered_text(
            model.recording_elapsed_time.to_formatted_hours_string(true),
            font             : .system(.body),
            font_color       : .white,
            background_color : Color.black,
            border_color     : .white,
            border_width     : 2.0,
            radius           : 10
        )
        
    }
    
    
    /**
     * Switch between scale to fit/fill for the live video preview
     */
    private var Preview_scale_button: some View
    {
        
        Button()
        {
            model.toggle_device_preview()
        }
        label:
        {
            let image_name = (model.preview_mode == .scale_to_fill)
                ? "minus.magnifyingglass"
                : "plus.magnifyingglass"
            
            Image(systemName: image_name)
                .font(.system(.headline))
        }
        .tint(.teal)
        .buttonStyle(.borderedProminent)
        
    }
    
    
    /**
     * Start the recording session
     */
    private var Quit_recording_button: some View
    {
        
        Button("Quit", action: close_window_action)
        .buttonStyle(.bordered)
        .disabled( model.is_recording || model.is_session_in_progress )
        
    }
    
    
    private var Start_stop_recording_button: some View
    {
        
        Button()
        {
            model.toggle_recording_process()
        }
        label:
        {
            if model.is_session_in_progress
            {
                HStack(spacing: 0)
                {
                    ProgressView().tint(.yellow).padding(.leading, -7)
                    Text( model.is_recording ? "Stopping" : "Cancel")
                        .font(.caption)
                        //.fontWeight(.bold)
                        .frame(maxWidth : .infinity)
                }
            }
            else
            {
                HStack
                {
                    Image(systemName: "play.fill")
                    Text( model.is_recording ? "Stop" : "Start")
                        .font(.body)
                        .frame(maxWidth : .infinity)
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .tint( start_button_color )
        .controlSize(.regular)
        
    }
    
    
    // MARK: - Private state
    
    
    private var start_button_color : Color
    {
        let color : Color
        
        if model.is_session_in_progress
        {
            color = model.is_recording ? dark_red : dark_green
        }
        else
        {
            color = model.is_recording ? .red : .green
        }
        
        return color
    }
    
    
    private var dark_red : Color
    {
        Color(red: 0.6, green: 0.3, blue: 0.3)
    }
    
    
    private var dark_green : Color
    {
        Color(red: 0.3, green: 0.6, blue: 0.3)
    }
    
}




struct Recording_toolbar_view_Previews: PreviewProvider
{
    
    static var previews: some View
    {
        Group
        {
            
            Recording_toolbar_view(
                model: Recording_session_model(
                        participant_id        : "PT_01",
                        is_recording          : false,
                        is_session_in_progress: false
                    ),
                close_window_action: {}
                )
            
            
            Recording_toolbar_view(
                model: Recording_session_model(
                        participant_id        : "PT_01",
                        is_recording          : false,
                        is_session_in_progress: true
                    ),
                close_window_action: {}
                )
            
            
            Recording_toolbar_view(
                model: Recording_session_model(
                        participant_id        : "PT_01",
                        is_recording          : true,
                        is_session_in_progress: false
                    ),
                close_window_action: {}
                )
            
            
            Recording_toolbar_view(
                model: Recording_session_model(
                        participant_id        : "PT_01",
                        is_recording          : true,
                        is_session_in_progress: true
                    ),
                close_window_action: {}
                )
            
        }
        .previewInterfaceOrientation(.landscapeRight)
        .previewLayout(.fixed(width: 450, height: 40))
        
    }
    
}
