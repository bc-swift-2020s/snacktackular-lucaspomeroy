//
//  Review.swift
//  Snacktacular
//
//  Created by Lucas  Pomeroy  on 4/20/20.
//  Copyright © 2020 Lucas Pomeroy. All rights reserved.
//

import Foundation
import Firebase

class Review{
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any]{
          return["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": date, "document": documentID]
      }
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String ) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]){
           let title = dictionary["title"] as! String? ?? ""
           let text = dictionary["text"] as! String? ?? ""
           let rating = dictionary["rating"] as! Int? ?? 0
           let reviewerUserID = dictionary["reviewerUserID"] as! String? ?? ""
           let fireBaseDate = dictionary["date"] as! Timestamp? ?? Timestamp()
           let documentID = dictionary["documentID"] as! String? ?? ""
           
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, date: fireBaseDate.dateValue(), documentID: "")
       
       }
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unkown User"
        
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID , date: Date(), documentID: "" )
    }
    
    func saveData(spot: Spot,completed: @escaping (Bool) -> ()){
            let db = Firestore.firestore()
            
            let dataToSave = self.dictionary
            if self.documentID != ""{
                let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
                ref.setData(dataToSave){ (error) in
                    if let error = error{
                        print("Error Updating")
                         completed(false)
                    }else{
                        print("successfully updated")
                        completed(true)
                        
                    }
                    
                }
            } else {
                var ref: DocumentReference? = nil
                ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave){ (error) in
                if let error = error{
                    print("Error creating")
                     completed(false)
                }else{
                    print("successfully created")
                    completed(true)
                    
                }
            }
        }
    }
}


