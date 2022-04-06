/**
 * \file    view_corner_radius.swift
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
 * Clip the borders of a View with a round shape
 */
public extension View
{
    
    func corner_radius(radius: CGFloat, corners: UIRectCorner) -> some View
    {
        clipShape( Rounded_corner(radius: radius, corners: corners) )
    }
    
}


