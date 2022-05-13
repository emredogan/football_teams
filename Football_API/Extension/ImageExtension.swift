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

extension UIImageView {
    func imageFromServerURL(_ urlString: String, imageService: ImageService) {
        print("Requesting image service by, ", imageService)
        
        //Only use url allowed chars. For example get rid of spaces.
        let imageServerUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        
        switch imageService {
        case .native:
            
            if let url = URL(string: imageServerUrl) {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    
                    if let data = data, let downloadedImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.image = downloadedImage
                        }
                    }
                    
                }).resume()
            }
        case .AF:
            AF.request(imageServerUrl,method: .get).response{ response in
                switch response.result {
                case .success(let responseData):
                    if let responseData = responseData, let image = UIImage(data: responseData, scale: 1) {
                        DispatchQueue.main.async {
                            self.image = image
                        }
                    }
                case .failure(let error):
                    print("Error:",error)
                }
            }
        case .KF:
            self.kf.setImage(with: URL(string: imageServerUrl))
        }
    }
    
}
