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
        .alert( recording_error_title ,
            isPresented : $model.show_recording_alert,
            presenting  : model.recording_error,
            actions     :
            {
                error_type in
            
                if let _ = error_type as? Device.Connect_error
                {
                    Button("Close recording session",  action: close_window)
                }
                else if let _ = error_type as? Device.Start_recording_error
                {
                    Button("Close recording session",  action: close_window)
                }
                else if let _ = error_type as? Device.Recording_error
                {
                    Button("End recording session",  action: end_session)
                }
                else if let _ = error_type as? Device.Stop_recording_error
                {
                    Button("Close recording session",  action: close_window)
                }
                else if let _ = error_type as? Device.Disconnect_error
                {
                    Button("Close recording session",  action: close_window)
                }
                else
                {
                    Button("End recording session",  action: end_session)
                }
            },
            message :
            {
                error_type in
            
                let message = get_error_message(
                    error_type,
                    default_message: "An unhandled error ocurred, please " +
                                     "restart the recording process"
                    )

                Text(message)
            }
        )
        .alert( "Fatal error while recording data" ,
            isPresented : $model.show_device_manager_alert,
            presenting  : model.device_manager_error,
            actions     :
            {
                _ in

                Button("End recording session",  action: end_session)
            },
            message :
            {
                error_type in
            
                let message = get_error_message(
                    error_type,
                    default_message: "An unhandled error ocurred, please " +
                                     "restart the recording process"
                    )

                Text(message)
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
    
    
    private var Quit_recording_button: some View
    {
        
        Button("Quit", action: close_window)
        .buttonStyle(.bordered)
        .disabled( (model.recording_state == .disconnected) ? false : true )
        
    }
    
    
    private var Start_stop_recording_button: some View
    {
        
        Button(action: toggle_recording_process)
        {
            
            switch model.recording_state
            {
                case .disconnected:
                    
                        HStack
                        {
                            Image(systemName: "play.fill")
                            Text("Start")
                                .font(.body)
                                .frame(maxWidth : .infinity)
                        }
                    
                case .connecting:
                    
                    HStack(spacing: 0)
                    {
                        ProgressView().tint(.yellow).padding(.leading, -7)
                        Text("Cancel")
                            .font(.caption)
                            //.fontWeight(.bold)
                            .frame(maxWidth : .infinity)
                    }
                    
                case .streaming:
                    
                        HStack
                        {
                            Image(systemName: "play.fill")
                            Text("Stop")
                                .font(.body)
                                .frame(maxWidth : .infinity)
                        }
                    
                case .stopping , .disconnecting:
                    
                    HStack(spacing: 0)
                    {
                        ProgressView().tint(.yellow).padding(.leading, -7)
                        Text("Stopping")
                            .font(.caption)
                            //.fontWeight(.bold)
                            .frame(maxWidth : .infinity)
                    }
            }
            
        }
        .buttonStyle(.borderedProminent)
        .tint( start_button_color )
        .controlSize(.regular)
        
    }
    
    
    // MARK: - Actions
    
    
    private func toggle_recording_process()
    {
        
        Task
        {
            await model.toggle_recording_process()
        }
        
    }
    
    
    private func end_session()
    {
        
        Task
        {
            if await model.end_recording_session()
            {
                dismiss()
            }
        }
        
    }
    
    private func close_window()
    {
        
        dismiss()
        
    }
    
    
    // MARK: - Private state
    
    
    @Environment(\.dismiss) private var dismiss
    
    
    private var recording_error_title : String
    {
        if let _ = model.recording_error as? Device.Connect_error
        {
            return "Could not start recording"
        }
        else if let _ = model.recording_error as? Device.Start_recording_error
        {
            return "Could not start recording"
        }
        else if let _ = model.recording_error as? Device.Recording_error
        {
            return "Fatal error during recording"
        }
        else if let _ = model.recording_error as? Device.Stop_recording_error
        {
            return "Could not stop recording"
        }
        else if let _ = model.recording_error as? Device.Disconnect_error
        {
            return "Could not stop recording"
        }
        else
        {
            return "Error"
        }
    }
    
    
    private var start_button_color : Color
    {
        let color : Color
        
        switch model.recording_state
        {
            case .disconnected:
                color = .green
                
            case .connecting:
                color = dark_green
                
            case .streaming:
                color = .red
                
            case .stopping:
                color = dark_red
                
            case .disconnecting:
                color = dark_red
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
    
    
    // MARK: - Error messages for the Alerts
    
    
    private func get_error_message(
            _  error_type      : Error,
               default_message : String
        ) -> String
    {

        let message : String
        
        if let error = error_type as? Device.Connect_error
        {
            message = get_connection_error_message(error)
        }
        else if let error = error_type as? Device.Start_recording_error
        {
            message = get_start_recording_error_message(error)
        }
        else if let error = error_type as? Device.Recording_error
        {
            message = get_recording_error_message(error)
        }
        else if let error = error_type as? Device.Stop_recording_error
        {
            message = get_stop_recording_error_message(error)
        }
        else if let error = error_type as? Device.Disconnect_error
        {
            message = get_disconnection_error_message(error)
        }
        else
        {
            message = default_message
        }
        
        return message

    }
    
    
    private func get_connection_error_message(
            _  error  : Device.Connect_error
        ) -> String
    {
        
        let message : String
        
        switch error
        {
                
            case .no_devices_configured:
                
                message = "No devices configured to connect, you need to " +
                          "enable at least one device"
                
                
            case .task_cancelled:
                
                message = "The connection task has been cancelled"
                
                
            case .failed_to_connect_to_all_devices:
                    
                message = "Could not connect to all devices. Please restart " +
                          "the recording process"
            
                
            case .not_authorised(let device_id):

                message = "Device '\(device_id)' is not authorised"
                
                
            case .authorisation_failure(
                        let device_id,
                        let description
                    ):
                
                message = "Failed to access device '\(device_id)': \(description)"
                
                
            case .create_output_folder(
                        let device_id,
                        let path,
                        let description
                    ):
                
                message = "Failed to create output data folder '\(path)'" +
                          "for device '\(device_id)': \(description)"
                

            case .empty_configuration(let device_id):

                message = "Configuration is empty for device '\(device_id)'"
                

            case .unsupported_configuration(
                        let device_id,
                        let description
                    ):

                message = "Unsupported configuration for device " +
                          "'\(device_id)': \(description)"
                

            case .recording_not_supported(
                        let device_id,
                        let description
                    ):

                message = "Recording not supported for device " +
                          "'\(device_id)': \(description)"
                

            case .failed_to_apply_configuration(
                        let device_id,
                        let description
                    ):

                message = "Failed to apply_configuration for device " +
                          "'\(device_id)': \(description)"

                
            case .connection_cancelled(
                    let device_id,
                    let description
                ):

                message = "The connection to device '\(device_id)' has been " +
                          "cancelled : \(description)"
                
                
            case .input_device_unavailable(
                        let device_id,
                        let description
                    ):

                message = "The device '\(device_id)' is unavailable: " +
                          description
                
                
            case .failed_to_connect_to_device(
                        let device_id,
                        let description
                    ):

                message = "Failed to connect to device '\(device_id)' : " +
                          description

                
            case .failed_to_add_output_device(
                        let device_id,
                        let description
                    ):

                message = "Cannot configure data writer for device " +
                          "\(device_id)': \(description)"
                
                
            case .output_file_exists(
                        let device_id,
                        let path,
                        let description
                    ):
                
                message = "The output file '\(path)' already exists for " +
                          "device '\(device_id)': \(description)"
                

            case .failure(
                        let device_id,
                        let description
                    ):

                message = "Failure to connect to device " +
                          "\(device_id)': \(description)"
        }
        
        return message
    
    }
    
    
    private func get_start_recording_error_message(
            _  error  : Device.Start_recording_error
        ) -> String
    {
        
        let message : String
        
        switch error
        {
                
            case .failed_to_start_from_all_devices:
                    
                message = "Could not start recording from all devices. " +
                          "Please restart the recording process"
                
                
            case .not_connected(let device_id):
                
                message = "Device '\(device_id)' is not connected"
                
                
            case .failed_to_start(
                        let device_id,
                        let description
                    ):
                
                message = "Failed to start recording from device " +
                          "'\(device_id)': \(description)"
                
        }
        
        return message
    
    }
    
    
    private func get_recording_error_message(
            _  error  : Device.Recording_error
        ) -> String
    {
        
        let message : String
        
        switch error
        {
                
            case .device_disconnected(
                        let device_id,
                        let description
                    ):
                message = "Device \(device_id) was disconnected: " +
                          "\(description). Recording will be stopped"
                
                
            case .connection_timeout(
                    let device_id,
                    let description
                ):

                message = "Timeout while connecting to device " +
                          "'\(device_id)': \(description)"
                
                
            case .start_timeout(
                    let device_id,
                    let description
                ):

                message = "Timeout while start recording from device " +
                          "'\(device_id)': \(description)"
                
                
            case .fatal_error_while_recording(
                    let device_id,
                    let description
                ):

                message = "Fatal error wile recording from device " +
                          "'\(device_id)': \(description)"
                
        }
        
        return message
    
    }
    
    
    private func get_stop_recording_error_message(
            _  error  : Device.Stop_recording_error
        ) -> String
    {
        
        let message : String
        
        switch error
        {
                
            case .stop_in_progress:
                
                message = "A stop procedure is already in progress, please wait..."
                
                
            case .failed_to_stop(
                        let device_id,
                        let description
                    ):
                
                message = "Failed to stop recording from device " +
                          "'\(device_id)': \(description)"

        }
        
        return message
    
    }
    
    
    private func get_disconnection_error_message(
            _  error  : Device.Disconnect_error
        ) -> String
    {
        
        let message : String
        
        switch error
        {
                
            case .disconnect_in_progress:
                
                message = "A disconnection procedure is already in progress, please wait..."
                
                
            case .failed_to_disconnect(
                        let device_id,
                        let description
                    ):
                message = "Failed to disconnect from device " +
                          "'\(device_id)': \(description)"
                
                
//            case .device_disconnected(
//                        let device_id,
//                        let description
//                    ):
//                message = "Device \(device_id) was disconnected: " +
//                          "\(description). Recording will be stopped"
                
                
            case .failure(
                        let device_id,
                        let description
                    ):
                message = "Failed to disconnect from device " +
                          "'\(device_id)': \(description)"
                
        }
        
        return message
    
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
                        participant_id  : "PT_01",
                        recording_state : .disconnected
                    )
                )
            
            
            Recording_toolbar_view(
                model: Recording_session_model(
                        participant_id  : "PT_01",
                        recording_state : .connecting
                    )
                )
            
            
            Recording_toolbar_view(
                model: Recording_session_model(
                        participant_id  : "PT_01",
                        recording_state : .streaming
                    )
                )
            
            
            Recording_toolbar_view(
                model: Recording_session_model(
                        participant_id  : "PT_01",
                        recording_state : .stopping
                    )
                )
            
        }
        .previewInterfaceOrientation(.landscapeRight)
        .previewLayout(.fixed(width: 450, height: 40))
        
    }
    
}
