//
//  MapViewController.swift
//  AdressMapUIKIT
//
//  Created by arnaud kiefer on 17/03/2022.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var childrenArray: [UIAction] = []
    var returnedPlacemark: MKPlacemark?
    var adressLabel: String?
    var userPosition: CLLocation?
    let locationManager = CLLocationManager()
    let defaultPosition = CLLocationCoordinate2D(latitude: 47.51035, longitude: 6.79846)

    @IBOutlet weak var ui_map: MKMapView!
    @IBOutlet weak var mapTypeSegmet: UISegmentedControl!
    @IBOutlet weak var button2: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        ui_map.showsUserLocation = true
        ui_map.delegate = self

        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        initMapRegion(coord: defaultPosition)
        addPoiToMap(coord: defaultPosition, poiTittle: "Montbéliard")
        setupMenu()
    }


    @IBAction func myPositionButtonTaped(_ sender: Any) {
        guard let myposition = userPosition?.coordinate else { return }
        initMapRegion(coord: myposition)
    }

    @IBAction func unwindToMap(segue:UIStoryboardSegue) {
        initMapRegion(coord: returnedPlacemark!.coordinate)
        addPoiToMap(coord: returnedPlacemark!.coordinate, poiTittle: returnedPlacemark!.title!)
        setupMenu()
    }

    @IBAction func ChangeMapTypeButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0 : ui_map.mapType = MKMapType.standard
        case 1 : ui_map.mapType = .satellite
        case 2 : ui_map.mapType = .hybrid
        default: break
        }
    }

    func setupMenu() {
        childrenArray = []
        let annot = ui_map.annotations
        for adress in annot {
            let new = UIAction(title: (adress.title ?? "")!, image: UIImage(systemName: "mappin.circle")) { _ in
                self.initMapRegion(coord: adress.coordinate)
            }
            childrenArray.append(new)
        }
        let menu = UIMenu(title: "Historique", children: childrenArray)
        button2.menu = menu
        button2.showsMenuAsPrimaryAction = true
    }

    func initMapRegion(coord: CLLocationCoordinate2D) {
        ui_map.setRegion(MKCoordinateRegion(center: coord , span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: false)
    }

    func addPoiToMap(coord: CLLocationCoordinate2D, poiTittle: String) {
        let poi = MKPointAnnotation()
        poi.coordinate = coord
        poi.title = poiTittle
        ui_map.addAnnotation(poi)
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if locations.count > 0 {
         if let maPosition = locations.last {
          userPosition = maPosition
         }
     }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading
         newHeading: CLHeading) {
        ui_map.camera.heading = newHeading.magneticHeading
        ui_map.setCamera(ui_map.camera, animated: true)
    }

}

