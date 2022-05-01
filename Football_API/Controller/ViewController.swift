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
    
    typealias CompletionHandlerTeams = (Result<[Team], Error>) -> Void // To make the code more readable we put an alias here.


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()   // To hide the empty cells
        tableView.dataSource = self
        tableView.delegate = self
        
        
        // Do any additional setup after loading the view.
        networkingClient.makeDataRequest(serviceName: .AF) { result in
            switch result {
            case .success(let teams):
                self.teams = teams
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):

                self.getDataFromFirebase { result in
                    switch result {
                    case .success(let teams):
                        self.teams = teams
                        self.teams.sort(by: {$0.name < $1.name})

                        
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    case .failure(let error): break

                       


                    }
                }
                
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }


            }
            
        }
    }
    
    func getDataFromFirebase(completion: @escaping CompletionHandlerTeams) {
        let db = Firestore.firestore()
        db.collection("myTeams")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    //completion(.failure(nil))
                } else {
                    print("PRINTING DOCS")
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let team = Team(name: document.data()["name"] as! String, logo: document.data()["logo"] as! String)

                        self.teams.append(team)

                    }
                    
                    completion(.success(self.teams))

                }
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

