//
//  SalesSearchViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 16/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class SalesSearchViewController: SiteTableViewController {

    private enum CellType {
        case Meta
        case ProductsHeading
        case Product
        case CustomerHeading
        case Customer
        case LicensesHeading
        case License
    }
    
    typealias JSON = SwiftyJSON.JSON
    
    private var cells = [CellType]()
    
    var site: Site?
    var sale: Sales!
    var products: [JSON]!
    var licenses: [JSON]?
    var customer: JSON?
    
    var filteredTableData = [JSON]()
    
    let searchController = SearchController(searchResultsController: nil)
    
    var loadingView = UIView()
    var noResultsView = UIView()
    
    init() {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        
        title = NSLocalizedString("Search", comment: "Sales Search View Controller title")
        tableView.scrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.userInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Search", comment: "Sales Search View Controller title"))
        navigationItem.titleView = titleLabel
        
        tableView.registerClass(SalesDetailMetaTableViewCell.self, forCellReuseIdentifier: "SalesDetailMetaTableViewCell")
        tableView.registerClass(SalesDetailHeadingTableViewCell.self, forCellReuseIdentifier: "SalesDetailHeadingTableViewCell")
        tableView.registerClass(SalesDetailProductTableViewCell.self, forCellReuseIdentifier: "SalesDetailProductTableViewCell")
        tableView.registerClass(SalesDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SalesDetailCustomerTableViewCell")
        tableView.registerClass(SalesDetailLicensesTableViewCell.self, forCellReuseIdentifier: "SalesDetailLicensesTableViewCell")
        
        cells = [.Meta, .ProductsHeading]
        
        loadingView = {
            var frame: CGRect = self.view.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            
            let view = UIView(frame: frame)
            view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            view.backgroundColor = .EDDGreyColor()
            
            return view
        }()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        activityIndicator.center = view.center
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = .EDDBlackColor()
        searchController.searchBar.backgroundColor = .EDDBlackColor()
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.tintColor = .whiteColor()
        searchController.searchBar.translucent = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("Enter Sale ID", comment: "")
        searchController.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        extendedLayoutIncludesOpaqueBars = true
        
        navigationController?.navigationBar.clipsToBounds = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        tableView.registerClass(SearchTableViewCell.self, forCellReuseIdentifier: "SearchCell")
        
        for view in searchController.searchBar.subviews {
            for field in view.subviews {
                if field.isKindOfClass(UITextField.self) {
                    let textField: UITextField = field as! UITextField
                    textField.backgroundColor = .blackColor()
                    textField.textColor = .whiteColor()
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.active = true
        dispatch_async(dispatch_get_main_queue()) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func showNoResultsView() {
        noResultsView = {
            var frame: CGRect = self.view.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            
            let view = UIView(frame: frame)
            view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            view.backgroundColor = .EDDGreyColor()
            
            return view
        }()
        
        let noResultsLabel = UILabel()
        noResultsLabel.text = NSLocalizedString("Sale Not Found.", comment: "")
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noResultsLabel.textAlignment = .Center
        noResultsLabel.sizeToFit()
        
        noResultsView.addSubview(noResultsLabel)
        view.addSubview(noResultsView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(noResultsLabel.widthAnchor.constraintEqualToAnchor(view.widthAnchor))
        constraints.append(noResultsLabel.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return cells.count
        } else {
            return 0
        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if cells[indexPath.row] == CellType.Customer {
            guard let item = customer else {
                return
            }
            let customerObject = Customer.objectForData(AppDelegate.sharedInstance.managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["user_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.dateFromString(item["info"]["date_created"].stringValue)!)
            navigationController?.pushViewController(CustomersDetailViewController(customer: customerObject), animated: true)
        }
        
        if cells[indexPath.row] == CellType.Product {
            let product: JSON = sale.products[indexPath.row - 2]
            let id = product["id"].int64Value
            
            if let product = Product.productForId(id) {
                navigationController?.pushViewController(ProductsDetailViewController(product: product), animated: true)
            } else {
                navigationController?.pushViewController(ProductsOfflineViewController(id: id), animated: true)
            }
        }
        
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
        case .Meta:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailMetaTableViewCell", forIndexPath: indexPath) as! SalesDetailMetaTableViewCell
            (cell as! SalesDetailMetaTableViewCell).configure(sale!)
        case .ProductsHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailHeadingTableViewCell", forIndexPath: indexPath) as! SalesDetailHeadingTableViewCell
            (cell as! SalesDetailHeadingTableViewCell).configure("Products")
        case .Product:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailProductTableViewCell", forIndexPath: indexPath) as! SalesDetailProductTableViewCell
            (cell as! SalesDetailProductTableViewCell).configure(sale.products[indexPath.row - 2])
        case .CustomerHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailHeadingTableViewCell", forIndexPath: indexPath) as! SalesDetailHeadingTableViewCell
            (cell as! SalesDetailHeadingTableViewCell).configure("Customer")
        case .Customer:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailCustomerTableViewCell", forIndexPath: indexPath) as! SalesDetailCustomerTableViewCell
            (cell as! SalesDetailCustomerTableViewCell).configure(customer)
        case .LicensesHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailHeadingTableViewCell", forIndexPath: indexPath) as! SalesDetailHeadingTableViewCell
            (cell as! SalesDetailHeadingTableViewCell).configure("Licenses")
        case .License:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailLicensesTableViewCell", forIndexPath: indexPath) as! SalesDetailLicensesTableViewCell
            (cell as! SalesDetailLicensesTableViewCell).configure(sale.licenses![indexPath.row - 5 - (products?.count)!])
        }
        
        return cell!
    }

}

extension SalesSearchViewController: UISearchControllerDelegate {
    
    // MARK: UISearchControllerDelegate
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
}

extension SalesSearchViewController: UISearchBarDelegate {
    
    // MARK: UISearchBar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.addSubview(loadingView)
        
        self.filteredTableData.removeAll(keepCapacity: false)
        
        let searchTerms = searchBar.text
        if searchTerms?.characters.count > 0 {
            let encodedSearchTerms = searchTerms!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            EDDAPIWrapper.sharedInstance.requestSales(["id" : encodedSearchTerms!], success: { (json) in
                if let items = json["sales"].array {
                    let item = items[0]
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadingView.removeFromSuperview()
                    })
                    if item["ID"].stringValue.characters.count == 0 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showNoResultsView()
                        })
                    } else {
                        let sale = Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array)
                        
                        self.sale = sale
                        
                        if sale.products!.count == 1 {
                            self.cells.append(.Product)
                        } else {
                            for _ in 1...sale.products!.count {
                                self.cells.append(.Product)
                            }
                        }
                        
                        if let items = sale.products {
                            self.products = [JSON]()
                            for item in items {
                                self.products.append(item)
                            }
                        }
                        
                        self.cells.append(.CustomerHeading)
                        self.cells.append(.Customer)
                        
                        if sale.licenses != nil {
                            self.cells.append(.LicensesHeading)
                            
                            if sale.licenses!.count == 1 {
                                self.cells.append(.License)
                            } else {
                                self.licenses = [JSON]()
                                for _ in 1...sale.licenses!.count {
                                    self.cells.append(.License)
                                }
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.noResultsView.removeFromSuperview()
                            self.tableView.reloadData()
                        })
                        
                        EDDAPIWrapper.sharedInstance.requestCustomers(["customer": sale.email], success: { json in
                            let items = json["customers"].arrayValue
                            self.customer = items[0]
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                    }
                }
                }, failure: { (error) in
                    print(error.localizedDescription)
            })
        }
    }
    
}
