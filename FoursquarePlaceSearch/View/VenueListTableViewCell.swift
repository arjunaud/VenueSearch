//
//  VenueListTableViewCell.swift
//  FoursquarePlaceSearch
//
//  Created by arjuna on 10/09/22.
//

import UIKit

/**
    Venue table cell implementation. Takes VenueCellViewModel and displays it.
 */

class VenueListTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var categoriesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(viewModel: VenueCellViewModel) {
        self.nameLabel.text = viewModel.name
        self.addressLabel.text = viewModel.address
        self.categoriesLabel.text = viewModel.catogories
    }

}
