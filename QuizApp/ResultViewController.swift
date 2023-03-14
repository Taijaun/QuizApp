//
//  ResultViewController.swift
//  QuizApp
//
//  Created by Taijaun Pitt on 07/03/2023.
//

import UIKit

protocol ResultViewControllerProtocol {
    func dialogDismissed()
}

class ResultViewController: UIViewController {
    
    @IBOutlet weak var dimView: UIView!
    
    @IBOutlet weak var dialogView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    var titleText = ""
    var feedbackText = ""
    var buttonText = ""
    
    var delegate: ResultViewControllerProtocol?
    
    
    // happens once
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round the dialog box corners
        dialogView.layer.cornerRadius = 10
        
    }
    
    // happens whenever the view is going to be shown
    override func viewWillAppear(_ animated: Bool) {
        
        // Now that the elements have loaded, set the text
        titleLabel.text = titleText
        feedbackLabel.text = feedbackText
        dismissButton.setTitle(buttonText, for: .normal)
        
        // hide the UI Elements
        dimView.alpha = 0
        titleLabel.alpha = 0
        feedbackLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Fade in the dim view and elements

        UIView.animate(withDuration: 0.6, delay: 0, options:.curveEaseOut) {
            
            self.dimView.alpha = 1
            self.titleLabel.alpha = 1
            self.feedbackLabel.alpha = 1
        }
        
    }
    
    
    @IBAction func dismissTapped(_ sender: Any) {
        
        // Fade out the dim view and then dismiss the popup
        
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveEaseOut) {
            
            self.dimView.alpha = 0
            
        } completion: { completed in
            // Dismiss the popup
            self.dismiss(animated: true)
            
            // Notify delegate that the popup was dismiss
            // whoever is set as the delegate will have this method
            self.delegate?.dialogDismissed()
        }

    }
    

}
