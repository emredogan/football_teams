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
    @IBOutlet weak var ImageRequestServiceImage: UIImageView!
    
    // MARK: - VARIABLES
    var currentNetworkService = NetworkRequestService.native
    var currentImageRequestService = ImageRequestService.native
    var networkDelegate: NetworkSettingsDelegate!
    
    // MARK: - LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(networkServiceType: currentNetworkService, ImageRequestServiceType: currentImageRequestService)
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
        decideImageRequestService(providedIndex: index)
    }
    
    // MARK: - OTHERS
    func updateUI(networkServiceType: NetworkRequestService, ImageRequestServiceType: ImageRequestService) {
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
        
        switch ImageRequestServiceType {
        case .native:
            ImageRequestServiceImage.image = UIImage(named: "apple")
            imageSegment.selectedSegmentIndex = 0
        case .AF:
            ImageRequestServiceImage.image = UIImage(named: "alamofire")
            imageSegment.selectedSegmentIndex = 1
        case .KF:
            ImageRequestServiceImage.image = UIImage(named: "kingfisher")
            imageSegment.selectedSegmentIndex = 2
        }
    }
    
    func decideNetworkService(providedIndex: Int) {
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
    
    func decideImageRequestService(providedIndex: Int) {
        switch providedIndex {
        case 0:
            ImageRequestServiceImage.image = UIImage(named: "apple")
            networkDelegate.didChooseImage(image: ImageRequestService.native)
        case 1:
            ImageRequestServiceImage.image = UIImage(named: "alamofire")
            networkDelegate.didChooseImage(image: ImageRequestService.AF)
        case 2:
            ImageRequestServiceImage.image = UIImage(named: "kingfisher")
            networkDelegate.didChooseImage(image: ImageRequestService.KF)
        default:
            ImageRequestServiceImage.image = UIImage(named: "apple")
            networkDelegate.didChooseImage(image: ImageRequestService.native)
        }
    }
}

// MARK: - PROTOCOLS
protocol NetworkSettingsDelegate {
    func didChooseNetwork(network: NetworkRequestService)
    func didChooseImage(image: ImageRequestService)
}
