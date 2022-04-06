/**
 * \file    participant_entry_view.swift
 * \author  Mauricio Villarroel
 * \date    Created: Apr 1, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


public struct Participant_entry_view<Label, Destination>: View where
    Label : View, Destination : View
{
    
    public var body: some View
    {
        
        VStack(alignment: .center)
        {
            
            Text( title ).font(.system(.title3)).fontWeight(.bold).padding()
            
            Divider()
            
            Spacer()
            
            Participant_info_view //.padding()
            
            Spacer()
            
            System_info_view
                .frame(height: system_info_height)
            
            Divider()
            
            Action_buttons_view
            
        }
        .onAppear
        {
            
            let orientation = UIDevice.current.orientation
            
            if orientation != .unknown
            {
                interface_orientation = orientation
            }
            
            model.register_for_system_events()
            
        }
        .onDisappear()
        {
            
            model.cancel_system_event_subscriptions()
            
        }
        .onChange(of: scene_phase)
        {
            
            phase in
            
            switch phase
            {
                case .active:
                    model.register_for_system_events()
                    
                case .inactive:
                    model.cancel_system_event_subscriptions()
                    
                default:
                    break
            }
            
        }
        .on_interface_rotation
        {
            orientation in
            
            if orientation != .unknown
            {
                interface_orientation = orientation
            }
        }
        .alert("Error",
            isPresented : $show_setup_alert,
            presenting  : model.setup_error)
            {
                error_type in

                switch error_type
                {
                    case .no_sensors_configured,
                         .no_camera_access,
                         .no_bluetooth_access,
                         .ble_empty_configuration,
                         .ble_services_not_supported(_),
                         .ble_characteristics_not_supported(_),
                         .ble_no_characteristics_configured(_):
                        
                        Button("Open settings", action: open_application_settings)
                        
                    default:
                        EmptyView()
                }

                Button("Dismiss",  action: {})
            }
            message:
            {
               Text( error_message(for: $0) )
            }
        
    }
    
    
    
    public init(
            title   : String = "Enter participant information",
            model   : Participant_entry_model,
            interface_orientation       : Binding<UIDeviceOrientation>,
            @ViewBuilder recording_view : @escaping () -> Destination,
            @ViewBuilder action_buttons : @escaping () -> Label
        )
    {

        self.title  = title
        self._model = ObservedObject<Participant_entry_model>(wrappedValue: model)
        
        self._interface_orientation = interface_orientation
        self.recording_view         = recording_view
        self.action_buttons         = action_buttons

    }
    
    
    // MARK: - Body Views
    
    
    private var Participant_info_view : some View
    {
        
        HStack
        {
            
            Text("Participant ID:")
            
            TextField("Enter unique ID", text: $model.participant_id)
                .frame(maxWidth: 250.0)
                .disableAutocorrection(true)
                .keyboardType(.alphabet)
                .lineLimit(1)
                .textInputAutocapitalization(.characters)
                .textContentType(.username)
                .textFieldStyle(.roundedBorder)
                .onSubmit
                {
                    model.format_participant_id()
                }
            
        }
        
    }
    
    
    private var System_info_view : some View
    {
        
        GeometryReader
        {
            geo in
            
            VStack
            {
                
                System_message_view
                    .frame(height: message_height)
                            
                Divider()
                
                let status_height = geo.size.height - message_height - 10
                
                HStack(alignment:.top)
                {
                    Temperature_state_info_view
                        .frame(height : status_height * 0.8)

                    Divider()
                    
                    Battery_state_info_view
                }
                //.frame(height: status_height)
                
            }
                
        }
        
    }
    
    
    private var System_message_view : some View
    {
        
        VStack
        {
            if let message = model.system_message
            {
                Divider()
                
                Text(message).font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        
    }
    
    
    private var Temperature_state_info_view : some View
    {
        
        HStack
        {
            ForEach(model.all_temperature_states)
            {
                Temperature_state_view(
                        device_id     : $0.device_id,
                        thermal_state : $0.value,
                        view_style    : .normal_style
                    )
                    .frame(width: 120)
            }
        }
        
    }
    
    
    private var Battery_state_info_view : some View
    {
        
        HStack
        {
            ForEach(model.all_battery_percentages)
            {
                percentage in
                
                let state = model.all_battery_states.first{ $0.id == percentage.id }
                let state_value = state?.value ?? .unknown
                                
                Battery_percentage_view(
                        device_id      : percentage.id,
                        percentage     : percentage.value,
                        show_device_id : true,
                        is_vertical    : true,
                        view_style     : .normal_style,
                        battery_state  : state_value
                    )
                    .frame(width: 120)
            }
        }
        
    }
    
    
    private var Action_buttons_view : some View
    {

        HStack
        {
            
            Button("Application settings", action: open_application_settings)
                .buttonStyle(.bordered)
                .buttonBorderShape(.automatic)
                .frame(maxWidth: .infinity)
            
            
            
            action_buttons()
            
            
            NavigationLink(
                    isActive   : $launch_recording_screen,
                    destination: recording_view
                )
                {
                    Button("Start recording", action: open_main_recordig_screen)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.automatic)
                        .frame(maxWidth: .infinity)

                }
                .isDetailLink(false)

        }
        
    }
    
    
    // MARK: - Private state
    
    
    private var title : String = "Enter participant information"
    
    @ObservedObject private var model : Participant_entry_model
    
    @Binding private var interface_orientation : UIDeviceOrientation
    
    @ViewBuilder private var recording_view : () -> Destination
    
    @ViewBuilder private var action_buttons : () -> Label
    
    
    @State private var launch_recording_screen : Bool = false
    
    @State private var show_setup_alert : Bool = false
        
    @Environment(\.scenePhase) private var scene_phase
    
    private var message_height     : CGFloat = 30
    private var system_info_height : CGFloat = 120
    
    
    // MARK: - Actions

    
    /**
     * Open iOS camera settings app
     */
    private func open_application_settings()
    {
        
        if let url = URL(string: UIApplication.openSettingsURLString)
        {
            model.cancel_system_event_subscriptions()
            UIApplication.shared.open(url)
        }
        
    }
    
    
    /**
     * Launch the main recording View
     */
    private func open_main_recordig_screen()
    {

        Task
        {
            if await model.is_configuration_valid()
            {
                model.cancel_system_event_subscriptions()
                launch_recording_screen = true
            }
            else
            {
                show_setup_alert = true
            }
        }
        
    }
    
    
    // MARK: - Private interface
    
    
    private func error_message( for error_type : Setup_error ) -> String
    {

        let message : String
    
        switch error_type
        {
                
            // Generic errors:
                
                
            case .no_participant_id:
                
                message = "Please enter the participant's unique ID"
                
            case .no_sensors_configured:
                
                message = "You MUST enable at least one sensor to " +
                          "collect data from"
                
            // System error
            
            case .system_thermal_state(let maximum):
                
                message = "Your phone is currently too warm, you need to " +
                          " wait until it reaches the state " +
                          "'\(maximum.name)' at minimum"
                
            case .system_battery_level(let minimum):
                
                message = "Your battery level is too low, wait until it " +
                          "has at least \(minimum)% of charge"
                
                
            // Camera errors
                
                
            case .no_camera_access:
                
                message = "The App requires access to the camera"
                
                
                
            // Thermal camera errors
                
                
            case .no_thermal_camera_access:
                
                message = "The thermal camera is enabled but could not be found. Please connect the video camera before recording"
                
                
            // Bluetooth errors:
                
                
            case .no_bluetooth_access:
                
                message = "The App requires access to Bluetooth devices"
                
            case .ble_empty_configuration:
                
                message = "Please select at least one Bluetooth " +
                          "characteristic to record from."
                
            case .ble_services_not_supported(let services):
                
                message = "Recording not supported from services: \(services)"
                
            case .ble_characteristics_not_supported(let characteristics):
                
                message = "Recording not supported from characteristics: " +
                          characteristics
                
            case .ble_no_characteristics_configured(let services):
                
                message = "No characteristics configured for services: " +
                          services
                
        }
        
        return message
        
    }
    
}



