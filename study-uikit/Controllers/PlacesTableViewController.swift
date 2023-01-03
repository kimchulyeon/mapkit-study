import UIKit
import MapKit

class PlacesTableViewController: UITableViewController {
	//MARK: - Properties
	var userLocation: CLLocation
	let places: [PlaceAnnotations]
	
	init(userLocation: CLLocation, places: [PlaceAnnotations]) {
		self.userLocation = userLocation
		self.places = places
		super.init(nibName: nil, bundle: nil)

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
		let place = places[indexPath.row]
		
		// cell configuration
		var content = cell.defaultContentConfiguration()
		content.text = place.name
		content.secondaryText = formatDistance(calculateDistance(from: userLocation, to: place.location))
		
		cell.contentConfiguration = content
		
		return cell
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - function
	func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
		return to.distance(from: from)
	}
	
	func formatDistance(_ distance: CLLocationDistance) -> String {
		let meters = Measurement(value: distance, unit: UnitLength.meters)
		return meters.converted(to: .kilometers).formatted()
	}
}

