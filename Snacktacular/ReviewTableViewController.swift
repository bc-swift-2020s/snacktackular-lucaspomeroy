//
//  ReviewTableViewController.swift
//  Snacktacular
//
//  Created by Lucas  Pomeroy  on 4/20/20.
//  Copyright © 2020 Lucas Pomeroy. All rights reserved.
//

import UIKit

class ReviewTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var reviewTitle: UITextField!
    @IBOutlet weak var reviewView: UITextView!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var buttonsBackgroundView: UIView!
    @IBOutlet weak var reviewDateLabel: UILabel!
    
    @IBOutlet var starButtonCollection: [UIButton]!
    
    
    var spot: Spot!
    var review: Review!
    var rating = 0{
        didSet{
            for starButton in starButtonCollection{
                let image = UIImage(named: ( starButton.tag < rating ? "star-filled" : "star-empty" ))
                starButton.setImage(image, for: .normal )
            }
            review.rating = rating
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide keyboard
               let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
               tap.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tap)
        
        guard let spot = spot else{
            print("ERROR")
            return
        }
        nameLabel.text = spot.name
        addressLabel.text = spot.address
        if review == nil{
            review = Review()
             
        }

        
    }
    
    func leaveViewController(){
          let isPresentingInAddMode = presentingViewController is UINavigationController
          if isPresentingInAddMode {
              dismiss(animated: true, completion: nil)
          } else {
              navigationController?.popViewController(animated: true)
          }
      }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        review.title = reviewTitle.text!
        review.text = reviewView.text!
        
        
        review.saveData(spot: spot){ (success) in
                   if success{
                       self.leaveViewController()

                   }else{
                       print("error could not leave this view controller because data wasnt saved.")
                   }
               }
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController() 
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    }
     
    @IBAction func reviewTitleChanged(_ sender: UITextField) {
    }
    @IBAction func returnTitleDonePressed(_ sender: UITextField) {
    }
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        rating = sender.tag + 1
    }
}
