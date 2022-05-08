//
//  SettingsViewController.swift
//  Football_API
//
//  Created by Emre Dogan on 08/05/2022.
//

import UIKit

protocol NetworkSettingsDelegate {
    func didChooseNetwork(network: RequestService)
    func didChooseImage(image: ImageService)
}



class SettingsViewController: UIViewController {
    
    @IBOutlet weak var networkSegment: UISegmentedControl!
    
    @IBOutlet weak var imageSegment: UISegmentedControl!
    
    var currentNetworkService = RequestService.native
    var currentImageService = ImageService.native
    
    var networkDelegate: NetworkSettingsDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch currentNetworkService {
        case .AF:
            networkSegment.selectedSegmentIndex  = 1
        case .native:
            networkSegment.selectedSegmentIndex = 0
        case .Firebase:
            networkSegment.selectedSegmentIndex = 2

        }
        
        switch currentImageService {
        case .native:
            imageSegment.selectedSegmentIndex = 0
        case .AF:
            imageSegment.selectedSegmentIndex = 1
        case .KF:
            imageSegment.selectedSegmentIndex = 2
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func networkSegmentedControlTapped(_ sender: UISegmentedControl) {
        networkTapped()
    }
    
    @IBAction func imageSegmentedControlTapped(_ sender: UISegmentedControl) {
        imageTapped()
    }
    
    func networkTapped() {
        let index = networkSegment.selectedSegmentIndex
        switch index {
        case 0:
            networkDelegate.didChooseNetwork(network: RequestService.native)
        case 1:
            networkDelegate.didChooseNetwork(network: RequestService.AF)
        case 2:
            networkDelegate.didChooseNetwork(network: RequestService.Firebase)
        default:
            networkDelegate.didChooseNetwork(network: RequestService.native)
        }
        
    }
    
    func imageTapped() {
        let index = imageSegment.selectedSegmentIndex
        switch index {
        case 0:
            networkDelegate.didChooseImage(image: ImageService.native)
        case 1:
            networkDelegate.didChooseImage(image: ImageService.AF)
            
        case 2:
            networkDelegate.didChooseImage(image: ImageService.KF)
        default:
            networkDelegate.didChooseImage(image: ImageService.native)
        }
    }

}
