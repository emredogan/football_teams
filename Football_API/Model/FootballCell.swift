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
    
    func setupCell(name: String, url: String, imageService: ImageService) {
        footballTeamName.text = name
        footballLogo.imageFromServerURL(url, imageService: imageService)
    }
}
