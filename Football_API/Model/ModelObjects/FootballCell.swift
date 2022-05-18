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
    @IBOutlet weak var subscribeImage: UIImageView!
    
    func setupCell(team: Team, imageService: ImageRequestService) {
        footballTeamName.text = team.name
        footballLogo.imageFromServerURL(team.logo, imageService: imageService)
        if(team.isSubscribed ?? false) {
            subscribeImage.image = UIImage(named: "premier")
        } else {
            subscribeImage.image = nil
        }
    }
}
