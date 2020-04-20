//
//  SpotDetailViewController.swift
//  Snacktacular
//
//  Created by John Gallaugher on 3/23/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class SpotDetailViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    var spot: Spot!
    var reviews: Reviews!
    let regionDistance: CLLocationDistance = 750
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
       
        //hide keyboard
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        
        
        
        if spot == nil{
            spot = Spot()
            getLocation()
            
            nameField.addBorder(width: 0.5, radius: 5.0, color: .black)
            addressField.addBorder(width: 0.5, radius: 5.0, color: .black)
        }else{
            nameField.isEnabled = false
            addressField.isEnabled = false
            nameField.backgroundColor = UIColor.white
            addressField.backgroundColor = UIColor.white
            saveBarButton.title = ""
            cancelBarButton.title = ""
            navigationController?.setToolbarHidden(true, animated: true)
        }
        reviews = Reviews()
        
        
        let region = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setToolbarHidden(false, animated: true)
        reviews.loadData(spot: spot) {
            self.tableView.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        spot.name = nameField.text!
        spot.address = addressField.text!
        switch segue.identifier ?? ""{
        case "addReview":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ReviewTableViewController
            destination.spot = spot
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        case "showReview":
            let destination = segue.destination as! ReviewTableViewController
            destination.spot = spot
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.review = reviews.reviewArray[selectedIndexPath.row]
        default:
            print("ERROR")
        }
    }
    
    func updateUserInterface(){
        nameField.text = spot.name
        addressField.text = spot.address
        updateMap()
    }
    
    func updateMap(){
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(spot)
        mapView.setCenter(spot.coordinate, animated: true)
    }
    
    func leaveViewController(){
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func photoButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "addReview", sender: nil)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        saveBarButton.isEnabled = !(nameField.text == "")
    }
    
    @IBAction func textFieldReturnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
        spot.name = nameField.text!
        spot.address = addressField.text!
        updateUserInterface()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        spot.name = nameField.text!
        spot.address = addressField.text!
        spot.saveData{ success in
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
    
    @IBAction func lookupPlacePressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    
}
extension SpotDetailViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    spot.name = place.name ?? ""
    spot.address = place.formattedAddress ?? ""
    spot.coordinate = place.coordinate
    dismiss(animated: true, completion: nil)
    updateUserInterface()
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}

extension SpotDetailViewController: CLLocationManagerDelegate{

    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
    }

    func handleAuthorizationStatus (status: CLAuthorizationStatus){
           
           switch status{
               
           case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
           case .restricted:
               self.oneButtonAlert(title: "Location Services Denied", message: "")
           case .denied:
               break
           case .authorizedAlways, .authorizedWhenInUse:
               locationManager.requestLocation()
           @unknown default:
               print("Unkown case of status")
           }
            
       }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         print("Checking auth status" )
        handleAuthorizationStatus(status: status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard spot.name == "" else {
            return
        }
        
        
        let geoCoder = CLGeocoder()
        var name = ""
        var address = ""
        let currentLocation = locations.last ?? CLLocation()
        spot.coordinate = currentLocation.coordinate
        geoCoder.reverseGeocodeLocation(currentLocation) { ( placemarks, error ) in
            
            if placemarks != nil{
                let placemark = placemarks?.last
                name = placemark?.name ?? "Unknown"
                if let postalAddress =  placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            }else{
                print("Error")
                
            }
            print("Location name: \(name)")
            
            self.spot.name = name
            self.spot.address = address
            
            self.updateUserInterface()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //deal with erre
    }
}

extension SpotDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! SpotReviewsTableViewCell
        cell.review = reviews.reviewArray[indexPath.row]
        return cell
    }
    
    
}
