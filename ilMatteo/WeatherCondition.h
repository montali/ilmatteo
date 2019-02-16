//
//  WeatherCondition.h
//  ilMatteo
//
//  Created by Simone Montali on 09/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WeatherCondition : NSObject
@property (nonatomic,strong) NSNumber* currentCondition;
@property (nonatomic,strong) NSString* weatherIcon;
@property (nonatomic,strong) NSString* cityId;
@property (nonatomic,strong) NSString* cityName;
@property (nonatomic,strong) NSNumber* currentTemperature;
@property (nonatomic,strong) NSNumber* currentPressure;
@property (nonatomic,strong) NSNumber* tempMin;
@property (nonatomic,strong) NSNumber* tempMax;
@property (nonatomic,strong) NSNumber* windSpeed;
@property (nonatomic,strong) NSNumber* timeStamp;
@property (nonatomic,strong) NSNumber* mmPrec;
@property (nonatomic,strong) NSNumber* percPrec;
@property (nonatomic,strong) NSDate *localTime;
// So dell'esistenza delle coordinate in CoreLocation, ma per l'uso che ne faccio qui non ha senso
@property (nonatomic,strong) NSNumber *longitude;
@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *timeOffset;

-(id) initWithCity:(NSString*) city;
-(id) initWithCoordinates:(CLLocationCoordinate2D) coordinates;
@end
