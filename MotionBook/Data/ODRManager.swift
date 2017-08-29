//
//  ODRManager.swift
//  MotionBook
//
//  Created by Seungyoun Yi on 2017. 8. 24..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation

class ODRManager {
    
    // MARK: - Properties
    static let shared = ODRManager()
    var currentRequest: NSBundleResourceRequest?
    
    // MARK: - Methods
    func requestDataWith(tag: String,
                          onSuccess: @escaping () -> Void,
                          onFailure: @escaping (NSError) -> Void) {
        
        currentRequest = NSBundleResourceRequest(tags: [tag])
        
        guard let request = currentRequest else { return }
        
        request.endAccessingResources()
        
        request.loadingPriority =
        NSBundleResourceRequestLoadingPriorityUrgent
        
        request.beginAccessingResources { (error: Error?) in
            if let error = error {
                onFailure(error as NSError)
                return
            }
            
            onSuccess()
        }
    }
}
