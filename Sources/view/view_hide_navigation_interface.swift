/**
 * \file    view_hide_navigation_interface.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 18, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import SwiftUI


/**
 * A helper function in View to hide the NavigationView interface
 */
public extension View
{
    
    func hide_navigation_interface() -> some View
    {
        self.modifier(Navidation_hidden_view_modifier() )
    }
    
}


/**
 * Custom view modifier to hide navigation interfaces
 */
fileprivate struct Navidation_hidden_view_modifier: ViewModifier
{

    func body(content: Content) -> some View
    {
        content
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}
