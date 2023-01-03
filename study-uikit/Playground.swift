import UIKit
import MapKit

class Playground: UIViewController {
	private let mapView: MKMapView = {
		let map = MKMapView()
		map.translatesAutoresizingMaskIntoConstraints = false
		map.userTrackingMode = .follow
		map.showsUserLocation = true
		return map
	}()
	private lazy var searchTextField: UITextField = {
		let tf = UITextField()
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.delegate = self
		tf.layer.cornerRadius = 15
		tf.textColor = UIColor.black
		tf.clipsToBounds = true
		tf.backgroundColor = UIColor.white
		tf.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.foregroundColor: UIColor.gray])
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
		tf.leftViewMode = .always
		return tf
	}()
	var locationManager: CLLocationManager?

	override func viewDidLoad() {
		super.viewDidLoad()

		configureUI()
		configureLocationManager()
	}

	//MARK: - function
	func configureUI() {
		view.addSubview(searchTextField)
		view.addSubview(mapView)

		view.bringSubviewToFront(searchTextField)

		// search text field
		NSLayoutConstraint.activate([
			searchTextField.heightAnchor.constraint(equalToConstant: 44),
			searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 1.2),
			searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60)
		])
		// map view
		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
		])
	}

	/**
	 requestLocation() -> setRegion() -> MKLocationSearch.Request().region
	 */
	func configureLocationManager() {
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.requestWhenInUseAuthorization()
		locationManager?.requestAlwaysAuthorization()
		locationManager?.requestLocation()
	}

	func checkLocationAuthorization() {
		guard let locationManager = locationManager, let location = locationManager.location else { return }

		switch locationManager.authorizationStatus {
		case .notDetermined, .restricted:
			print("not")
		case .denied:
			print("denied")
		case .authorizedAlways, .authorizedWhenInUse:
			let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
			mapView.setRegion(region, animated: true)
		default:
			break
		}
	}

	func findNearbyPlaces(by searchInputText: String) {
		mapView.removeAnnotations(mapView.annotations)

		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = searchInputText
		request.region = mapView.region

		let search = MKLocalSearch(request: request)
		search.start { [weak self] res, err in
			guard let res = res, err == nil else { return }
			let places = res.mapItems.map(PlaceAnnotations.init)
			places.forEach { place in
				self?.mapView.addAnnotation(place)
			}
			
			self?.presentPlacesTable(places: places)
		}

//		let search = MKLocalSearch(request: request)
//		search.start { [weak self] res, err in
//			guard let res = res, err == nil else { return }
//			let places = res.mapItems
//			places.forEach { place in
//				let annotation = MKPointAnnotation()
//				annotation.coordinate = place.placemark.coordinate
//				annotation.title = place.name
//				annotation.subtitle = place.phoneNumber
//				self?.mapView.addAnnotation(annotation)
//			}
//		}
	}
	
	func presentPlacesTable(places: [PlaceAnnotations]) {
		guard let locationManager = locationManager, let userLocation = locationManager.location else { return }
		
		let placeTVC = PlacesTableViewController(userLocation: userLocation, places: places)
		placeTVC.modalPresentationStyle = .pageSheet
		
		if let sheet = placeTVC.sheetPresentationController {
			sheet.prefersGrabberVisible = true
			sheet.detents = [.medium(), .large()]
			
			present(placeTVC, animated: true)
		}
	}
}

//MARK: - location manager 델리게이트
extension Playground: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		checkLocationAuthorization()
	}
}

//MARK: - text field 델리게이트
extension Playground: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let text = searchTextField.text else { return false }
		textField.resignFirstResponder()
		findNearbyPlaces(by: text)
		return true
	}
}

