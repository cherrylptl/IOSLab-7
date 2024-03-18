//
//  ViewController.swift
//  Lab 7
//
//  Created by user238103 on 3/10/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        MapView.delegate = self
    }

    @IBAction func StartTripButton(_ sender: Any) {
        
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
            MapView.showsUserLocation = true
            TripView.backgroundColor = UIColor.systemGreen
    }
    
    @IBAction func StopTripButton(_ sender: Any) {
        
        locationManager.stopUpdatingLocation()
        MapView.showsUserLocation = false
        TripView.backgroundColor = UIColor.systemGray
    }

    @IBOutlet weak var Distance: UILabel!
    @IBOutlet weak var CurrentSpeed: UILabel!
    @IBOutlet weak var MaxAcceleration: UILabel!
    @IBOutlet weak var MaxSpeed: UILabel!
    @IBOutlet weak var AverageSpeed: UILabel!
    @IBOutlet weak var ExceededView: UIView!
    @IBOutlet weak var TripView: UIView!
    @IBOutlet weak var MapView: MKMapView!
    
    var startLocation : CLLocation!
    var lastLocation : CLLocation!
    var traveledDistance : Double = 0
    var previousSpeed : Double = 0
    var maxAccelerationValue : Double = 0
    var previousTime : Date? = Date()
    var speedsArray:[Double] = []
    let locationManager : CLLocationManager = CLLocationManager()
    
    var distanceBeforeExceedingDisplayed = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations[0]

        manager.startUpdatingLocation()

        render(location)

        if startLocation == nil{

            startLocation = locations.first!
        }
        else{

            let lastLocation = locations.last!
            let distance = startLocation.distance(from: lastLocation)
            startLocation = lastLocation
            traveledDistance = traveledDistance + distance;
        }

    
    if (location.speed * 3.6) > 115 && !distanceBeforeExceedingDisplayed {
        
        //Display Distance Travel Before Exceeding the Speed
        print("Driver Travel Before Exceeding the Speed : \(round(traveledDistance * 100 / 1000) / 100.0) km")
        
        distanceBeforeExceedingDisplayed = true
    }
        //Displat Distance
        Distance.text = "\(round(traveledDistance*100/1000)/100.0) km"

        //Display Current Speed
        CurrentSpeed.text = "\(String(format: "%.2f", location.speed * 3.6)) km/h"

        speedsArray.append(location.speed*3.6)

        //Display Maximum Speed
        MaxSpeed.text = "\(String(format: "%.2f", speedsArray.max() ?? 0)) km/h"

        var totalSpeed : Double = 0.0

        speedsArray.forEach{ speed in
            totalSpeed = totalSpeed + speed
        }

        let avgSpeedMeasured = totalSpeed/Double(speedsArray.count)

        if(previousSpeed != 0){

            let speedDifference = location.speed - previousSpeed
            
            let timeDifference = Date().timeIntervalSince(previousTime!)
            
            let acceleration = speedDifference/timeDifference
           
            maxAccelerationValue =  max(acceleration, maxAccelerationValue)
            
            //Display MaxAcceleration
            MaxAcceleration.text = String (format : "%.3f", maxAccelerationValue) + " m/s^2"
        }

        previousSpeed = location.speed

        previousTime = Date()

        //Display Average Speed
        AverageSpeed.text = "\(String(format: "%.2f", avgSpeedMeasured)) km/h"

        ExceededView.backgroundColor = (location.speed * 3.6) > 115 ? UIColor.red : UIColor.white

    }


    
    func render (_ location: CLLocation) {

           let coordinate = CLLocationCoordinate2D (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude )

           let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta:0.05)

           let region = MKCoordinateRegion(center: coordinate, span: span)

           let pin = MKPointAnnotation ()

           pin.coordinate = coordinate

           MapView.addAnnotation(pin)

           MapView.setRegion(region, animated: true)

       }
}

