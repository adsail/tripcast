//
//  GCD+Convenience.swift
//
//  Credit to Professor Hannan:
//  Created by John Hannan on 11/16/15.
//  Copyright © 2015 John Hannan. All rights reserved.
//

import Foundation

struct GCD {
    static var MainQueue : dispatch_queue_t = {
        return dispatch_get_main_queue()
    }()
    
    static func performOnMainQueue(f: () -> ()) {
        dispatch_async(MainQueue) { f() }
    }
    
    static var UserInteractiveQueue: dispatch_queue_t  = {
        return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
    }()
    
    static var UserInitiatedQueue: dispatch_queue_t  = {
        return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
    }()

    static var UtilityQueue: dispatch_queue_t  = {
        return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
    }()
    
    static var BackgroundQueue: dispatch_queue_t = {
        return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    }()

}

func performOnMainQueue(f: () -> ()) {
    dispatch_async(GCD.MainQueue) { f() }
}

func performOnUserInitiatedQueue(f: () -> ()) {
    dispatch_async(GCD.UserInitiatedQueue) { f() }
}


func delay(delay: Double, f: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(),
        f
    )
}