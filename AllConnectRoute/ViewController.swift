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
    
    let locationManager = CLLocationManager()
    var events = [Event]()
    var coordinates = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get current user location
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 10
        
        mapView.showsUserLocation = true
        
        // create event objects
        let event1 = Event(latitude: 46.3546803, longitude: -72.5837866)
        let event2 = Event(latitude: 45.5369442, longitude: -73.5107131)
        let event3 = Event(latitude: 45.6066487, longitude: -73.712409)
        events = [event1, event2, event3]
        
        // add annotations
        var annotations = [EventAnnotation]()
        for event in events {
            let eventAnnotation = EventAnnotation(coordinate: event.coordinates)
            annotations.append(eventAnnotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    fileprivate func getDirections(_ fromLocationCoord: CLLocationCoordinate2D, _ toLocationCoord: CLLocationCoordinate2D) {
        let fromLocationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: fromLocationCoord, addressDictionary: nil))
        let toLocationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: toLocationCoord, addressDictionary: nil))
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.transportType = .automobile
        directionsRequest.source = fromLocationMapItem
        directionsRequest.destination = toLocationMapItem
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (directionsResponse, error) -> Void in
            if let error = error {
                print("Error getting directions: \(error.localizedDescription)")
            } else {
                let route = directionsResponse?.routes[0] as! MKRoute
                self.mapView.add(route.polyline)
                
                let closestLocation = self.getClosestLocation(toLocationCoord, locations: self.coordinates)
                if let closest = closestLocation {
                    self.getDirections(toLocationCoord, closest)
                }
                
                self.coordinates = self.coordinates.filter({ $0 != toLocationCoord })
            }
        }
    }
    
    fileprivate func getClosestLocation(_ location: CLLocationCoordinate2D, locations: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        var closestLocation: (distance: Double, coordinates: CLLocationCoordinate2D)?
        
        for loc in locations {
            let distance = round(location.location.distance(from: loc.location)) as Double
            if closestLocation == nil {
                closestLocation = (distance, loc)
            } else {
                if distance < closestLocation!.distance {
                    closestLocation = (distance, loc)
                }
            }
        }
        return closestLocation?.coordinates
    }
    
    fileprivate func focusMapViewToShowAllAnnotations() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView!, viewFor annotation: MKAnnotation!) -> MKAnnotationView! {
        // Don't add a custom image to the user location pin
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "EventLocationIdentifier"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            view?.annotation = annotation
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5
        return renderer
    }
    
    @nonobjc func mapView(_ mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        focusMapViewToShowAllAnnotations()
    }
    
    func mapView(_ mapView: MKMapView!, didUpdate userLocation: MKUserLocation!) {
        focusMapViewToShowAllAnnotations()
        mapView.removeOverlays(mapView.overlays)
        
        coordinates = events.map({ $0.coordinates })
        let closestLocation = getClosestLocation(userLocation.coordinate, locations: coordinates)
        if let closest = closestLocation {
            getDirections(userLocation.coordinate, closest)
        }
    }
}
