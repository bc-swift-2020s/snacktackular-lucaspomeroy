//
//  Spot.swift
//  Snacktacular
//
//  Created by Lucas  Pomeroy  on 4/13/20.
//  Copyright © 2020 John Gallaugher. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Spot{
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var longitude: CLLocationDegrees{
        return coordinate.longitude
    }
    var latitude: CLLocationDegrees{
        return coordinate.latitude
    }
    
    var dictionary: [String: Any]{
        return["name": name, "address": address, "longitude": longitude, "latitude": latitude, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init(){
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    convenience init(dictionary: [String: Any]){
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviewa = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUSerID = dictionary["postingUserID "] as! String? ?? ""
        self.init(name: name, address: address, coordinate: coordinate, averageRating: averageRating, numberOfReviews: numberOfReviewa, postingUserID: postingUSerID, documentID: "")
    
    }
    
    
    func saveData(completed: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        guard let postingUSerID = (Auth.auth().currentUser?.uid) else{
            return completed(false)
        }
        self.postingUserID = postingUSerID
        let dataToSave = self.dictionary
        if self.documentID != ""{
            let ref = db.collection("spots").document(self.documentID)
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
            ref = db.collection("spots").addDocument(data: dataToSave){ (error) in
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
