/**
 * \file    view_on_interface_rotation.swift
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
import UIKit


/**
 * A helper function to track interface rotation changes
 */
public extension View
{
    
    func on_interface_rotation(
            perform action: @escaping (UIDeviceOrientation) -> Void
        ) -> some View
    {
        self.modifier(Device_rotation_view_modifier(action: action))
    }
    
}


/**
 * Custom view modifier to track interface rotation and call an
 * predefined "action"
 */
fileprivate struct Device_rotation_view_modifier: ViewModifier
{
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View
    {
        content
            //.onAppear()
            .onReceive(
                NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                )
            {
                _ in
                action(UIDevice.current.orientation)
            }
    }
}

