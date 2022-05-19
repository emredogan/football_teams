//
//  FirebaseService.swift
//  Football_API
//
//  Created by Emre Dogan on 19/05/2022.
//

import Foundation
import FirebaseMessaging


class FirebaseService {
    private init() {}
    
    static func subscribe(_ team: Team, completionHandler:@escaping (Bool) -> ()) {
        let trimmedTeamName = team.name.filter {!$0.isWhitespace}
        Messaging.messaging().subscribe(toTopic: trimmedTeamName) { error in
            if error != nil {
                completionHandler(false)
                return
            }
            completionHandler(true)
        }
    }
    
    static func unsubscribe(_ team: Team, completionHandler:@escaping (Bool) -> ()) {
        let trimmedTeamName = team.name.filter {!$0.isWhitespace}
        Messaging.messaging().unsubscribe(fromTopic: trimmedTeamName) { error in
            if error != nil {
                completionHandler(false)
                return
            }
            completionHandler(true)
        }
    }
}
