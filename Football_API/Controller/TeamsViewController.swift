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
    var imageRequestType = ImageService.native
    var networkService = RequestService.native
    
    @IBOutlet weak var tableView: UITableView!
    let networkingClient = NetworkService()
    
    private var isDownloadingData = false
    
    private var teams = [Team]()
    private let fireDB = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        if(!isDownloadingData) {
            downloadData(reqService: networkService)
            changeNavigationHeader()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()   // To hide the empty cells
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(self.showSettings))
        downloadData(reqService: .native)
    }
    
    @objc func showSettings() {
        let settingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsViewController.networkDelegate = self
        settingsViewController.currentNetworkService = networkService
        settingsViewController.currentImageService = imageRequestType
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    func downloadData(reqService: RequestService) {
        isDownloadingData = true
        changeNavigationHeader()
        networkingClient.makeDataRequest(serviceName: reqService) { [weak self] result in
            switch result {
            case .success(let teams):
                self?.handleResult(result: teams)
                self?.isDownloadingData = false
            case .failure(let error):
                self?.isDownloadingData = false
                // create the alert
                let alert = UIAlertController(title: "Warning", message: "API call has failed, attempting to retrieve data from Firebase", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self?.present(alert, animated: true, completion: nil)
                self?.networkService = RequestService.Firebase
                self?.downloadData(reqService: self?.networkService ?? RequestService.native)
                self?.changeNavigationHeader()
            }
        }
    }
    
    func changeNavigationHeader() {
        DispatchQueue.main.async {
            self.title = "\(self.networkService),\(self.imageRequestType)"
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
    func didChooseNetwork(network: RequestService) {
        networkService = network
    }
    
    func didChooseImage(image: ImageService) {
        imageRequestType = image
    }
}


