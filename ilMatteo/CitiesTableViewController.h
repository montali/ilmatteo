//
//  CitiesTableViewController.h
//  ilMatteo
//
//  Created by Simone Montali on 11/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CitiesTableViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *citiesTable;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (IBAction)searchCity:(id)sender;

@end
