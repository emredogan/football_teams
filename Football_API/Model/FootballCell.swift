//
//  FootballCell.swift
//  Football_API
//
//  Created by Emre Dogan on 22/04/2022.
//

import UIKit
import Alamofire

class FootballCell: UITableViewCell {
    @IBOutlet weak var footballLogo: UIImageView!
    @IBOutlet weak var footballTeamName: UILabel!
    
    func setupCell(name: String, url: String, imageService: Service) {
        footballTeamName.text = name
        switch imageService {
        case .native:
            footballLogo.imageFromServerURL(url, imageService: TeamsViewController.imageRequestType)
        case .kf:
            footballLogo.imageFromServerURL(url, imageService: TeamsViewController.imageRequestType)
        case .AF:
            footballLogo.imageFromServerURL(url, imageService: TeamsViewController.imageRequestType)
        }
    }
}

enum Service {
    case native, kf, AF
}
