//
//  ViewController.swift
//  Football_API
//
//  Created by Emre Dogan on 21/04/2022.
//

import UIKit
import Kingfisher


class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let networkingClient = NetworkClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()   // To hide the empty cells
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        networkingClient.makeDataRequest(serviceName: .AF) {
            DispatchQueue.main.async {
                self.tableView.reloadData()

            }
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NetworkClient.teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "football_cell", for: indexPath) as! FootballCell
        let currentTeam = NetworkClient.teams[indexPath.row]
        cell.setupCell(name: currentTeam.name, url: currentTeam.logo, imageService: .native)
        return cell
    }
}

