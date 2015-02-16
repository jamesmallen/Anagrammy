//
//  NotificationManager.swift
//  Anagrammy
//
//  Created by James Allen on 2/16/15.
//  Copyright (c) 2015 James M Allen. All rights reserved.
//

import Foundation

// http://moreindirection.blogspot.com/2014/08/nsnotificationcenter-swift-and-blocks.html

class NotificationManager {
    private var observerTokens: [AnyObject] = []
    
    deinit {
        deregisterAll()
    }
    
    func deregisterAll() {
        for token in observerTokens {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
        
        observerTokens = []
    }
    
    func registerObserver(name: String!, block: (NSNotification! -> Void)) {
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: nil) {note in
            block(note)
        }
        
        observerTokens.append(newToken)
    }
    
    func registerObserver(name: String!, forObject object: AnyObject!, block: (NSNotification! -> Void)) {
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(name, object: object, queue: nil) {note in
            block(note)
        }
        
        observerTokens.append(newToken)
    }
}
