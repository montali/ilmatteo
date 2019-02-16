//
//  HistoryViewController.h
//  ilMatteo
//
//  Created by Simone Montali on 12/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import "HistoryViewController.h"
#import "AppDelegate.h"

static int const kHeaderSectionTag = 6900;


@implementation HistoryViewController{
    NSArray *parameterStrings;
}
@synthesize cityID=_cityID;


- (void)viewDidLoad {
    [super viewDidLoad];

    parameterStrings=[NSArray arrayWithObjects:[NSString stringWithFormat:@"Pressione"],[NSString stringWithFormat:@"Temperatura"],[NSString stringWithFormat:@"TempMax"],[NSString stringWithFormat:@"TempMin"], nil];
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PastWeatherCondition"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"cityId == %@", _cityID]];
    NSMutableArray *weatherConditions = [[_managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    self.sectionNames=[NSMutableArray new];
    self.sectionItems=[NSMutableArray new];
    for(int i=0;i<[weatherConditions count];i++){
        // Il DateFormatter mi serve per creare stringhe dall'oggetto NSDate
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
        // Imposto GMT perché altrimenti usa la Time Zone locale (i dati che ho sono GMT)
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSString *dateString = [dateFormatter stringFromDate:[[weatherConditions objectAtIndex:i] valueForKey:@"datetime"]];
        [_sectionNames addObject:[NSString stringWithFormat:@"%@", dateString]];
        NSString *pressure=[NSString stringWithFormat:@"%@", [[weatherConditions objectAtIndex:i] valueForKey:@"pressure"]];
        pressure=[pressure stringByAppendingString:@" hPa"];
        NSString *temperature=[NSString stringWithFormat:@"%@", [[weatherConditions objectAtIndex:i] valueForKey:@"temperature"]];
        temperature=[temperature stringByAppendingString:@"°C"];
        NSString *tempMax=[NSString stringWithFormat:@"%@", [[weatherConditions objectAtIndex:i] valueForKey:@"tempMax"]];
        tempMax=[tempMax stringByAppendingString:@"°C"];
        NSString *tempMin=[NSString stringWithFormat:@"%@", [[weatherConditions objectAtIndex:i] valueForKey:@"tempMin"]];
        tempMin=[tempMin stringByAppendingString:@"°C"];
        NSMutableArray *conditions=[NSMutableArray arrayWithObjects:pressure,temperature,tempMax,tempMin, nil];
        [_sectionItems addObject:conditions];
        
    }
    
    // configure the tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.expandedSectionHeaderNumber = -1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        self.tableView.backgroundView = nil;
        return self.sectionNames.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.expandedSectionHeaderNumber == section) {
        NSMutableArray *arrayOfItems = [self.sectionItems objectAtIndex:section];
        return arrayOfItems.count;
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sectionNames.count) {
        return [self.sectionNames objectAtIndex:section];
    }
    
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section; {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // recast your view as a UITableViewHeaderFooterView
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor lightGrayColor];
    header.textLabel.textColor = [UIColor blackColor];
    UIImageView *viewWithTag = [self.view viewWithTag:kHeaderSectionTag + section];
    if (viewWithTag) {
        [viewWithTag removeFromSuperview];
    }
    // make headers touchable
    header.tag = section;
    UITapGestureRecognizer *headerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderWasTouched:)];
    [header addGestureRecognizer:headerTapGesture];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    NSArray *section = [self.sectionItems objectAtIndex:indexPath.section];
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [parameterStrings objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [section objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateTableViewRowDisplay:(NSArray *)arrayOfIndexPaths {
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation: UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - Expand / Collapse Methods

- (void)sectionHeaderWasTouched:(UITapGestureRecognizer *)sender {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)sender.view;
    NSInteger section = headerView.tag;
    UIImageView *eImageView = (UIImageView *)[headerView viewWithTag:kHeaderSectionTag + section];
    self.expandedSectionHeader = headerView;
    
    if (self.expandedSectionHeaderNumber == -1) {
        self.expandedSectionHeaderNumber = section;
        [self tableViewExpandSection:section withImage: eImageView];
    } else {
        if (self.expandedSectionHeaderNumber == section) {
            [self tableViewCollapeSection:section withImage: eImageView];
            self.expandedSectionHeader = nil;
        } else {
            UIImageView *cImageView  = (UIImageView *)[self.view viewWithTag:kHeaderSectionTag + self.expandedSectionHeaderNumber];
            [self tableViewCollapeSection:self.expandedSectionHeaderNumber withImage: cImageView];
            [self tableViewExpandSection:section withImage: eImageView];
        }
    }
}

- (void)tableViewCollapeSection:(NSInteger)section withImage:(UIImageView *)imageView {
    NSArray *sectionData = [self.sectionItems objectAtIndex:section];
    
    self.expandedSectionHeaderNumber = -1;
    if (sectionData.count == 0) {
        return;
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            imageView.transform = CGAffineTransformMakeRotation((0.0 * M_PI) / 180.0);
        }];
        NSMutableArray *arrayOfIndexPaths = [NSMutableArray array];
        for (int i=0; i< sectionData.count; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:section];
            [arrayOfIndexPaths addObject:index];
        }
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation: UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)tableViewExpandSection:(NSInteger)section withImage:(UIImageView *)imageView {
    NSArray *sectionData = [self.sectionItems objectAtIndex:section];
    
    if (sectionData.count == 0) {
        self.expandedSectionHeaderNumber = -1;
        return;
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            imageView.transform = CGAffineTransformMakeRotation((180.0 * M_PI) / 180.0);
        }];
        NSMutableArray *arrayOfIndexPaths = [NSMutableArray array];
        for (int i=0; i< sectionData.count; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:section];
            [arrayOfIndexPaths addObject:index];
        }
        self.expandedSectionHeaderNumber = section;
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation: UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}
@end
