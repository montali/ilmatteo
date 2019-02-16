//
//  HistoryViewController.h
//  ilMatteo
//
//  Created by Simone Montali on 12/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (assign) NSInteger expandedSectionHeaderNumber;
@property (assign) UITableViewHeaderFooterView *expandedSectionHeader;
@property (strong) NSMutableArray *sectionItems;
@property (strong) NSMutableArray *sectionNames;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong) NSString *cityID;
@end

