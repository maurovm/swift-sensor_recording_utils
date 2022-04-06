/**
 * \file    rounded_corner.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 11, 2022
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
 * Create a rounded border shape
 */
public struct Rounded_corner: Shape
{

    var radius:  CGFloat      = .infinity
    var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path
    {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
    
}
