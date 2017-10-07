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
import SwiftyJSON

class CrimeInfoViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    var curPostcode: String! = "9999"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get and verify authorization
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

        // show user locaiton on map
        mapView.showsUserLocation=true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // set map region when location get updated and send crime info request
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get current location
        let location = locations[0]
        
        // set map region
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        
        // get postcode and if send crime info request when postcode changes
        lookUpCurrentLocation(location: location, completionHandler: {(placeMark: CLPlacemark?) in
            let newPostcode = placeMark?.postalCode
            if(newPostcode != self.curPostcode){
                self.curPostcode = newPostcode!
                self.getDataFromDB(postcode: self.curPostcode)
            }
        })
    }
    
    // return postcode of current location
    func lookUpCurrentLocation(location: CLLocation, completionHandler: @escaping (CLPlacemark?) -> Void) {
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
        // get history crime information of current area based on postcode
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
            
            // convert response into json array
            let responseString = String(data: data, encoding: .utf8)
            let objectData = responseString!.data(using: String.Encoding.utf8)
            let json = try! JSONSerialization.jsonObject(with: objectData!, options: JSONSerialization.ReadingOptions.mutableContainers)
            let myjson = JSON(json)
            
            // count offence subdivision
            var chartDataSuburb = [String:Int]()
            for temp in (myjson.array)!{
                let key = temp["CSA Offence Subdivision"].string
                if(chartDataSuburb[key!] != nil) {
                    let old = chartDataSuburb[key!]
                    let new = old! + 1
                    chartDataSuburb[key!] = new
                } else {
                    chartDataSuburb[key!] = 1
                }
            }
            print(chartDataSuburb)
            print(chartDataSuburb.count)
        }
        task.resume()
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
