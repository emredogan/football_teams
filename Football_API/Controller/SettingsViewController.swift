//
//  SettingsViewController.swift
//  Football_API
//
//  Created by Emre Dogan on 08/05/2022.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - IBOUTLETS
    @IBOutlet weak var networkSegment: UISegmentedControl!
    @IBOutlet weak var imageSegment: UISegmentedControl!
    
    @IBOutlet weak var networkImage: UIImageView! 
    @IBOutlet weak var imageServiceImage: UIImageView!
    
    // MARK: - VARIABLES
    var currentNetworkService = NetworkRequestService.native
    var currentImageService = ImageService.native
    var networkDelegate: NetworkSettingsDelegate!
    
    // MARK: - LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(networkServiceType: currentNetworkService, imageServiceType: currentImageService)
    }
    
    // MARK: - HANDLE VIEW ACTIONS
    @IBAction func networkSegmentedControlTapped(_ sender: UISegmentedControl) {
        networkTapped()
    }
    
    @IBAction func imageSegmentedControlTapped(_ sender: UISegmentedControl) {
        imageTapped()
    }
    
    func networkTapped() {
        let index = networkSegment.selectedSegmentIndex
        decideNetworkService(providedIndex: index)
    }
    
    func imageTapped() {
        let index = imageSegment.selectedSegmentIndex
        decideImageService(providedIndex: index)
    }
    
    // MARK: - OTHERS
    func updateUI(networkServiceType: NetworkRequestService, imageServiceType: ImageService) {
        switch networkServiceType {
        case .native:
            networkImage.image = UIImage(named: "apple")
            networkSegment.selectedSegmentIndex = 0
        case .AF:
            networkImage.image = UIImage(named: "alamofire")
            networkSegment.selectedSegmentIndex  = 1
        case .Firebase:
            networkImage.image = UIImage(named: "firebase")
            networkSegment.selectedSegmentIndex = 2
        }
        
        switch imageServiceType {
        case .native:
            imageServiceImage.image = UIImage(named: "apple")
            imageSegment.selectedSegmentIndex = 0
        case .AF:
            imageServiceImage.image = UIImage(named: "alamofire")
            imageSegment.selectedSegmentIndex = 1
        case .KF:
            imageServiceImage.image = UIImage(named: "kingfisher")
            imageSegment.selectedSegmentIndex = 2
        }
    }
    
    func decideNetworkService(providedIndex: Int) {
        //let index = networkSegment.selectedSegmentIndex
        switch providedIndex {
        case 0:
            networkImage.image = UIImage(named: "apple")
            networkDelegate.didChooseNetwork(network: NetworkRequestService.native)
        case 1:
            networkImage.image = UIImage(named: "alamofire")
            networkDelegate.didChooseNetwork(network: NetworkRequestService.AF)
        case 2:
            networkImage.image = UIImage(named: "firebase")
            networkDelegate.didChooseNetwork(network: NetworkRequestService.Firebase)
        default:
            networkImage.image = UIImage(named: "apple")
            networkDelegate.didChooseNetwork(network: NetworkRequestService.native)
        }
    }
    
    func decideImageService(providedIndex: Int) {
        switch providedIndex {
        case 0:
            imageServiceImage.image = UIImage(named: "apple")
            networkDelegate.didChooseImage(image: ImageService.native)
        case 1:
            imageServiceImage.image = UIImage(named: "alamofire")
            networkDelegate.didChooseImage(image: ImageService.AF)
        case 2:
            imageServiceImage.image = UIImage(named: "kingfisher")
            networkDelegate.didChooseImage(image: ImageService.KF)
        default:
            imageServiceImage.image = UIImage(named: "apple")
            networkDelegate.didChooseImage(image: ImageService.native)
        }
    }
}

// MARK: - PROTOCOLS
protocol NetworkSettingsDelegate {
    func didChooseNetwork(network: NetworkRequestService)
    func didChooseImage(image: ImageService)
}
