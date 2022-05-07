//
//  NetworkClient.swift
//  Football_API
//
//  Created by Emre Dogan on 21/04/2022.
//

import Foundation
import Alamofire
import FirebaseFirestore

// We have two possible ways to make network request
enum RequestService {
    case AF, native, Firebase
}

typealias CompletionHandlerTeams = (Result<[Team], Error>) -> Void // To make the code more readable we put an alias here.

class NetworkService {
    private var requestURL = "https://api-football-v1.p.rapidapi.com/v3/standings?season=2020&league=39"
    
    func makeDataRequest(serviceName: RequestService, completion: @escaping CompletionHandlerTeams) {
        print("Requesting network service by, ", serviceName)
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
    
    
    func makeAFDataRequest(headers: HTTPHeaders, completion: @escaping CompletionHandlerTeams) {
        AF.request(requestURL, method: .get, headers: headers).validate().responseDecodable(of: JsonResult.self) { (response) in
            guard let result: JsonResult = response.value else {
                completion(.failure(MyErrors.networkError(response.debugDescription)))
                return
            }
            let teams = self.processResult(result: result)
            completion(.success(teams))
        }
    }
    
    func makeNativeDataRequest(headers: HTTPHeaders, completion: @escaping CompletionHandlerTeams) {
        var request = URLRequest(url: URL(string: requestURL)!)
        request.headers = headers
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(.failure(MyErrors.networkError(error!.localizedDescription)))
            } else {
                do {
                    let result = try JSONDecoder().decode(JsonResult.self, from: data!)
                    let teams = self.processResult(result: result)
                    completion(.success(teams))
                } catch {
                    completion(.failure(MyErrors.JsonDecodeError(error.localizedDescription)))
                }
            }
        })
        dataTask.resume()
    }
    
    func processResult(result: JsonResult) ->[Team]  {
        
        var teams = [Team]()
        
        let response = result.response
        let league = response[0].league
        let standings = league.standings
        let standing = standings[0]
        
        for teamInfo in standing {
            let teamName = teamInfo.team.name
            let teamLogoURL = teamInfo.team.logo
            let team = Team(name: teamName, logo: teamLogoURL)
            teams.append(team)
        }
        return teams
    }
    
    func deliverResult(result:  Result<[Team], Error>, completion: CompletionHandlerTeams) {
        switch result {
        case .success(let teams):
            completion(.success(teams))
        case .failure(let error):
            completion(.failure(MyErrors.networkError(error.localizedDescription)))
        }
        
    }
    
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
    
    func getDataFromFirebase(completion: @escaping CompletionHandlerTeams) {
        print("Getting data from Firebase")
        let dbCollectionName = "myTeams"
        
        let db = Firestore.firestore()
        var teams = [Team]()
        
        db.collection(dbCollectionName)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    completion(.failure(MyErrors.FirebaseError(err.localizedDescription)))
                } else {
                    for document in querySnapshot!.documents {
                        let nameFromDocument = document.data()["name"] as! String
                        let logoFromDocument = document.data()["logo"] as! String
                        let team = Team(name: nameFromDocument, logo: logoFromDocument)
                        teams.append(team)
                        
                    }
                    
                    completion(.success(teams))
                    
                }
            }
    }
}
