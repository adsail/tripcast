//
//  ViewController.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/11/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIViewControllerTransitioningDelegate {
    
    private let accuWeatherBaseURL = "http://dataservice.accuweather.com/forecasts/v1/hourly/12hour/"
    private let accuWeatherLocationBaseURL = "http://dataservice.accuweather.com/locations/v1/cities/geoposition/search"
    private let accuWeatherAPIKey = "CnDXl19fMm5TA4wgY5nGIltOzJ3DzOdb"

    let tripCastModel = TripCastModel.sharedInstance
    
    var meterageCounter: Double = 0
    
    var ETA: Double = 0
    var intETA: Int = 0
    let twelveHours = 43200
    let maxHours = 350000
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var tripDetailButton: UIBarButtonItem!
    @IBOutlet weak var clearMapButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
   
    @IBAction func clearMapButtonPressed(sender: AnyObject) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        tripCastModel.locations.removeAll()
        clearMapButton.enabled = false
        tripDetailButton.enabled = false
        tripCastModel.origin = nil
        tripCastModel.destination = nil
    }
    
    @IBAction func detailButtonPressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let routeDetailViewController = storyboard.instantiateViewControllerWithIdentifier("routeDetailView") as! RouteDetailViewController
        
        routeDetailViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        routeDetailViewController.transitioningDelegate = self
        routeDetailViewController.view.alpha = 0.9
        
        UIView.animateWithDuration(0.5) {
            self.view.alpha = 0.5
            self.navigationController?.navigationBar.alpha = 0.8
        }
        
        presentViewController(routeDetailViewController, animated: true, completion: nil)
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let settingsViewController = storyboard.instantiateViewControllerWithIdentifier("settingsView") as! SettingsViewController
        
        settingsViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        settingsViewController.transitioningDelegate = self
        settingsViewController.view.alpha = 0.9
        
        UIView.animateWithDuration(0.5) {
            self.view.alpha = 0.5
            self.navigationController?.navigationBar.alpha = 0.8
        }
        
        presentViewController(settingsViewController, animated: true, completion: nil)
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return HalfPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func configureMapView() {
        mapView.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            let prefs = NSUserDefaults.standardUserDefaults()

            if prefs.boolForKey(UserDefaults.showUserLocation) {
                mapView.showsUserLocation = true
                locationManager.startUpdatingLocation()
            }
        }
        else {
            mapView.showsUserLocation = false
            locationManager.stopUpdatingLocation()
        }
    }
    
    func getDirections() {
        let drivingRouteRequest = MKDirectionsRequest()
        
        drivingRouteRequest.source = tripCastModel.origin.mapItem()
        drivingRouteRequest.destination = tripCastModel.destination.mapItem()
        drivingRouteRequest.transportType = .Automobile
        drivingRouteRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: drivingRouteRequest)
        
        directions.calculateDirectionsWithCompletionHandler { (response, error) in
            if error != nil {
                assert(false, "Error getting directions.")
            } else {
                let twelveHoursPastDeparture = self.twelveHours + Int(self.tripCastModel.departureTime)
                
                let etaToDestination = Int(self.tripCastModel.departureTime) + Int((response?.routes.first!.expectedTravelTime)!)
                
                dispatch_async(GCD.MainQueue) {
                    self.location(self.tripCastModel.origin, estimatedTimeOfArrival: Int(self.tripCastModel.departureTime))
                    
                    // If-else is necessary since weather API only returns 12 hours of weather forecasts.
                    // If departure time + travel time > 12 hours from now, goes to else.
                    if etaToDestination < twelveHoursPastDeparture {
                        self.location(self.tripCastModel.destination, estimatedTimeOfArrival: etaToDestination)
                    }
                    else {
                        self.lastHourLocation(self.tripCastModel.destination)
                    }
                }
                self.showDirections(response!)
            }
        }
    }
    
    func showDirections(response: MKDirectionsResponse) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        tripCastModel.locations.removeAll()
        
        let route = response.routes.first!
        let twelveHoursPastDeparture = 43200 + Int(self.tripCastModel.departureTime)
    
        mapView.addOverlay(route.polyline)
        
        tripCastModel.locations.append(tripCastModel.origin)
        
        for step in route.steps {
            meterageCounter = meterageCounter + step.distance
            
            // Waypoint roughly every 20 miles. This is the best that can be done with Apple Maps.
            if meterageCounter >= 30000 {
                let myLocation: Location = Location(coordinate: step.polyline.coordinate)
                
                let drivingRouteRequest = MKDirectionsRequest()
                
                drivingRouteRequest.source = tripCastModel.origin.mapItem()
                drivingRouteRequest.destination = myLocation.mapItem()
                drivingRouteRequest.transportType = .Automobile
                drivingRouteRequest.requestsAlternateRoutes = false
                
                let directions = MKDirections(request: drivingRouteRequest)
                
                directions.calculateETAWithCompletionHandler({ (response, error) in
                    if error != nil {
                        assert(false, "Error getting directions.")
                    }
                    else {
                        self.ETA = self.tripCastModel.departureTime + (response?.expectedTravelTime)!
                            
                        self.ETA = round(self.ETA)
                        self.intETA = Int(self.ETA)
                        
                        myLocation.epochETA = self.intETA
                        
                        
                        // Same situation as for the desintation annotation, but instead for each waypoint.
                        if self.intETA < twelveHoursPastDeparture {
                            self.location(myLocation, estimatedTimeOfArrival: self.intETA)
                        }
                        else {
                            self.lastHourLocation(myLocation)
                        }
                        self.tripCastModel.locations.append(myLocation)
                    }
                })
                self.meterageCounter = 0
            }
        }
        
        // Since Apple Maps doesn't allow simply placing waypoints on an interval, sometimes, waypoint annotations were very close
        // to the destination annotation. This was showing the waypoints out of order on the trip details table after sorting
        // so this ensures the destination annotation is at the very end. epochETA value is used solely for the table so this has
        // no implications.
        tripCastModel.destination.epochETA = Int(NSDate().timeIntervalSince1970) + maxHours
        tripCastModel.locations.append(tripCastModel.destination)

        clearMapButton.enabled = true
        tripDetailButton.enabled = true
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 2.0
            
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if let annotation = annotation as? Location {
            
            let identifier = "droppedPin"
            let view: MKAnnotationView
        
            
            if let dequedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) {
                dequedView.annotation = annotation
                view = dequedView
                view.canShowCallout = true
            }
            else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
            }

            if annotation.weatherIcon != nil {
                view.image = UIImage(named: String(annotation.weatherIcon!))
            }

            let infoPinButton = UIButton(type: .InfoLight)
            infoPinButton.addTarget(self, action: #selector(ViewController.showWaypointDetails(_:)), forControlEvents: .TouchUpInside)
            view.leftCalloutAccessoryView = infoPinButton as UIView
            
            return view
        }
        return nil
    }

    // MARK: - Segue
    //
    //
    @IBAction func unwindMe(segue:UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        switch segue.identifier! {
        case "UnwindSettings":
            UIView.animateWithDuration(0.5) {
                self.view.alpha = 1.0
                self.navigationController?.navigationBar.alpha = 1.0
            }
            updateSettings()
        case "UnwindRouteDetails":
            UIView.animateWithDuration(0.5) {
                self.view.alpha = 1.0
                self.navigationController?.navigationBar.alpha = 1.0
            }
        case "UnwindTripConfig":
            getDirections()
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "ShowFavoritesTable":
            let destination = segue.destinationViewController as! FavoritesTableViewController
            destination.mapView = mapView
        case "ShowDirections":
            let destination = segue.destinationViewController as! OriginViewController
            destination.mapView = mapView
        case "ShowWaypointDetails":
            let destination = segue.destinationViewController as! WaypointDetailViewController
            destination.waypoint = mapView.selectedAnnotations.first as? Location

        default:
            break
        }
    }
    
    func showWaypointDetails(button: UIButton) {
        performSegueWithIdentifier("ShowWaypointDetails", sender: self)
    }
    
    //MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSettings()
        
        clearMapButton.enabled = false
        tripDetailButton.enabled = false
        configureLocationManager()
        configureMapView()
        
        mapView.delegate = self
    }
    
    func updateSettings() {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        let mapType = prefs.integerForKey(UserDefaults.mapType)
        let locationSwitch = prefs.boolForKey(UserDefaults.showUserLocation)
        let trafficSwitch = prefs.boolForKey(UserDefaults.showTraffic)
        
        if mapType == 0 {
            mapView.mapType = .Standard
        }
        else if mapType == 1 {
            mapView.mapType = .Satellite
        }
        else if mapType == 2 {
            mapView.mapType = .Hybrid
        }
        
        if locationSwitch {
            mapView.showsUserLocation = true
        }
        else {
            mapView.showsUserLocation = false
        }
        
        if trafficSwitch {
            mapView.showsTraffic = true
        }
        else {
            mapView.showsTraffic = false
        }
    }

    override func viewDidAppear(animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func location(location: Location, estimatedTimeOfArrival: Int) {
        let session = NSURLSession.sharedSession()
        
        let searchCoordinate: String = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        let locationRequestURL = NSURL(string: "\(accuWeatherLocationBaseURL)?apikey=\(accuWeatherAPIKey)&q=\(searchCoordinate)&toplevel=true")!
        
        let dataTask = session.dataTaskWithURL(locationRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                // Case 1: Error
                print(error.localizedDescription)
            }
            else {
                // Case 2: Success
                do {
                    let locationData = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! [String: AnyObject]
                    
                    location.city = locationData["EnglishName"] as? String
                    location.state = locationData["AdministrativeArea"]!["EnglishName"] as? String
                    location.stateID = locationData["AdministrativeArea"]!["ID"] as? String
                    location.title = "\(location.city!), \(location.stateID!)"

                    if let locationKey = locationData["Key"]! as? String {
                        //GET WEATHER DATA
                        let weatherRequestURL = NSURL(string: "\(self.accuWeatherBaseURL)\(locationKey)?apikey=\(self.accuWeatherAPIKey)")!
                        
                        let weatherDataTask = session.dataTaskWithURL(weatherRequestURL) {
                            (data: NSData?, response: NSURLResponse?, error: NSError?) in
                            if let error = error {
                                // Case 1: Error
                                print(error.localizedDescription)
                            }
                            else {
                                // Case 2: Success
                                do {
                                    let weatherDataArray = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! [[String: AnyObject]]
                                    
                                    
                                    // For loop logic did not seem to plot origin consistently. This if/else is the workaround to ensure the origin annotation is always displayed.
                                    if location == self.tripCastModel.origin {
                                        let data = weatherDataArray[self.tripCastModel.hourDelay]
                                        dispatch_async(GCD.MainQueue, {
                                            location.epochTimestamp = data["EpochDateTime"] as? Int
                                            location.iconPhrase = data["IconPhrase"] as? String
                                            location.preciptationProbability = data["PrecipitationProbability"] as? Int
                                            location.weatherIcon = data["WeatherIcon"] as? Int
                                            location.temperature = data["Temperature"]!["Value"] as? Int
                                            
                                            self.mapView.addAnnotation(location)
                                        })
                                    }
                                    else {
                                        for data in weatherDataArray {
                                            let time = data["EpochDateTime"] as! Int
                                            
                                            if abs(estimatedTimeOfArrival - time) < 1801 {
                                                dispatch_async(GCD.MainQueue, {
                                                    location.epochTimestamp = data["EpochDateTime"] as? Int
                                                    location.iconPhrase = data["IconPhrase"] as? String
                                                    location.preciptationProbability = data["PrecipitationProbability"] as? Int
                                                    location.weatherIcon = data["WeatherIcon"] as? Int
                                                    location.temperature = data["Temperature"]!["Value"] as? Int

                                                    self.mapView.addAnnotation(location)
                                                })
                                            }

                                        }
                                    }
                                    
                                    // Called for each waypoint, map re-zooms as annotations are plotted... looks more fluid.
                                    dispatch_async(GCD.MainQueue, {
                                        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                                    })
                                }
                                catch {
                                    print("Error: \(error)")
                                }
                            }
                        }
                        weatherDataTask.resume()
                        //END WEATHER DATA
                    }
                }
                catch {
                    print("Error: \(error)")
                }
            }
        }
        dataTask.resume()
    }
    
    func lastHourLocation(location: Location) {
        let session = NSURLSession.sharedSession()
        
        let searchCoordinate: String = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        let locationRequestURL = NSURL(string: "\(accuWeatherLocationBaseURL)?apikey=\(accuWeatherAPIKey)&q=\(searchCoordinate)&toplevel=true")!
        
        let dataTask = session.dataTaskWithURL(locationRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                // Case 1: Error
                print(error.localizedDescription)
            }
            else {
                // Case 2: Success
                do {
                    let locationData = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! [String: AnyObject]
                    
                    location.city = locationData["EnglishName"] as? String
                    location.state = locationData["AdministrativeArea"]!["EnglishName"] as? String
                    location.stateID = locationData["AdministrativeArea"]!["ID"] as? String
                    location.title = "\(location.city!), \(location.stateID!)"
                    
                    if let locationKey = locationData["Key"]! as? String {
                        //GET WEATHER DATA
                        let weatherRequestURL = NSURL(string: "\(self.accuWeatherBaseURL)\(locationKey)?apikey=\(self.accuWeatherAPIKey)")!
                        
                        let weatherDataTask = session.dataTaskWithURL(weatherRequestURL) {
                            (data: NSData?, response: NSURLResponse?, error: NSError?) in
                            if let error = error {
                                // Case 1: Error
                                print(error.localizedDescription)
                            }
                            else {
                                // Case 2: Success
                                do {
                                    let weatherDataArray = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! [[String: AnyObject]]
                                    
                                    if let data = weatherDataArray.last {
                                        dispatch_async(GCD.MainQueue, {
                                            location.epochTimestamp = data["EpochDateTime"] as? Int
                                            location.iconPhrase = data["IconPhrase"] as? String
                                            location.preciptationProbability = data["PrecipitationProbability"] as? Int
                                            location.weatherIcon = data["WeatherIcon"] as? Int
                                            location.temperature = data["Temperature"]!["Value"] as? Int
                                        
                                            self.mapView.addAnnotation(location)
                                        })
                                    }
                                    
                                    dispatch_async(GCD.MainQueue, {
                                        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                                    })
                                }
                                catch {
                                    print("Error: \(error)")
                                }
                            }
                        }
                        weatherDataTask.resume()
                        //END WEATHER DATA
                    }
                }
                catch {
                    print("Error: \(error)")
                }
            }
        }
        dataTask.resume()
    }
}


