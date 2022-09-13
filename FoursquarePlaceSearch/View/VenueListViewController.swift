//
//  ViewController.swift
//  FoursquarePlaceSearch
//
//  Created by arjuna on 07/09/22.
//

import UIKit
import CoreLocation
import MapKit
/**
 View Controller to manage venue list view.
 */

class VenueListViewController: UIViewController {
    
    let venueDataService: VenueDataServiceProtocol = VenueDataService()
    private var viewModel: VenueListViewModel!
    @IBOutlet weak var venueListTableView: UITableView!
    @IBOutlet weak var noVenuesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
        self.viewModel = VenueListViewModel(delegate: self)
        self.viewModel.viewDidLoad()
    }
    
    func setupUI() {
        self.navigationItem.title = "Venues"
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(onRefreshButtonTap))
        let radiusButton = UIBarButtonItem(image: UIImage(named: "radius"), style: .plain, target: self, action: #selector(onRadiusButtonTap))

        self.navigationItem.rightBarButtonItems = [refreshButton, radiusButton]
        if #available(iOS 15, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                navigationController?.navigationBar.standardAppearance = appearance;
                navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }
        self.venueListTableView.estimatedRowHeight = 200
        self.venueListTableView.rowHeight = UITableView.automaticDimension
    }
    
    @objc func onRefreshButtonTap() {
        self.viewModel.refresh()
    }
    
    @objc func onRadiusButtonTap() {
        self.viewModel.radiusSelectionTapped()
    }
    
}

extension VenueListViewController: VenueListViewModelDelegateProtocol {
    func showLoadingIndicator() {
        self.activityIndicator.startAnimating()
    }
    
    func stopLoadingIndicator() {
        self.activityIndicator.stopAnimating()
    }
    
    func reloadData() {
        self.venueListTableView.reloadData()
    }
    
    func showErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func showRadiusSelectionUI(title: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.viewModel.setRadius(radiusString: alert.textFields?.first?.text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func showNoVenuesLabel(text: String)
    {
        self.noVenuesLabel.text = text
        self.noVenuesLabel.isHidden = false
    }
    
    func hideNoVeunuesLabel() {
        self.noVenuesLabel.isHidden = true
    }

    func openLocationInMaps(location: CLLocationCoordinate2D, locationName: String) {
//        let placemark = MKPlacemark(coordinate: location)
//        let mapItem = MKMapItem(placemark: placemark)
//        mapItem.name = locationName
//        let options = [
//            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: location)
//               ]
//        mapItem.openInMaps(launchOptions: options)

        // Google Map start
        
//        var locationURLString = "http://maps.google.com/maps?q=\(location.latitude),\(location.longitude)"
//        locationURLString = locationURLString.replacingOccurrences(of: " ", with: "+")
//
//        let locationURL = URL.init(string: locationURLString)
//        UIApplication.shared.open(locationURL!)
         
        //Google Map end
    }

}

extension VenueListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.venueCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let venueListCell = tableView.dequeueReusableCell(withIdentifier: "VenueListTableViewCell", for: indexPath) as! VenueListTableViewCell
        venueListCell.configure(viewModel: self.viewModel.venueCellModelForRow(row: indexPath.row))
        return venueListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.viewModel.venueCount - 1 {
            self.viewModel.fetchMoreVenuesIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.venueCellModelForRow(row: indexPath.row).tapHandler()
    }
}
