//
//  FootballCell.swift
//  Football_API
//
//  Created by Emre Dogan on 22/04/2022.
//

import UIKit



class FootballCell: UITableViewCell {
    @IBOutlet weak var footballLogo: UIImageView!
    
    @IBOutlet weak var footballTeamName: UILabel!
    
    
    func setupCell(name: String, url: String, imageService: Service) {
        footballTeamName.text = name
        switch imageService {
        case .native:
            footballLogo.imageFromServerURL(url, placeHolder: nil)
        case .kf:
            footballLogo.kf.setImage(with: URL(string: url))
        }
    }
    
}

enum Service {
    case native, kf
}
