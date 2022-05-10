//
//  AlertExtension.swift
//  Football_API
//
//  Created by Emre Dogan on 09/05/2022.
//

import Foundation
import UIKit

extension UIViewController {
    func popupAlert(message: String?) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func pushViewController<T:UIViewController>(viewController:T.Type) {
        guard let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: T.self)) as? T else { return }
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
