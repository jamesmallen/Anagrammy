//
//  Utils.swift
//  Anagrammy
//
//  Created by James Allen on 2/16/15.
//  Copyright (c) 2015 James M Allen. All rights reserved.
//

import Foundation


var globalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var globalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
}

var globalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)
}

var globalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
}

var globalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)
}
