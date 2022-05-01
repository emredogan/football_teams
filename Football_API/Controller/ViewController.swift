//
//  ViewController.swift
//  Football_API
//
//  Created by Emre Dogan on 21/04/2022.
//

import UIKit
import Kingfisher
import FirebaseFirestore
import FirebaseFirestoreSwift



class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let networkingClient = NetworkService()
    
    private var teams = [Team]()
    private let fireDB = Firestore.firestore()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()   // To hide the empty cells
        tableView.dataSource = self
        tableView.delegate = self
        
        
        // Do any additional setup after loading the view.
        networkingClient.makeDataRequest(serviceName: .AF) { result in
            switch result {
            case .success(let teams):
                self.handleResult(result: teams)
            case .failure(let error):
                
                self.networkingClient.getDataFromFirebase { result in
                    switch result {
                    case .success(let teams):
                        self.handleResult(result: teams)
                    case .failure(let error): break
                        
                        
                        
                        
                    }
                }
                
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            }
            
        }
    }
    
    func handleResult(result: [Team]) {
        self.teams = result
        teams.sort(by: {$0.name < $1.name})
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    
    
    // USED TO TEMPORARLY SAVE DATA IN FIREBASE STORE
    /*func writeData(teams: [Team]) {
     print("WRITING DATA TO FIREBASE")
     
     for team in teams {
     do { // 2
     let team = team
     
     try fireDB.collection("myTeams").document(randomString(length: 10)).setData(from: team)
     } catch {
     // handle the error here
     print("ERROR is saving to DB")
     }
     }
     
     
     
     }
     
     func randomString(length: Int) -> String {
     let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
     return String((0..<length).map{ _ in letters.randomElement()! })
     } */
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "football_cell", for: indexPath) as! FootballCell
        let currentTeam = teams[indexPath.row]
        cell.setupCell(name: currentTeam.name, url: currentTeam.logo, imageService: .kf)
        return cell
    }
}

