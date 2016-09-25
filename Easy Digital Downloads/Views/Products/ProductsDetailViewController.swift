//
//  ProductsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 23/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class ProductsDetailViewController: SiteTableViewController {

    private enum CellType {
        case InfoHeading
        case Info
        case StatsHeading
        case Stats
        case PricingHeading
        case Pricing
        case NotesHeading
        case Notes
        case FilesHeading
        case Files
        case LicensingHeading
        case Licensing
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var product: Product?
    var fetchedProduct: [JSON]?
    
    init(product: Product) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.product = product
        
        title = product.title
        
        view.backgroundColor = .EDDGreyColor()
        
        networkOperations()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(ProductsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "ProductHeadingTableViewCell")
        tableView.registerClass(ProductsDetailInfoTableViewCell.self, forCellReuseIdentifier: "ProductInfoTableViewCell")
        tableView.registerClass(ProductsDetailStatsTableViewCell.self, forCellReuseIdentifier: "ProductStatsTableViewCell")
        tableView.registerClass(ProductsDetailPricingTableViewCell.self, forCellReuseIdentifier: "ProductPricingTableViewCell")
        tableView.registerClass(ProductsDetailLicensingTableViewCell.self, forCellReuseIdentifier: "ProductLicensingTableViewCell")
        tableView.registerClass(ProductsDetailFilesTableViewCell.self, forCellReuseIdentifier: "ProductFilesTableViwCell")
        
        cells = [.InfoHeading, .Info, .StatsHeading, .Stats, .PricingHeading, .Pricing]
        
        if product.files != nil {
            cells.append(.FilesHeading)
            cells.append(.Files)
        }
        
        if product.notes?.characters.count > 0 {
            cells.append(.NotesHeading)
            cells.append(.Notes)
        }
        
        if product.licensing != nil {
            cells.append(.LicensingHeading)
            cells.append(.Licensing)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    private func networkOperations() {
        guard product != nil else {
            return
        }
        
        EDDAPIWrapper.sharedInstance.requestProducts(["product": "\(product!.pid)"], success: { (json) in
            if let items = json["products"].array {
                self.fetchedProduct = items
            }
            }) { (error) in
                fatalError()
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch(cells[indexPath.row]) {
            case .InfoHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
                (cell as! ProductsDetailHeadingTableViewCell).configure("Info")
            case .Info:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductInfoTableViewCell", forIndexPath: indexPath) as! ProductsDetailInfoTableViewCell
                (cell as! ProductsDetailInfoTableViewCell).configure(product!)
            case .StatsHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
                (cell as! ProductsDetailHeadingTableViewCell).configure("Stats")
            case .Stats:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductStatsTableViewCell", forIndexPath: indexPath) as! ProductsDetailStatsTableViewCell
                (cell as! ProductsDetailStatsTableViewCell).configure(product?.stats)
            case .PricingHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
                (cell as! ProductsDetailHeadingTableViewCell).configure("Pricing")
            case .Pricing:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductPricingTableViewCell", forIndexPath: indexPath) as! ProductsDetailPricingTableViewCell
                (cell as! ProductsDetailPricingTableViewCell).configure((product?.hasVariablePricing.boolValue)!, pricing: product!.pricing)
            case .LicensingHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
                (cell as! ProductsDetailHeadingTableViewCell).configure("Licensing")
            case .Licensing:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductLicensingTableViewCell", forIndexPath: indexPath) as! ProductsDetailLicensingTableViewCell
                (cell as! ProductsDetailLicensingTableViewCell).configure(product!.licensing!)
            case .FilesHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
                (cell as! ProductsDetailHeadingTableViewCell).configure("Files")
            case .Files:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductFilesTableViwCell", forIndexPath: indexPath) as! ProductsDetailFilesTableViewCell
                (cell as! ProductsDetailFilesTableViewCell).configure(product!.files!)
            case .NotesHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
                (cell as! ProductsDetailHeadingTableViewCell).configure("Notes")
            case .Notes:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductLicensingTableViewCell", forIndexPath: indexPath) as! ProductsDetailLicensingTableViewCell
                (cell as! ProductsDetailLicensingTableViewCell).configure(product!.licensing!)
        }
        
        return cell!
    }
    
}