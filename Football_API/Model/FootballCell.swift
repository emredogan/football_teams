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
            footballLogo.imageFromServerURLNative(url, placeHolder: nil)
        case .kf:
            footballLogo.imageFromServerURLKF(url: url)
        case .AF:
            footballLogo.imageFromServerURLAF(url: url)
        }
    }
    
}

enum Service {
    case native, kf, AF
}
