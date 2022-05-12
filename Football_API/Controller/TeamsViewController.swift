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

class TeamsViewController: UIViewController {
    
    // MARK: - IBOUTLETS
    @IBOutlet weak var teamsTableView: UITableView!
    
    // MARK: - VARIABLES
    var imageRequestType = ImageService.native
    var networkService = NetworkRequestService.native
    private let networkingClient = NetworkService()
    private var isDownloadingData = false
    private var teams = [Team]()
    private let fireDB = Firestore.firestore()
    
    // MARK: - LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        teamsTableView.dataSource = self
        teamsTableView.delegate = self
        setupNavigationItem()
        downloadData(reqService: .native)
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
    
    func changeNavigationHeader() {
        DispatchQueue.main.async {
            self.title = "\(self.networkService),\(self.imageRequestType)"
        }
    }
    
    // MARK: - NETWORK METHODS
    func downloadData(reqService: NetworkRequestService) {
        isDownloadingData = true
        changeNavigationHeader()
        networkingClient.makeDataRequest(serviceName: reqService) { [weak self] result in
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
}

// MARK: - EXTENSIONS
extension TeamsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "football_cell", for: indexPath) as! FootballCell
        let currentTeam = teams[indexPath.row]
        cell.setupCell(name: currentTeam.name, url: currentTeam.logo, imageService: imageRequestType)
        return cell
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


