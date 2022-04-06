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
                    video_content
                        .frame(
                            width     : geo.size.width,
                            height    : geo.size.height,
                            alignment : .center
                        )
                }
                
                
                if has_sensors
                {
                    Sensor_list_view(screen_width: geo.size.width)
                }
                
                
                Toolbar_controls_view(screen_width: geo.size.width)
                
            }
            .frame( width: geo.size.width, height: geo.size.height )
            .alert( alert_error_title ,
                isPresented : $model.show_alert_error,
                presenting  : model.alert_error,
                actions     :
                {
                    _ in

                    Button("End recording session",  action: close_window)
                },
                message :
                {
                    error_type in
                
                    if let error = error_type as? Device.Connect_error
                    {
                        show_connection_error_message(error)
                    }
                    else if let error = error_type as? Device.Recording_error
                    {
                        show_recording_error_message(error)
                    }
                    else if let error = error_type as? Device.Disconnect_error
                    {
                        show_disconnection_error_message(error)
                    }
                    else
                    {
                        Text(
                            "An unhandled error ocurred, please restart " +
                             "the recording process"
                            )
                    }
                
                }
            )
            .alert("Success",
                   isPresented : $model.recording_finished_successfully,
                   actions     :
                {
                    Button("End recording session",  action: close_window)
                },
                message :
                {
                    Text("Recording finished succesfully")
                }
            )
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
            model          : Recording_session_model,
            sensor_content : Sensor_content,
            video_content  : Video_content
        )
    {

        self._model  = ObservedObject<Recording_session_model>(wrappedValue: model)
        self.sensor_content = sensor_content
        self.video_content  = video_content
        
        has_sensors = true
        has_video   = true
        
    }
    
    
    
    // MARK: - Body views
    
    
    @ViewBuilder
    private func Sensor_list_view( screen_width : CGFloat ) -> some View
    {
        VStack
        {
            Spacer()
            
            let width_factor : CGFloat = is_landscape ?  0.5 : 0.9
            
            ZStack
            {
                Background_panel()
            
                VStack(alignment:.center)
                {
                    sensor_content
                }
            }
            .frame(width: screen_width * width_factor, height: 65)
            .padding(.bottom, 10)
        }
        
    }
    
    
    @ViewBuilder
    private func Toolbar_controls_view( screen_width : CGFloat ) -> some View
    {
        
        let top_padding   : CGFloat = is_landscape ?  2   : 40
        let width_factor  : CGFloat = is_landscape ?  0.7 : 0.98
        
        let toolbar_width  = screen_width * width_factor
        let toolbar_height : CGFloat = 40;
        
        
        VStack(alignment:.center)
        {
            
            Recording_toolbar_view(
                    model               : model,
                    close_window_action : close_window
                )
                .frame(
                    width : toolbar_width,
                    height: toolbar_height
                )
                .padding(.top, top_padding)
            
            Spacer()
            
        }
        
    }
    
    
    // MARK: - Actions
    
    
    
    private func close_window()
    {
        
        if model.is_recording == false  &&
           model.is_session_in_progress  == false
        {
            model.end_session()
            dismiss()
        }
        
    }
    
    
    // MARK: - Private state
    
    
    @ObservedObject private var model : Recording_session_model
    
    private var sensor_content : Sensor_content
    
    private var video_content  : Video_content
    
    private let has_sensors : Bool
    
    private let has_video : Bool
    
    @Environment(\.horizontalSizeClass) private var horizontal_size
    
    @Environment(\.dismiss) private var dismiss
    
    
    private var alert_error_title : String
    {
        if let _ = model.alert_error as? Device.Connect_error
        {
            return "Connection error"
        }
        else if let _ = model.alert_error as? Device.Recording_error
        {
            return "Recording error"
        }
        else if let _ = model.alert_error as? Device.Disconnect_error
        {
            return "Disconnection error"
        }
        else
        {
            return "Error"
        }
    }
    
    
    private var is_landscape : Bool
    {
        horizontal_size == .regular
    }
    
    
    // MARK: - Error messages for the Alerts
    
    
    @ViewBuilder
    private func show_connection_error_message(
            _  error  : Device.Connect_error
        ) -> some View
    {
        
        switch error
        {
                
            case .no_devices_configured:
                
                Text(
                    "No devices configured to connect, you need to enable " +
                    "at least one device"
                    )
                
            case .failed_to_connect_to_all_devices:
                    
                Text(
                    "Could not connect to all devices. Please restart the " +
                    "recording process"
                    )
            
                
            case .not_authorised(let device_id):

                Text("Device '\(device_id)' is not authorised")
                
            case .authorisation_failure(
                        let device_id,
                        let description
                    ):
                
                Text("Failed to access device '\(device_id)': \(description)")
                
            case .create_output_folder(
                        let device_id,
                        let path,
                        let description
                    ):
                
                Text(
                    "Failed to create output data folder " +
                     "'\(path)' for device '\(device_id)': \(description)"
                    )

            case .empty_configuration(let device_id):

                Text("Configuration is empty for device '\(device_id)'")

            case .unsupported_configuration(
                        let device_id,
                        let description
                    ):

                Text(
                    "Unsupported configuration for device " +
                     "'\(device_id)': \(description)"
                    )

            case .recording_not_supported(
                        let device_id,
                        let description
                    ):

                Text(
                    "Recording not supported for device " +
                     "'\(device_id)': \(description)"
                    )

            case .failed_to_apply_configuration(
                        let device_id,
                        let description
                    ):

                Text(
                    "Failed to apply_configuration for device " +
                     "'\(device_id)': \(description)"
                    )
                
                

            case .timeout(
                    let device_id,
                    let description
                ):

            Text(
                "Timeout while connecting to device " +
                 "'\(device_id)': \(description)"
                )

                
            case .connection_cancelled(
                    let device_id,
                    let description
                ):

            Text(
                "The connection to device '\(device_id)' has been cancelled : \(description)"
                )
                
                
            case .input_device_unavailable(
                        let device_id,
                        let description
                    ):

                Text(
                    "The device '\(device_id)' is unavailable: " + description
                    )
                
                
            case .failed_to_connect_to_device(
                        let device_id,
                        let description
                    ):

                Text(
                    "Failed to connect to device '\(device_id)' : " +
                    description
                    )

                
            case .failed_to_add_output_device(
                        let device_id,
                        let description
                    ):

                Text(
                    "Cannot configure data writer for device " +
                     "\(device_id)': \(description)"
                    )
                
            case .output_file_exists(
                        let device_id,
                        let path,
                        let description
                    ):
                
                Text(
                    "The output file '\(path)' already exists for device " +
                    "'\(device_id)': \(description)"
                    )
                

            case .failure(
                        let device_id,
                        let description
                    ):

                Text(
                    "Failure to connect to device " +
                     "\(device_id)': \(description)"
                    )
        }
    
    }
    
    
    @ViewBuilder
    private func show_recording_error_message(
            _  error  : Device.Recording_error
        ) -> some View
    {
        
        switch error
        {
                
            case .failed_to_start_from_all_devices:
                    
                Text(
                    "Could not start recording from all devices. " +
                    "Please restart the recording process"
                    )
                
            case .not_connected(let device_id):
                
                Text("Device '\(device_id)' is not connected")
                
                

            case .start_timeout(
                    let device_id,
                    let description
                ):

                Text(
                    "Timeout while start recording from device " +
                     "'\(device_id)': \(description)"
                    )
                
                
            case .failed_to_start(
                        let device_id,
                        let description
                    ):
                
                Text(
                    "Failed to start recording from device " +
                    "'\(device_id)': \(description)"
                    )
                
            case .failed_to_stop(
                        let device_id,
                        let description
                    ):
                
                Text(
                    "Failed to stop recording from device " +
                    "'\(device_id)': \(description)"
                    )
                
            case .fatal_error_while_recording(
                    let device_id,
                    let description
                ):

                Text(
                    "Fatal error wile recording from device " +
                     "'\(device_id)': \(description)"
                    )
        }
    
    }
    
    
    @ViewBuilder
    private func show_disconnection_error_message(
            _  error  : Device.Disconnect_error
        ) -> some View
    {
        
        switch error
        {
            case .failed_to_disconnect(
                        let device_id,
                        let description
                    ):
                Text(
                    "Failed to disconnect from device " +
                    "'\(device_id)': \(description)"
                    )
                
            case .device_disconnected(
                        let device_id,
                        let description
                    ):
                Text(
                    "Device \(device_id) was disconnected: " +
                    "\(description). Recording will be stopped"
                    )
                
            case .failure(
                        let device_id,
                        let description
                    ):
                Text(
                    "Failed to disconnect from device " +
                    "'\(device_id)': \(description)"
                    )
        }
    
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
            model          : Recording_session_model,
            sensor_content : Sensor_content
        )
    {

        self._model  = ObservedObject<Recording_session_model>(wrappedValue: model)
        self.sensor_content = sensor_content
        self.video_content  = EmptyView()
        
        has_sensors = true
        has_video   = false
        
    }
    
}


extension Recording_session_view  where Sensor_content == EmptyView
{
    
    public init(
            model         : Recording_session_model,
            video_content : Video_content
        )
    {

        self._model  = ObservedObject<Recording_session_model>(wrappedValue: model)
        
        self.sensor_content = EmptyView()
        self.video_content  = video_content
        
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
