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
    
    private let shouldDownloadFootball = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()   // To hide the empty cells
        
        if(shouldDownloadFootball) {
            downloadData()
        } else {
            networkingClient.downloadJson {
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    func downloadData() {
        networkingClient.makeDataRequest(serviceName: .AF) { result in
            switch result {
            case .success(let teams):
                self.handleResult(result: teams)
            case .failure(let error):
                print(error)
                // REGULAR API CALL HAS FAILED ATTEMPTING TO GET DATA FROM THE FIRESTORE
                self.networkingClient.getDataFromFirebase { result in
                    switch result {
                    case .success(let teams):
                        self.handleResult(result: teams)
                    case .failure(let error):
                        print(error)
                    }
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
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldDownloadFootball {
            return teams.count
        } else {
            return NetworkService.heroes.count

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "football_cell", for: indexPath) as! FootballCell
        
        if shouldDownloadFootball {
            let currentTeam = teams[indexPath.row]
            cell.setupCell(name: currentTeam.name, url: currentTeam.logo, imageService: .kf)
        } else {
            let currentHero = NetworkService.heroes[indexPath.row]
            let heroImgURL = "https://api.opendota.com"+currentHero.img
            cell.setupCell(name: currentHero.localized_name, url: heroImgURL, imageService: .kf)
        }
        
        return cell
    }
}

