//
//  NetworkClient.swift
//  Football_API
//
//  Created by Emre Dogan on 21/04/2022.
//

import Foundation
import Alamofire
import FirebaseFirestore

typealias CompletionHandlerTeams = (Result<[Team], Error>) -> Void

class APIService {
    // MARK: - VARIABLES
    private var requestURL = "https://api-football-v1.p.rapidapi.com/v3/standings?season=2020&league=39"
    
    // MARK: - DATA REQUESTS
    func makeDataRequest(serviceName: NetworkRequestService, completion: @escaping CompletionHandlerTeams) {
        let headers = grabKeyHeaders()
        
        switch serviceName {
        case .AF:
            makeAFDataRequest(headers: headers.toHeader()) {result in
                self.deliverResult(result: result, completion: completion)
            }
            
        case .native:
            makeNativeDataRequest(headers: headers.toHeader()) { result in
                self.deliverResult(result: result, completion: completion)
            }
        case .Firebase:
            getDataFromFirebase { result in
                self.deliverResult(result: result, completion: completion)
            }
        }
    }
    
    // MARK: - AF Request
    func makeAFDataRequest(headers: HTTPHeaders, completion: @escaping CompletionHandlerTeams) {
        AF.request(requestURL, method: .get, headers: headers).validate().responseDecodable(of: JsonResult.self) { (response) in
            guard let result: JsonResult = response.value else {
                completion(.failure(NetworkErrors.networkError(response.debugDescription)))
                return
            }
            let teams = self.processResult(result: result)
            completion(.success(teams))
        }
    }
    
    // MARK: - NATIVE Request
    func makeNativeDataRequest(headers: HTTPHeaders, completion: @escaping CompletionHandlerTeams) {
        var request = URLRequest(url: URL(string: requestURL)!)
        request.headers = headers
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(.failure(NetworkErrors.networkError(error!.localizedDescription)))
            } else {
                do {
                    let result = try JSONDecoder().decode(JsonResult.self, from: data!)
                    let teams = self.processResult(result: result)
                    completion(.success(teams))
                } catch {
                    completion(.failure(NetworkErrors.JsonDecodeError(error.localizedDescription)))
                }
            }
        })
        dataTask.resume()
    }
    
    // MARK: - Firebase Request
    func getDataFromFirebase(completion: @escaping CompletionHandlerTeams) {
        let dbCollectionName = "myTeams"
        
        let db = Firestore.firestore()
        var teams = [Team]()
        
        db.collection(dbCollectionName).addSnapshotListener { snapshot, error in
            print("Change in the firebase")
            db.collection(dbCollectionName)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        completion(.failure(NetworkErrors.FirebaseError(err.localizedDescription)))
                    } else {
                        teams.removeAll()
                        for document in querySnapshot!.documents {
                            let nameFromDocument = document.data()["name"] as! String
                            let logoFromDocument = document.data()["logo"] as! String
                            let team = Team(name: nameFromDocument, logo: logoFromDocument, isSubscribed: false)
                            teams.append(team)
                        }
                        completion(.success(teams))
                    }
                }
        }
        
        
    }
    
    
    
    func isDeveloperFromFirebase(completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("footballAPI").addSnapshotListener({ snapshot, error in
            db.collection("footballAPI").document("backupDB").getDocument(as: Dev.self) { (result) in
                print("Change in the firebase version 2")

                switch result {
                case .success(let dev):
                    completion(dev.isDeveloper ?? false)
                case .failure(let error):
                    // A `City` value could not be initialized from the DocumentSnapshot.
                    print("Error decoding city: \(error)")
                }
            }
        })
            
        
        
        
    }
    
    
    // MARK: - HANDLE RESULT
    func processResult(result: JsonResult) ->[Team]  {
        var teams = [Team]()
        let response = result.response
        let league = response[0].league
        let standings = league.standings
        let standing = standings[0]
        
        for teamInfo in standing {
            let teamName = teamInfo.team.name
            let teamLogoURL = teamInfo.team.logo
            let team = Team(name: teamName, logo: teamLogoURL, isSubscribed: false)
            teams.append(team)
        }
        return teams
    }
    
    func deliverResult(result:  Result<[Team], Error>, completion: CompletionHandlerTeams) {
        switch result {
        case .success(let teams):
            completion(.success(teams))
        case .failure(let error):
            completion(.failure(NetworkErrors.networkError(error.localizedDescription)))
        }
    }
    
    // MARK: - HELPER METHODS
    func grabKeyHeaders() -> [String : String] {
        var keys: NSDictionary?
        var headers = [String: String]()
        
        let rapidAPIHost = "X-RapidAPI-Host"
        let rapidAPIKey = "X-RapidAPI-Key"
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            let host = dict[rapidAPIHost] as! String
            let key = dict[rapidAPIKey] as! String
            
            let myHeaders = [
                rapidAPIHost: host,
                rapidAPIKey: key
            ]
            
            headers = myHeaders
        }
        return headers
    }
}
