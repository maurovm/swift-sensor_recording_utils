/**
 * \file    content_mode.swift
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


public extension Device
{

    /**
     * How the live data preview of a given device should be displayed in tis
     * enclosing View, either fit or fill its area.
     *
     * For example, for an image from the video camera, should the image
     * should be zoomed out (to show entire image data) or zoomed in (to
     * cover all its View's area) ?
     */
    enum Content_mode
    {
        /**
         * The entire data should be shown in the View.
         *
         * For example, a video image will be zoomed out and possible extra dark
         * space would be added to the top and bottom regions to preseve
         * aspect ratio
         */
        case scale_to_fit
        
        /**
         * Part of the data will be shown in the View, so the entire View area
         * is coevered with the device data.
         *
         * For example, a video image will be zoomed in to cover all the
         * space of its enclosing View. This will probably mean that part of
         * the image won't be displayed on screen
         * aspect ratio
         */
        case scale_to_fill
        
        /**
         * Toggle the value
         */
        public func toggle() -> Content_mode
        {
            return (self == .scale_to_fill) ? .scale_to_fit : .scale_to_fill
        }
    }
    
}
