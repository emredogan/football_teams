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

class NetworkClient {
    static var teams = [Team]()
    private var requestURL = "https://api-football-v1.p.rapidapi.com/v3/standings?season=2020&league=39"
    
    var keys: NSDictionary?
    
    
    func makeDataRequest(serviceName: RequestService, completion: @escaping () -> ()) {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
                let host = dict["X-RapidAPI-Host"] as! String
                let key = dict["X-RapidAPI-Key"] as! String
            
            let headers = [
                "X-RapidAPI-Host": host,
                "X-RapidAPI-Key": key
            ]
            
            switch serviceName {
            case .AF:
                makeAFDataRequest(headers: headers.toHeader()) {
                    completion()
                }
                
            case .native:
                makeNativeDataRequest(headers: headers.toHeader()) {
                    completion()
                }
            }
            }
        
        
        
    }
    
    func makeAFDataRequest(headers: HTTPHeaders, completion: @escaping () -> ()) {
        AF.request(requestURL, method: .get, headers: headers).validate().responseDecodable(of: Result.self) { (response) in
            guard let result: Result = response.value else {
                print(response.debugDescription)
                return
            }
            self.processResult(result: result)
            completion()
        }
    }
    
    func makeNativeDataRequest(headers: HTTPHeaders, completion: @escaping () -> ()) {
        var request = URLRequest(url: URL(string: requestURL)!)
        request.headers = headers
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "Error while fetching data")
            } else {
                do {
                    let result = try JSONDecoder().decode(Result.self, from: data!)
                    self.processResult(result: result)
                    completion()
                } catch {
                    print(error)
                }
            }
        })
        dataTask.resume()
    }
    
    func processResult(result: Result) {
        
        let response = result.response
        let league = response[0].league
        let standings = league.standings
        let standing = standings[0]
        
        for teamInfo in standing {
            let teamName = teamInfo.team.name
            let teamLogoURL = teamInfo.team.logo
            let team = Team(name: teamName, logo: teamLogoURL)
            NetworkClient.teams.append(team)
        }
    }
}
