//
//  StoreCommissionsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class StoreCommissionsDetailViewController: SiteTableViewController {

    fileprivate enum CellType {
        case metaHeading
        case meta
    }
    
    fileprivate var cells = [CellType]()
    
    var site: Site?
    var commission: StoreCommissions?
    
    init(storeCommission: StoreCommissions) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.commission = storeCommission
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Store Commission", comment: ""))
        navigationItem.titleView = titleLabel
        
        cells = [.metaHeading, .meta]
        
        tableView.register(StoreCommissionsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "StoreCommissionsDetailHeadingTableViewCell")
        tableView.register(StoreCommissionsDetailMetaTableViewCell.self, forCellReuseIdentifier: "StoreCommissionsDetailMetaTableViewCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .metaHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "StoreCommissionsDetailHeadingTableViewCell", for: indexPath) as! StoreCommissionsDetailHeadingTableViewCell
                (cell as! StoreCommissionsDetailHeadingTableViewCell).configure("Meta")
            case .meta:
                cell = tableView.dequeueReusableCell(withIdentifier: "StoreCommissionsDetailMetaTableViewCell", for: indexPath) as! StoreCommissionsDetailMetaTableViewCell
                (cell as! StoreCommissionsDetailMetaTableViewCell).configure(commission!)
        }
        
        return cell!
    }

}