struct Participant_entry_view_Previews: PreviewProvider
{
    
    
    static var previews: some View
    {
        
        Group
        {
            NavigationView
            {
                Participant_entry_view(
                    model          : Participant_entry_model(
                                        battery_percentage: [ .init(
                                            device_id  : "Phone",
                                            value      : 75
                                            )],
                                        battery_state: [ .init(
                                            device_id  : "Phone",
                                            value      : .charging
                                            )]
                                        ),
                    interface_orientation : .constant(.unknown),
                    recording_view : {},
                    action_buttons : {}
                )
            }

            NavigationView
            {
                Participant_entry_view(
                    model          : Participant_entry_model(
                                        system_message : "Conneting to thermal camera ..."
                                        ),
                    interface_orientation : .constant(.unknown),
                    recording_view : {},
                    action_buttons : {}
                )
            }
        }
        .navigationViewStyle(.stack)
        .previewInterfaceOrientation(.landscapeRight)
        
        
        Group
        {
            NavigationView
            {
                Participant_entry_view(
                    model          : Participant_entry_model(),
                    interface_orientation : .constant(.unknown),
                    recording_view : {},
                    action_buttons : {}
                )
            }

            NavigationView
            {
                Participant_entry_view(
                    model          : Participant_entry_model(
                                        system_message : "Conneting to thermal camera ..."
                                        ),
                    interface_orientation : .constant(.unknown),
                    recording_view : {},
                    action_buttons : {}
                )
            }
        }
        .navigationViewStyle(.stack)
        .previewInterfaceOrientation(.portrait)

    }
    
}
