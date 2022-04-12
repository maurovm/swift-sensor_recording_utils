/**
 * \file    recording_session_view.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 4, 2021
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


public struct Recording_session_view<Video_content, Sensor_content>: View
    where Video_content : View, Sensor_content : View
{
    
    public var body: some View
    {
        GeometryReader
        {
            geo in
            
            ZStack(alignment: .center)
            {
                
                if has_video
                {
                    self.video_content
                        .frame(
                            width     : geo.size.width,
                            height    : geo.size.height,
                            alignment : .center
                        )
                }
                
                
                if has_sensors
                {
                    Sensor_list_view
                        .frame(
                            width: geo.size.width * (is_landscape ?  0.5 : 0.9)
                        )
                }
                
                
                Toolbar_controls_view
                    .frame(
                        width: geo.size.width * (is_landscape ?  0.7 : 0.98)
                    )
                
            }
            .frame( width: geo.size.width, height: geo.size.height )
            .onAppear
            {
                model.register_for_system_events()
            }
            .onDisappear()
            {
                model.cancel_system_event_subscriptions()
            }
            .on_interface_rotation
            {
                orientation in
                
                if orientation != .unknown
                {
                    model.change_interface_orientation(orientation)
                }
            }
            
        }
        .hide_navigation_interface()
        .ignoresSafeArea()
        
    }
    
    
    public init(
            model : Recording_session_model,
            @ViewBuilder sensor_content : @escaping () -> Sensor_content,
            @ViewBuilder video_content  : @escaping () -> Video_content
        )
    {

        self._model  = ObservedObject<Recording_session_model>(wrappedValue: model)
        self.sensor_content = sensor_content()
        self.video_content  = video_content()
        
        has_sensors = true
        has_video   = true
        
    }
    
    
    
    // MARK: - Body views
    
    
    private var Sensor_list_view: some View
    {
        
        VStack
        {
            
            Spacer()
                        
            ZStack
            {
                Background_panel()
            
                VStack(alignment:.center)
                {
                    self.sensor_content
                }
            }
            .frame(height: 65)
            .padding(.bottom, 10)
            
        }
        
    }
    
    
    private var Toolbar_controls_view: some View
    {
        
        VStack(alignment:.center)
        {

            Recording_toolbar_view(model: model)
                .frame(height: 40)
                .padding(.top, is_landscape ?  2 : 40)
            
            Spacer()
            
        }
        
    }
    
    // MARK: - Private state
    
    
    @ObservedObject private var model : Recording_session_model
    
    private var sensor_content : Sensor_content
    
    private var video_content  : Video_content
    
    private let has_sensors : Bool
    
    private let has_video   : Bool
    
    @Environment(\.horizontalSizeClass) private var horizontal_size
    
    
    private var is_landscape : Bool
    {
        horizontal_size == .regular
    }
    
}



extension Recording_session_view
    where Video_content == EmptyView , Sensor_content == EmptyView
{
    
    public init( model: Recording_session_model )
    {

        self._model  = ObservedObject<Recording_session_model>(wrappedValue: model)
        
        self.sensor_content = EmptyView()
        self.video_content  = EmptyView()
        
        has_sensors = false
        has_video   = false
        
    }
    
}


extension Recording_session_view  where  Video_content == EmptyView
{
    
    public init(
            model : Recording_session_model,
            @ViewBuilder sensor_content : @escaping () -> Sensor_content
        )
    {

        self._model  = ObservedObject<Recording_session_model>(wrappedValue: model)
        self.sensor_content = sensor_content()
        self.video_content  = EmptyView()
        
        has_sensors = true
        has_video   = false
        
    }
    
}


extension Recording_session_view  where Sensor_content == EmptyView
{
    
    public init(
            model : Recording_session_model,
            @ViewBuilder video_content : @escaping () -> Video_content
        )
    {

        self._model  = ObservedObject<Recording_session_model>(wrappedValue: model)
        
        self.sensor_content = EmptyView()
        self.video_content  = video_content()
        
        has_sensors = false
        has_video   = true
        
    }
    
}





struct Recording_session_view_Previews: PreviewProvider
{
    
    static var previews: some View
    {
        
        NavigationView
        {
            Recording_session_view(
                model: Recording_session_model(participant_id: "PT-01")
                )
        }
        .previewInterfaceOrientation(.portrait)
        
        
        NavigationView
        {
            Recording_session_view(
                model: Recording_session_model(participant_id: "PT-01")
                )
        }
        .navigationViewStyle(.stack)
        .previewInterfaceOrientation(.landscapeRight)
        
        
        NavigationView
        {
            Recording_session_view(
                model: Recording_session_model(participant_id: "PT-01")
                )
        }
        .navigationViewStyle(.stack)
        .previewInterfaceOrientation(.landscapeLeft)
        
    }
    
}
