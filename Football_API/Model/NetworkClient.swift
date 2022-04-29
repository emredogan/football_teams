//
//  NetworkClient.swift
//  Football_API
//
//  Created by Emre Dogan on 21/04/2022.
//

import Foundation


class NetworkClient {
    
    static var teams = [Team]()

    
    func makeDataRequest( completion: @escaping () -> ()) {
        let headers = [
            "X-RapidAPI-Host": "api-football-v1.p.rapidapi.com",
            "X-RapidAPI-Key": "144d8f8935msh73e730b7fa245cfp1ea48ajsn45c6ef3f9585"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://api-football-v1.p.rapidapi.com/v3/standings?season=2020&league=39")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                do {
                    let result = try JSONDecoder().decode(Result.self, from: data!)
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
                    
                    completion()
         

                } catch {
                    print(error)
                }


            }
        })

        dataTask.resume()
    }
    
}
