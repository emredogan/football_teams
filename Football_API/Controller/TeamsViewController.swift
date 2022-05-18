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
import FirebaseMessaging


class TeamsViewController: UIViewController {
    
    // MARK: - IBOUTLETS
    @IBOutlet weak var teamsTableView: UITableView!
    @IBOutlet weak var subscribeSegmentedControl: UISegmentedControl!
    
    // MARK: - VARIABLES
    var imageRequestType = ImageService.native
    var networkService = NetworkRequestService.native
    private let apiService = APIService()
    private var isDownloadingData = false
    private var teams = [Team]()
    private var isFirstTime: Bool = true
    private var subscribedTeams = [Team]()
    private var isFiltering = false
    private let fireDB = Firestore.firestore()
    
    // MARK: - LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        teamsTableView.dataSource = self
        teamsTableView.delegate = self
        downloadData(reqService: .native)
        apiService.isDeveloperFromFirebase { isDev in
            DispatchQueue.main.async {
                if isDev {
                    self.setupNavigationItem()
                } else {
                    self.hideNavigationItem()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(!isDownloadingData) {
            downloadData(reqService: networkService)
        }
    }
    
    // MARK: - PREPARE USER INTERFACE
    func setupNavigationItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(self.showSettings))
    }
    
    func hideNavigationItem() {
        self.navigationItem.rightBarButtonItem = nil

    }
    
    
    
    func changeNavigationHeader() {
        DispatchQueue.main.async {
            self.title = "\(self.networkService),\(self.imageRequestType)"
        }
    }
    
    
    @IBAction func subscribeSegmentTapped(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isFiltering = false
            subscribedTeams = teams
            
            
        } else {
            isFiltering = true
            subscribedTeams = teams.filter({ team in
                team.isSubscribed ?? false
            })
        }
        
        teamsTableView.reloadData()
    }
    
    // MARK: - NETWORK METHODS
    func downloadData(reqService: NetworkRequestService) {
        isDownloadingData = true
        changeNavigationHeader()
        apiService.makeDataRequest(serviceName: reqService) { [weak self] result in
            switch result {
            case .success(let teams):
                self?.isDownloadingData = false
                self?.handleResult(result: teams)
            case .failure(let error):
                if(self?.networkService != NetworkRequestService.Firebase) {
                    print(error.localizedDescription)
                    self?.backUpDownload()
                }
            }
        }
    }
    
    func backUpDownload() {
        isDownloadingData = false
        popupAlert(message: "API call has failed, attempting to retrieve data from Firebase")
        networkService = NetworkRequestService.Firebase
        downloadData(reqService: networkService)
    }
    
    func handleResult(result: [Team]) {
        self.teams = result
        teams.sort(by: {$0.name < $1.name})
        DispatchQueue.main.async {
            self.teamsTableView.reloadData()
        }
    }
    
    // MARK: - NAVIGATION
    @objc func showSettings() {
        let settingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsViewController.networkDelegate = self
        settingsViewController.currentNetworkService = networkService
        settingsViewController.currentImageService = imageRequestType
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    
    // MARK: - FIREBASE SUBSCRIPTION
    func subscribeToATopicFirebase(_ teamName: String, _ indexPath: IndexPath) {
        if self.isFiltering {
            self.popupAlert(message: "Already subscribed to team \(teamName)")
        } else {
            let trimmedTeamName = teamName.filter {!$0.isWhitespace}
            Messaging.messaging().subscribe(toTopic: trimmedTeamName) { error in
                if error != nil {
                    self.popupAlert(message: error?.localizedDescription)
                    return
                }
                
                self.updateTeamsListAfterSubscribe(indexPath, teamName: teamName)
                
                self.teamsTableView.reloadRows(at: [indexPath], with: .top)
                self.popupAlert(message: "Subscribed to team \(teamName)")
            }
            
            
            
            
        }
    }
    
    
    
    func unsubscribeTopicFirebase(_ teamName: String, _ indexPath: IndexPath) {
        let trimmedTeamName = teamName.filter {!$0.isWhitespace}
        Messaging.messaging().unsubscribe(fromTopic: trimmedTeamName) { error in
            if error != nil {
                self.popupAlert(message: error?.localizedDescription)
                return
            }
            
            self.updateTeamsListAfterUnsubscribe(indexPath, teamName: teamName)
            
            if self.isFiltering {
                self.teamsTableView.deleteRows(at: [indexPath], with: .top)
            } else {
                self.teamsTableView.reloadRows(at: [indexPath], with: .top)
            }
            
            self.popupAlert(message: "Unsubscribed to team \(teamName)")
        }
        
    }
    
    func updateTeamsListAfterSubscribe(_ indexPath: IndexPath, teamName: String) {
        if isFiltering {
            self.subscribedTeams[indexPath.row].isSubscribed = true
            self.teams = self.teams.map { (team) -> Team in
                var team = team
                if team.name == teamName {
                    team.isSubscribed = false
                }
                return team
            }
        } else {
            self.teams[indexPath.row].isSubscribed = true
            self.subscribedTeams = self.teams.filter({ team in
                team.isSubscribed ?? false
            })
        }
        
        
    }
    
    func updateTeamsListAfterUnsubscribe(_ indexPath: IndexPath, teamName: String) {
        if self.isFiltering {
            self.teams = self.teams.map { (team) -> Team in
                var team = team
                if team.name == teamName {
                    team.isSubscribed = false
                }
                return team
            }
        } else {
            self.teams[indexPath.row].isSubscribed = false
        }
        
        self.subscribedTeams = self.teams.filter({ team in
            team.isSubscribed ?? false
        })
    }
}

// MARK: - TABLE VIEW EXTENSIONS
extension TeamsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? subscribedTeams.count : teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "football_cell", for: indexPath) as! FootballCell
        cell.selectionStyle = .none
        let currentTeam = isFiltering ? subscribedTeams[indexPath.row] : teams[indexPath.row]
        
        cell.setupCell(team: currentTeam, imageService: imageRequestType)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var tappedTeam : Team?
        if isFiltering {
            tappedTeam = subscribedTeams[indexPath.row]
            
        } else {
            tappedTeam = teams[indexPath.row]
            
        }
        
        
        let unSubAction = UIContextualAction(style: .normal,
                                             title: "Unsubscribe") { [weak self] (action, view, completionHandler) in
            self?.unsubscribeTopicFirebase(tappedTeam?.name ?? "", indexPath)
            completionHandler(true)
        }
        unSubAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [unSubAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        var tappedTeam : Team?
        if isFiltering {
            tappedTeam = subscribedTeams[indexPath.row]
            
        } else {
            tappedTeam = teams[indexPath.row]
            
        }
        
        let subAction = UIContextualAction(style: .normal,
                                           title: "Subscribe") { [weak self] (action, view, completionHandler) in
            self?.subscribeToATopicFirebase(tappedTeam?.name ?? "", indexPath)
            completionHandler(true)
        }
        subAction.backgroundColor = .systemBlue
        
        
        
        return UISwipeActionsConfiguration(actions: [subAction])
        
    }
    
}

extension TeamsViewController : NetworkSettingsDelegate {
    func didChooseNetwork(network: NetworkRequestService) {
        networkService = network
    }
    
    func didChooseImage(image: ImageService) {
        imageRequestType = image
    }
}


