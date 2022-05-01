//
//  NetworkClient.swift
//  Football_API
//
//  Created by Emre Dogan on 21/04/2022.
//

import Foundation
import Alamofire

enum RequestService {
    case AF, native
}

class NetworkService {
    private var requestURL = "https://api-football-v1.p.rapidapi.com/v3/standings?season=2020&league=39"
    
    
    typealias CompletionHandlerTeams = (Result<[Team], Error>) -> Void // To make the code more readable we put an alias here.
    
    func makeDataRequest(serviceName: RequestService, completion: @escaping CompletionHandlerTeams) {
        let headers = grabKeyHeaders()
        
        switch serviceName {
        case .AF:
            makeAFDataRequest(headers: headers.toHeader()) {result in
                
                switch result {
                case .success(let teams):
                    completion(.success(teams))
                case .failure(let error):
                    print("ERROR - Getting data from the network client ", error)
                }
            }
            
        case .native:
            makeNativeDataRequest(headers: headers.toHeader()) { result in
                
                switch result {
                case .success(let teams):
                    completion(.success(teams))
                case .failure(let error):
                    print("ERROR - Getting data from the network client ", error)
                }
                
            }
        }
        
        
    }
    
    func makeAFDataRequest(headers: HTTPHeaders, completion: @escaping CompletionHandlerTeams) {
        AF.request(requestURL, method: .get, headers: headers).validate().responseDecodable(of: JsonResult.self) { (response) in
            guard let result: JsonResult = response.value else {
                print(response.debugDescription)
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
                print(error ?? "Error while fetching data")
            } else {
                do {
                    let result = try JSONDecoder().decode(JsonResult.self, from: data!)
                    let teams = self.processResult(result: result)
                    completion(.success(teams))
                } catch {
                    print(error)
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
    
    func grabKeyHeaders() -> [String : String] {
        var keys: NSDictionary?
        var headers = [String: String]()
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            let host = dict["X-RapidAPI-Host"] as! String
            let key = dict["X-RapidAPI-Key"] as! String
            
            let myHeaders = [
                "X-RapidAPI-Host": host,
                "X-RapidAPI-Key": key
            ]
            
            headers = myHeaders
        }
        return headers
    }
}
