//
//  ViewController.swift
//  AllConnectRoute
//
//  Created by Isuru Nanayakkara on 7/31/15.
//  Copyright (c) 2015 BitInvent. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    private var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get current user location
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 10
        
        mapView.showsUserLocation = true
        
        // create event objects
        let event1 = Event(latitude: 33.856878, longitude: -118.030318)
        let event2 = Event(latitude: 33.8037266, longitude: -118.122265)
        let event3 = Event(latitude: 33.8084035, longitude: -118.0736853)
        events = [event1, event2, event3]
        
        // add annotations
        var annotations = [EventAnnotation]()
        for event in events {
            let eventAnnotation = EventAnnotation(coordinate: event.coordinates)
            annotations.append(eventAnnotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    private func getDirections(#fromLocationCoord: CLLocationCoordinate2D, toLocationCoord: CLLocationCoordinate2D) {
        let fromLocationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: fromLocationCoord, addressDictionary: nil))
        let toLocationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: toLocationCoord, addressDictionary: nil))
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.transportType = .Automobile
        directionsRequest.setSource(fromLocationMapItem)
        directionsRequest.setDestination(toLocationMapItem)
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculateDirectionsWithCompletionHandler { (directionsResponse, error) -> Void in
            if let error = error {
                println("Error getting directions: \(error.localizedDescription)")
            } else {
                let route = directionsResponse.routes[0] as! MKRoute
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.addOverlay(route.polyline)
            }
        }
    }
    
    private func focusMapViewToShowAllAnnotations() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // Don't add a custom image to the user location pin
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "EventLocationIdentifier"
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            view.annotation = annotation
        }
        return view
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5
        return renderer
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        focusMapViewToShowAllAnnotations()
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        focusMapViewToShowAllAnnotations()
        
        let event = events[1]
        getDirections(fromLocationCoord: userLocation.coordinate, toLocationCoord: event.coordinates)
    }
}