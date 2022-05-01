//
//  ImageExtension.swift
//  Football_API
//
//  Created by Emre Dogan on 22/04/2022.
//

import Foundation
import UIKit
import Kingfisher
import Alamofire

enum ImageService {
    case native, AF, KF
}

extension UIImageView {
    
    func imageFromServerURL(_ urlString: String, service: ImageService) {
        //If imageurl's imagename has space then this line going to work for this
        let imageServerUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString

        switch service {
        case .native:
            
            if let url = URL(string: imageServerUrl) {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    
                    if error != nil {
                        DispatchQueue.main.async {
                            // TO - DO
                            self.image = nil
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        if let data = data {
                            if let downloadedImage = UIImage(data: data) {
                                self.image = downloadedImage
                            }
                        }
                    }
                }).resume()
            }
        case .AF:
            AF.request(imageServerUrl,method: .get).response{ response in
                switch response.result {
                case .success(let responseData):
                    self.image = UIImage(data: responseData!, scale:1)
                    
                case .failure(let error):
                    print("error--->",error)
                }
            }
        case .KF:
            self.kf.setImage(with: URL(string: imageServerUrl))
        }
    }
    
}
