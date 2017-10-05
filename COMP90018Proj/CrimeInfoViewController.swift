//
//  CrimeInfoViewController.swift
//  COMP90018Proj
//
//  Created by Kai Zhang on 28/9/17.
//  Copyright © 2017 Unimelb. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
//import GoogleMap
class ViewController: UIViewController, CLLocationManagerDelegate {
    var coreLactionManager = CLLocationManager()
    var locationManager : LocationManager!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreLactionManager.delegate = self
        locationManager = LocationManager.sharedInstance
        
        let authorizationCode =  CLLocationManager.authorizationStatus()
        if authorizationCode == CLAuthorizationStatus.notDetermined && coreLactionManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) || coreLactionManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)){
            if Bundle.main.object(forInfoDictionaryKey: "Privacy - Location Always Usage Description") != nil{
                coreLactionManager.requestAlwaysAuthorization()
            }else{
                print("No decription provided")
            }
        }else{
            getLocation()
        }
        
//        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//
//            if let placeLikelihoodList = placeLikelihoodList {
//                for likelihood in placeLikelihoodList.likelihoods {
//                    let place = likelihood.place
//                    print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
//                    print("Current Place address \(place.formattedAddress)")
//                    print("Current Place attributions \(place.attributions)")
//                    print("Current PlaceID \(place.placeID)")
//                    print("Current Place postcode\(place.postacode)")
//                }
//            }
//        })
        
        
        
        
        // get history information of crime of the corresponding area of current postcode
        var request = URLRequest(url: URL(string: "https://facedbidentify.herokuapp.com/api/crimeInfo?postcode=3000")!)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
}

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.notDetermined || status != CLAuthorizationStatus.denied || status != CLAuthorizationStatus.restricted {
            getLocation()
        }
    }
    
    func getLocation(){
        locationManager.startUpdatingLocationWithCompletionHandler { (latitude, longtitude, status, verboseMessage, error) in
            self.displayLocation(location: CLLocation(latitude: latitude, longitude: longtitude))
        }
    }
    
    func displayLocation(location:CLLocation){
        
        mapView.setRegion(MKCoordinateRegion(center:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude),span:MKCoordinateSpanMake(0.05, 0.05)), animated: true)
        //set pin to mapview
        let locationPinCoord = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationPinCoord
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
