/**
 * \file    task-sleep.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 8, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


/**
 * Utility addition to Task to be able to sleep for a number of seconds,
 * insetead of nanoseconds. Code extracted from:
 *
 * https://www.hackingwithswift.com/quick-start/concurrency\
 * /how-to-make-a-task-sleep
 *
 */
extension Task where Success == Never, Failure == Never
{

    public static func sleep(seconds: Double) async throws
    {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }

}
