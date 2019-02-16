//
//  AboutViewController.h
//  ilMatteo
//
//  Created by Simone Montali on 14/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface AboutViewController : UIViewController <UIDocumentPickerDelegate>
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (IBAction)exportCSV:(id)sender;
- (IBAction)importCSV:(id)sender;
- (IBAction)itWasAGoodDay:(id)sender;

@end
