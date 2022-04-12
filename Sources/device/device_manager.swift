/**
 * \file    device_manager.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 16, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation
import UIKit


/**
 * The main class type in charge of managing the recording process
 * for a given device.
 *
 * Other sensors (such as the cmaera or Pulse oximeters) subclass this
 * class
 */
@MainActor
open class Device_manager: ObservableObject, Identifiable, Equatable
{
    
    /**
     * Unique identifier for the device.  We support only "one" instance per
     * device type
     *
     * This identifier is also used to create the unique folder to record
     * data from this device
     */
    public let identifier : Device.ID_type
    
    nonisolated public var id: Device.ID_type
    {
        return identifier
    }
    
    
    nonisolated public static func == (
            lhs : Device_manager,
            rhs : Device_manager
        ) -> Bool
    {
        return lhs.identifier == rhs.identifier
    }
    
    
    public let sensor_type : Sensor_type
    
    
    @Published public var manager_event : Device_manager_event
    
    /**
     * Handle changes to the interface orientatio
     */
    @Published public var interface_orientation : UIDeviceOrientation
    
    /**
     * Handle changes to the scale to preview content
     */
    @Published public var preview_mode: Device.Content_mode
    
    /**
     * Device life cycle properties
     */
    @Published open private(set) var device_state : Device.Recording_state
    
    
    /**
     * Initialise class
     *
     * - Parameter  device_identifier : The unique identifier for this device
     */
    public init(
            identifier   : Device.ID_type,
            sensor_type  : Sensor_type,
            settings     : Device_settings,
            orientation  : UIDeviceOrientation,
            preview_mode : Device.Content_mode,
            device_state : Device.Recording_state,
            connection_timeout : Double
        )
    {
        
        // Make the identifier does not contain any spaces
        
        var device_id = identifier.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        
        device_id = device_id.replacingOccurrences(of: " ", with: "_")
        
        self.identifier            = device_id
        self.sensor_type           = sensor_type
        self.device_settings       = settings
        self.interface_orientation = orientation
        self.preview_mode          = preview_mode
        self.device_state          = device_state
        self.connection_timeout    = connection_timeout
        
        manager_event = .not_set
        
    }
    
    
    deinit
    {
        
        connection_timeout_task?.cancel()
        connection_timeout_task = nil
        
        start_timeout_task?.cancel()
        start_timeout_task = nil
        
    }
    
    
    // MARK: - Public interface to Start/Stop recording from this device
    
    
    /**
     * Connect and configure the device
     *
     * If the device is alreay streaming, we skip.
     * We start by verfying if the App can access the device, then we
     * configure itce. Fnally, we add the device to the recording
     * session
     *
     * - Parameter  session_id : The unique identifier for the recording
     *               session. Typically, it consists on:
     *
     *            PATICIPANT_ID + TIME_STAMP
     */
    public final func connect(session_id : String) async throws -> Bool
    {
        
        if is_device_connected || is_device_recording
        {
            return true
        }
    
        try await check_for_authorisation()
    
        
        device_state = .connecting
        
        
        // start the connection timeout
        
        
        connection_timeout_task = Task
        {
            [weak self] in
            
            await self?.throw_if_not_connected()
        }
        
        
        // Create the data directory for this device and this session
        
        
        /**
         * The base folder where to store data for the current
         * recording session
         */
        let recording_folder = get_recording_path(for: session_id)
        
        if device_settings.recording_enabled
        {
            do
            {
                try create_output_data_folder(recording_folder)
            }
            catch
            {
                connection_timeout_task?.cancel()
                connection_timeout_task = nil
                
                throw error
            }
        }
        
        
        // Connect to the underlying device
                
        do
        {
            
            try await device_connect(recording_path: recording_folder)
            set_device_connected()
            
        }
        catch let error as Device.Connect_error
        {
            connection_timeout_task?.cancel()
            connection_timeout_task = nil
            
            throw error
        }
        catch
        {
            connection_timeout_task?.cancel()
            connection_timeout_task = nil
            
            throw Device.Connect_error.failure(
                    device_id    : identifier,
                    description  : error.localizedDescription
                )
        }
        
        return is_device_connected
        
    }
    
    
    /**
     * Mark this device as connected
     */
    public final func set_device_connected()
    {
        is_device_connected = true
    }
    
    
    /**
     * Start recording process
     */
    public final func start_recording() async throws -> Bool
    {
        
        // Check preconditions
        
        if  is_device_connected == false
        {
            throw Device.Start_recording_error.not_connected(
                    device_id : identifier
                )
        }
        
        if is_device_recording
        {
            return true
        }
        
        device_state = .streaming
        
        
        // start the timeout task

        
        start_timeout_task = Task
        {
            [weak self] in
            await self?.throw_if_not_started()
        }
        
        
        // Start recording
        
        do
        {
            
            try await device_start_recording()
            is_device_recording = true
            
        }
        catch let error as Device.Start_recording_error
        {
            start_timeout_task?.cancel()
            start_timeout_task = nil
            
            throw error
        }
        catch
        {
            start_timeout_task?.cancel()
            start_timeout_task = nil
            
            throw Device.Start_recording_error.failed_to_start(
                    device_id    : identifier,
                    description  : error.localizedDescription
                )
        }
        
        return is_device_recording
        
    }
    
    
    /**
     * Stop recording process
     */
    public final func stop_recording() async throws
    {
        
        device_state = .stopping
        
        start_timeout_task?.cancel()
        start_timeout_task = nil
        
        do
        {
            
            try await device_stop_recording()
            is_device_recording = false
            
        }
        catch let error as Device.Stop_recording_error
        {
            throw error
        }
        catch
        {
            throw Device.Stop_recording_error.failed_to_stop(
                    device_id    : identifier,
                    description  : error.localizedDescription
                )
        }

    }
    
    
    public final func discconnect() async throws
    {
        
        device_state = .disconnecting
        
        connection_timeout_task?.cancel()
        connection_timeout_task = nil
        
        do
        {
            
            try await device_disconnect()
            is_device_connected = false
            device_state = .disconnected
            
        }
        catch let error as Device.Disconnect_error
        {
            throw error
        }
        catch
        {
            throw Device.Disconnect_error.failure(
                    device_id    : identifier,
                    description  : error.localizedDescription
                )
        }
        
    }
    
    
    // MARK: - Methods subclasses MUST override to handle the device life cycle
    
    
    /**
     * Check if the app has access to the input device
     *
     * TODO: restrict access to only subclasses
     */
    open func device_check_access() async throws
    {
        preconditionFailure("This method must be overridden")
    }
    
