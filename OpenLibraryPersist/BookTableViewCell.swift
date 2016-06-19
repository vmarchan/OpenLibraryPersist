//
//  BookTableViewCell.swift
//  OpenLibraryTable
//
//  Created by Veronica Marchan on 5/6/16.
//  Copyright © 2016 vmarchan. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
