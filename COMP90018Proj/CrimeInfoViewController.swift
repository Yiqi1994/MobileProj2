//
//  CrimeInfoViewController.swift
//  COMP90018Proj
//
//  Created by Kai Zhang on 28/9/17.
//  Copyright © 2017 Unimelb. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Foundation


class CrimeInfoViewController: UIViewController, CLLocationManagerDelegate {
//    @IBOutlet weak var tableView: UITableView!
//
//
//
//
//
//    var items:[(days:String,city:String,inches:String)]?
//
//    private var cityValue:[String]=[]
//    private var inchesValue:[String]=[]
    
    
    
    
    
    
    
    
    
    
    
    

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways{
            print("no authorization")
            return
        }
        
        if !CLLocationManager.locationServicesEnabled() {
            print("location serivice not available")
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        lookUpCurrentLocation(completionHandler: {(location: CLPlacemark?) in
            print(location?.postalCode)
            self.getDataFromDB(postcode: (location?.postalCode)!)
        })
        
        mapView.showsUserLocation=true
        
        
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
//        let pinForUserLocation = MKPointAnnotation()
//        pinForUserLocation.coordinate = myLocation
//
//        mapView.addAnnotation(pinForUserLocation)
//        mapView.showAnnotations([pinForUserLocation], animated: true)
          mapView.setRegion(region, animated: true)
    
        
    }
    
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void) {
        if let lastLocation = self.locationManager.location{
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: {(placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                } else {
                    completionHandler(nil)
                }
            })
        } else {
            completionHandler(nil)
        }
    }
    
    
    func getDataFromDB(postcode:String){
        // get history information of crime of the corresponding area of current postcode
        var request = URLRequest(url: URL(string: "https://facedbidentify.herokuapp.com/api/crimeInfo?postcode=\(String(describing: postcode))")!)
        
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
            self.extractJSON(json:response)
       
        }
        task.resume()
    }
    
    

    @IBAction func updateInfoFromDB(_ sender: Any) {
        lookUpCurrentLocation(completionHandler: {(location: CLPlacemark?) in
            print(location?.postalCode)
            self.getDataFromDB(postcode: (location?.postalCode)!)
        })
    }
    
    func extractJSON(json:Any) {
        do {
            let data1 = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(describing:(data:data1,String.Encoding.utf8))
            print("convertedString =\(String(describing:convertedString))")
        }catch {
            print(error.localizedDescription)
        }
        
    }
    
    struct Todo:Codable {
        var suburb:String
        var offenceType:String
    }
    
    // count the apperance of key in jsonString or jsonArray
//    func countAppearance(JSONArray: Array<Any>){
//        var counts:[String:Int] = [:]
//        for item in JSONArray{
//            counts[item] = counts[item,default:0]+=1
//        }
//        print(counts)
//        
//        for(key, value) in counts {
//            print("\(key) occurs \(value) time(s)")
//        }
//    }
    
}
