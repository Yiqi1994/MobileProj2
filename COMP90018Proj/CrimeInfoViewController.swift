//
//  CrimeInfoViewController.swift
//  COMP90018Proj Front-End Application
//
//  Created by Kai Zhang, Yiqi Yu, Lisha Qiu
//  Copyright © 2017 Unimelb. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import PieCharts
import SwiftyJSON

class CrimeInfoViewController: UIViewController, CLLocationManagerDelegate,PieChartDelegate {
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicator1: UIActivityIndicatorView!
    @IBOutlet weak var pieChartView: PieChart!
    @IBOutlet weak var pieChartViewA: PieChart!
    @IBOutlet weak var mapView: MKMapView!

    var locationManager: CLLocationManager!
    // provide a initial postcode to exam location change
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

        // set location detail
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
            var chartDataSuburb = [String:Double]()
            for temp in (myjson.array)!{
                let key = temp["CSA Offence Division"].string
                if(chartDataSuburb[key!] != nil) {
                    let old = chartDataSuburb[key!]
                    let new = old! + Double(temp["Offence Count"].string!)!
                    chartDataSuburb[key!] = new
                } else {
                    chartDataSuburb[key!] = Double(temp["Offence Count"].string!)!
                }
            }
            print(chartDataSuburb)
            print(chartDataSuburb.count)

            self.pieChartView.models = self.createModels1(dic: chartDataSuburb)
            self.pieChartViewA.models = self.createModels()
        }
        task.resume()
    }


    override func viewDidAppear(_ animated: Bool) {
        // add charts to view
        pieChartView.layers = [createCustomViewsLayer(), createTextLayer()]
        pieChartView.delegate = self
        pieChartViewA.layers = [createCustomViewsLayer(), createTextLayer()]
        pieChartViewA.delegate = self
    }

    // create chart data model for current location
    fileprivate func createModels1(dic: Dictionary<String, Double>) -> [PieSliceModel] {
        let alpha: CGFloat = 0.5

        return [
            PieSliceModel(value: dic["A Crimes against the person"]!, color: UIColor.yellow.withAlphaComponent(alpha)),
            PieSliceModel(value: dic["B Property and deception offences"]!, color: UIColor.blue.withAlphaComponent(alpha)),
            PieSliceModel(value: dic["C Drug offences"]!, color: UIColor.green.withAlphaComponent(alpha)),
            PieSliceModel(value: dic["D Public order and security offences"]!, color: UIColor.cyan.withAlphaComponent(alpha)),
            PieSliceModel(value: dic["E Justice procedures offences"]!, color: UIColor.red.withAlphaComponent(alpha)),
            PieSliceModel(value: dic["F Other offences"]!, color: UIColor.magenta.withAlphaComponent(alpha)),
        ]
    }

    // create chart data model for average location. These information is already known
    fileprivate func createModels() -> [PieSliceModel] {
        let alpha: CGFloat = 0.5

        return [
            PieSliceModel(value: 115.9, color: UIColor.yellow.withAlphaComponent(alpha)),
            PieSliceModel(value: 471.2, color: UIColor.blue.withAlphaComponent(alpha)),
            PieSliceModel(value: 44.9, color: UIColor.green.withAlphaComponent(alpha)),
            PieSliceModel(value: 51.8, color: UIColor.cyan.withAlphaComponent(alpha)),
            PieSliceModel(value: 102.5, color: UIColor.red.withAlphaComponent(alpha)),
            PieSliceModel(value: 2.6, color: UIColor.magenta.withAlphaComponent(alpha)),
        ]

    }

    // create chart view layer
    fileprivate func createCustomViewsLayer() -> PieCustomViewsLayer {
        let viewLayer = PieCustomViewsLayer()

        let settings = PieCustomViewsLayerSettings()
        settings.viewRadius = 135
        settings.hideOnOverflow = false
        viewLayer.settings = settings

        viewLayer.viewGenerator = createViewGenerator()

        return viewLayer
    }

    // create chart text layer
    fileprivate func createTextLayer() -> PiePlainTextLayer {
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 60
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 12)

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        textLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.percentage * 100 as NSNumber).map{"\($0)%"} ?? ""
        }

        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }

    // create chart view
    fileprivate func createViewGenerator() -> (PieSlice, CGPoint) -> UIView {
        return {slice, center in

            let container = UIView()
            container.frame.size = CGSize(width: 100, height: 40)
            container.center = center
            let view = UIImageView()
            view.frame = CGRect(x: 30, y: 0, width: 40, height: 40)
            container.addSubview(view)

            if slice.data.id == 3 || slice.data.id == 0 {
                let specialTextLabel = UILabel()
                specialTextLabel.textAlignment = .center
                if slice.data.id == 0 {
                    specialTextLabel.text = " "
                    specialTextLabel.font = UIFont.boldSystemFont(ofSize: 18)
                } else if slice.data.id == 3 {
                    specialTextLabel.textColor = UIColor.white
                    specialTextLabel.text = " "
                }
                specialTextLabel.sizeToFit()
                specialTextLabel.frame = CGRect(x: 0, y: 40, width: 100, height: 20)
                container.addSubview(specialTextLabel)
                container.frame.size = CGSize(width: 100, height: 60)
            }
            return container
        }
    }

    // print slice infor when user click it
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected:\(selected),slice:\(slice)")
    }

}
