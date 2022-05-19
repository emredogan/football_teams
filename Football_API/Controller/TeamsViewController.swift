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
    
    // Services
    var imageRequestService = ImageRequestService.native
    var networkService = NetworkRequestService.native
    private let apiService = APIService()
    
    // Database
    private var teams = [Team]()
    private var subscribedTeams = [Team]()

    // Others
    private var isDownloadingData = false
    private var isFirstTime: Bool = true
    private var isFiltering = false
    
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
            self.title = "\(self.networkService),\(self.imageRequestService)"
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
        settingsViewController.currentImageRequestService = imageRequestService
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    
    // MARK: - FIREBASE SUBSCRIPTION
    func subscribeToATopicFirebase(_ team: Team?, _ indexPath: IndexPath) {
        if let team = team {
            if team.isSubscribed ?? false {
                self.popupAlert(message: "Already subscribed to team \(team.name)")
            } else {
                FirebaseService.subscribe(team) { success in
                    if(success) {
                        self.updateTeamsListAfterSubscribe(indexPath, teamName: team.name)
                        self.popupAlert(message: "Subscribed to team \(team.name)")
                    }
                }
            }
        }
    }
    
    func unsubscribeTopicFirebase(_ team: Team?, _ indexPath: IndexPath) {
        
        if let team = team {
            if !(team.isSubscribed ?? true) {
                self.popupAlert(message: "Already unsubscribed to team \(team.name)")
            } else {
                FirebaseService.unsubscribe(team) { success in
                    if(success) {
                        self.updateTeamsListAfterUnsubscribe(indexPath, teamName: team.name)
                        self.popupAlert(message: "Unsubscribed to team \(team.name)")
                    }
                }
            }
        }
    }
    
    func updateTeamsListAfterSubscribe(_ indexPath: IndexPath, teamName: String) {
        self.teams[indexPath.row].isSubscribed = true
        // Update filtered from main list
        self.subscribedTeams = self.teams.filter({ team in
            team.isSubscribed ?? false
        })
        self.teamsTableView.reloadRows(at: [indexPath], with: .top)
    }
    
    func updateTeamsListAfterUnsubscribe(_ indexPath: IndexPath, teamName: String) {
        if self.isFiltering {
            // Update mainlist from filtered list
            self.teams = self.teams.map { (team) -> Team in
                var team = team // make team var to able to change it below.
                if team.name == teamName {
                    team.isSubscribed = false
                }
                return team
            }
            self.subscribedTeams = self.teams.filter({ team in
                team.isSubscribed ?? false
            })
            self.teamsTableView.deleteRows(at: [indexPath], with: .top)

        } else {
            self.teams[indexPath.row].isSubscribed = false
            // Update filtered from main list
            self.subscribedTeams = self.teams.filter({ team in
                team.isSubscribed ?? false
            })
            self.teamsTableView.reloadRows(at: [indexPath], with: .top)
        }
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
        
        cell.setupCell(team: currentTeam, imageService: imageRequestService)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tappedTeam = returnTappedTeam(indexPath: indexPath)
        let unSubAction = UIContextualAction(style: .normal,
                                             title: "Unsubscribe") { [weak self] (action, view, completionHandler) in
            self?.unsubscribeTopicFirebase(tappedTeam, indexPath)
            completionHandler(true)
        }
        unSubAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [unSubAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let tappedTeam = returnTappedTeam(indexPath: indexPath)
        let subAction = UIContextualAction(style: .normal,
                                           title: "Subscribe") { [weak self] (action, view, completionHandler) in
            self?.subscribeToATopicFirebase(tappedTeam, indexPath)
            completionHandler(true)
        }
        subAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [subAction])
    }
    
    func returnTappedTeam(indexPath: IndexPath) -> Team? {
        if isFiltering {
            return subscribedTeams[indexPath.row]
            
        } else {
            return teams[indexPath.row]
        }
    }
}

extension TeamsViewController : NetworkSettingsDelegate {
    func didChooseNetwork(network: NetworkRequestService) {
        networkService = network
    }
    
    func didChooseImage(image: ImageRequestService) {
        imageRequestService = image
    }
}


