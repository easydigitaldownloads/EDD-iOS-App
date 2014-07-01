//
//  SalesViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/8/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "SalesViewController.h"

#import "EDDSalesSearchViewController.h"
#import "Sale.h"
#import "SaleCell.h"
#import "SaleDetailViewController.h"
#import "SVProgressHUD.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

const int kSalesLoadingCellTag = 1273;

@interface SalesViewController ()

- (void)refresh:(id)sender;
- (void)reload:(id)sender;

@property (nonatomic, retain) NSMutableArray *sales;

@end

@implementation SalesViewController

@synthesize sales = _sales;

#pragma mark - UIView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sales = [NSMutableArray array];
	
    _currentPage = 0;
	_totalPages = 99;
    
    self.title = NSLocalizedString(@"Sales", nil);
    
    [self setupRightBarButtonItems];
    
	[self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
	
    [self.tableView registerNib:[UINib nibWithNibName:@"SaleCell" bundle:nil] forCellReuseIdentifier:@"SaleCell"];
	   
    [self reload:nil];
}

- (void)setupRightBarButtonItems {
    self.refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    
    self.navigationItem.rightBarButtonItems = @[ search, self.refresh ];
}

#pragma mark - API

- (void)refresh:(id)sender {
	_currentPage = 0;
	_totalPages = 99;
	
	self.sales = [NSMutableArray array];
	
	[self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
	[self.tableView reloadData];
}

- (void)reload:(id)sender {
	if (_currentPage == 0) return;
	
	[SVProgressHUD showWithStatus:@"Loading Sales..." maskType:SVProgressHUDMaskTypeClear];
    self.refresh.enabled = NO;
    
    [Sale globalSalesWithPage:_currentPage andWithBlock:^(NSArray *sales, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
			if ([sales count] != PAGING_RETURN) {
				_totalPages = _currentPage;
			}
			
			for (Sale *sale in sales) {
				if (![self.sales containsObject:sale]) {
					[self.sales addObject:sale];
				}
			}
            [self.tableView reloadData];
        }
		[SVProgressHUD dismiss];
        self.refresh.enabled = YES;
    }];
}

#pragma mark - Navigation

- (void)search:(id)sender {
    EDDSalesSearchViewController *searchViewController = [[EDDSalesSearchViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_currentPage == 0) {
        return 1;
	}
    
    if (_currentPage < _totalPages) {
        return [self.sales count] + 1;
    }
	
	return [self.sales count];
}

- (UITableViewCell *)saleCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SaleCell";
    SaleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (!cell) {
        cell = [[SaleCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:cellIdentifier];
    }
    
	Sale *sale = [self.sales objectAtIndex:indexPath.row];
	[cell initializeSale:sale];
    
    return cell;
}

- (UITableViewCell *)loadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
													reuseIdentifier:nil];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.center;
    [cell addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    cell.tag = kSalesLoadingCellTag;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.sales.count) {
        return [self saleCellForIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kSalesLoadingCellTag) {
        _currentPage++;
        [self reload:nil];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	Sale *sale = [self.sales objectAtIndex:indexPath.row];
	SaleDetailViewController *detailViewController = [[SaleDetailViewController alloc] initWithSale:sale];
	
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] init];
}

@end