    /**
     * Configure the input device
     *
     * TODO: Can we re-throw an error in Swift?
     */
    open func device_connect(recording_path: URL) async throws
    {
        preconditionFailure("This method must be overridden")
    }
    
    /**
     * Call the specific implementation of the device to trigger the start
     * of the recording process
     */
    open func device_start_recording() async throws
    {
        preconditionFailure("This method must be overridden")
    }
    
    /**
     * Call the specific implementation of the device to stop
     * recording
     */
    open func device_stop_recording() async throws
    {
        preconditionFailure("This method must be overridden")
    }
    
    /**
     * Call the specific implementation of the device to release
     * resources and disconnect form the device
     */
    open func device_disconnect() async throws
    {
        preconditionFailure("This method must be overridden")
    }
    
    
    // MARK: - Private state
    
    
    private let device_settings : Device_settings
    
    private var is_device_connected : Bool = false
    
    private var is_device_recording : Bool = false
    
    
    /**
     * The amount of seconds to wait for connecting or starting a device
     */
    private var connection_timeout : Double
    
    private var connection_timeout_task : Task<Void, Never>?
    
    private var start_timeout_task : Task<Void, Never>?
    
    
    // MARK: - Private interface
    
    
    /**
     * Verify if we have access to the device
     */
    private func check_for_authorisation() async throws
    {
        
        do
        {
            try await device_check_access()
        }
        catch let auth_error as Device.Connect_error
        {
            throw auth_error
        }
        catch
        {
            throw Device.Connect_error.authorisation_failure(
                    device_id   : identifier,
                    description : error.localizedDescription
                )
        }
        
    }
    
    /**
     * Return the path to the App's Documents folder
     */
    private func get_documents_folder() -> URL
    {
        let all_folders = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            )
        return all_folders[0]
    }
    
    
    /**
     * Return the unique path for the current recording session. It is
     * based on the user ID, and the current time stamp
     */
    private func get_recording_path(
            for  session_id : String
        ) -> URL
    {
        
        /**
         * The name of the folder, within the app's Document's folder,
         * where we store all the data
         */
        let data_folder_name = "data"
        
        let path = get_documents_folder()
            .appendingPathComponent(data_folder_name)
            .appendingPathComponent(session_id)
            .appendingPathComponent(identifier)
        
        return path
        
    }
    
    
    /**
     * Create the folder to save data from this device for the current
     * recording session
     */
    private func create_output_data_folder(_ output_folder: URL) throws
    {
        
        do
        {
            try FileManager.default.createDirectory(
                    at: output_folder,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
        }
        catch CocoaError.fileWriteFileExists
        {
            throw Device.Connect_error.create_output_folder(
                    device_id    : identifier,
                    path         : output_folder.path,
                    description  : "Folder already exists"
                )
        }
        catch
        {
            throw Device.Connect_error.create_output_folder(
                    device_id    : identifier,
                    path         : output_folder.path,
                    description  : error.localizedDescription
                )
        }
        
    }
    
    
    
    private func throw_if_not_connected() async
    {
        
        do
        {
            try await Task.sleep(seconds: connection_timeout)
        }
        catch
        {
            return
        }
        
        if (Task.isCancelled == false) && (is_device_connected == false)
        {
            manager_event = .device_connect_timeout(identifier)
        }
        
    }
    
    
    private func throw_if_not_started() async
    {
        
        do
        {
            try await Task.sleep(seconds: connection_timeout)
        }
        catch
        {
            return
        }
        
        
        if (Task.isCancelled == false) && (is_device_recording == false)
        {
            manager_event = .device_start_timeout(identifier)
        }
        
    }
    
}
