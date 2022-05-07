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
    public static var imageRequestType = ImageService.native
    public static var networkService = RequestService.native

    @IBOutlet weak var tableView: UITableView!
    let networkingClient = NetworkService()
    
    private var teams = [Team]()
    private let fireDB = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()   // To hide the empty cells
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(self.showSettings))
        downloadData(reqService: .native)
    }
    
    @objc func showSettings() {
        let ac = UIAlertController(title: "Write the services that you want to use", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()
        
        let networkServiceTypeTF = ac.textFields![0]
        let imageLoadingServiceTypeTF = ac.textFields![1]
        
        networkServiceTypeTF.placeholder = "Network service. (native, AF)"
        imageLoadingServiceTypeTF.placeholder = "Image service. (native, AF, KF)"

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak ac] _ in
            if(networkServiceTypeTF.text!.uppercased() == "AF") {
                TeamsViewController.networkService = RequestService.AF
            } else {
                TeamsViewController.networkService = RequestService.native
            }
            
            if(imageLoadingServiceTypeTF.text!.uppercased() == "AF") {
                TeamsViewController.imageRequestType = ImageService.AF
            } else if(imageLoadingServiceTypeTF.text!.uppercased() == "KF") {
                TeamsViewController.imageRequestType = ImageService.KF
            } else {
                TeamsViewController.imageRequestType = ImageService.native
            }
            
            self.teams.removeAll()
            self.tableView.reloadData()
            self.downloadData(reqService: TeamsViewController.networkService)
        }

        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func downloadData(reqService: RequestService) {
        changeNavigationHeader()
        networkingClient.makeDataRequest(serviceName: reqService) { result in
            switch result {
            case .success(let teams):
                self.handleResult(result: teams)
            case .failure(let error):
                // create the alert
                        let alert = UIAlertController(title: "Warning", message: "API call has failed, attempting to retrieve data from Firebase", preferredStyle: UIAlertController.Style.alert)

                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                TeamsViewController.networkService = RequestService.Firebase
                self.downloadData(reqService: TeamsViewController.networkService)
            }
        }
    }
    
    func changeNavigationHeader() {
        DispatchQueue.main.async {
            self.title = "\(TeamsViewController.networkService),\(TeamsViewController.imageRequestType)"
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
        cell.setupCell(name: currentTeam.name, url: currentTeam.logo, imageService: .kf)
        return cell
    }
}


