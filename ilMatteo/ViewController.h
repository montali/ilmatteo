//
//  ViewController.h
//  ilMatteo
//
//  Created by Simone Montali on 08/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) NSString *cityName;
@property (nonatomic,strong) NSString *cityID;

@property (weak, nonatomic) IBOutlet UILabel *labelNomeCitta;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *conditionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *mmPrecLabel;
@property (weak, nonatomic) IBOutlet UILabel *ventoLabel;
@property (weak, nonatomic) IBOutlet UILabel *precPercent;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *matteView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSManagedObject *dbObject;
@property (weak, nonatomic) IBOutlet UIToolbar *historyToolbar;
- (IBAction)shareWeather:(id)sender;

@end

