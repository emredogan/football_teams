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

    
        func imageFromServerURLNative(_ URLString: String, placeHolder: UIImage?) {

        self.image = nil
        //If imageurl's imagename has space then this line going to work for this
        let imageServerUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        

        if let url = URL(string: imageServerUrl) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: ", error!)
                    DispatchQueue.main.async {
                        self.image = placeHolder
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
    }
    
    func imageFromServerURLAF(url: String) {
        AF.request( url,method: .get).response{ response in
            print("Requesting image with AF")
            switch response.result {
            case .success(let responseData):
                self.image = UIImage(data: responseData!, scale:1)
                
            case .failure(let error):
                print("error--->",error)
            }
        }
    }
    
    func imageFromServerURLKF(url: String) {
        self.kf.setImage(with: URL(string: url))
    }
    
    
    
    
}
