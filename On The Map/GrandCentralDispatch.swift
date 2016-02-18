//
//  GrandCentralDispatch.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(update: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
        update()
    }
}