//
//  Spots.swift
//  Snacktacular
//
//  Created by Lucas  Pomeroy  on 4/13/20.
//  Copyright © 2020 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase


class Spots {
    var spotArray = [Spot]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()){
        db.collection("spots").addSnapshotListener{ (querySnapshot, error) in
            guard error == nil else{
                print("error adding snapshot listener")
                return completed()
            }
            self.spotArray = []
            for document in querySnapshot!.documents{
                let spot = Spot(dictionary: document.data())
                spot.documentID = document.documentID
                self.spotArray.append(spot)
            }
            completed()
        }
    }
}
