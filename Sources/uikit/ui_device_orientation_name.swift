/**
 * \file    ui_device_orientation_name.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 10, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation
import UIKit


public extension UIDeviceOrientation
{
    
    var name : String
    {
        switch self
        {
            case .unknown:
                return "unknown"
                
            case .portrait:
                return "portrait"
                
            case .portraitUpsideDown:
                return "portraitUpsideDown"
                
            case .landscapeLeft:
                return "landscapeLeft"
                
            case .landscapeRight:
                return "landscapeRight"
                
            case .faceUp:
                return "faceUp"
                
            case .faceDown:
                return "faceDown"
                
            @unknown default:
                return "unknown default"
        }
    }
    
}
