//
//  WeatherCondition.m
//  ilMatteo
//
//  Created by Simone Montali on 09/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import "WeatherCondition.h"

@implementation WeatherCondition 
@synthesize currentCondition = _currentCondition;
@synthesize weatherIcon=_weatherIcon;
@synthesize cityId=_cityId;
@synthesize cityName=_cityName;
@synthesize currentTemperature=_currentTemperature;
@synthesize currentPressure=_currentPressure;
@synthesize tempMin=_tempMin;
@synthesize tempMax=_tempMax;
@synthesize windSpeed=_windSpeed;
@synthesize timeStamp=_timeStamp;
@synthesize mmPrec=_mmPrec;
@synthesize percPrec=_percPrec;
@synthesize localTime=_localTime;
@synthesize longitude=_longitude;
@synthesize latitude=_latitude;
@synthesize timeOffset=_timeOffset;

-(id) initWithCity:(NSString*) city{
        // Genero la query con il nome della città (sostituirò poi gli spazi con %20) e la chiave API
        NSString *query = [[[@"http://api.openweathermap.org/data/2.5/weather?q=" stringByAppendingString:city]stringByAppendingString:@"&appid=77a67b564a92b6bb1549b8a0bd9ec052&units=metric"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    // Salvo i dati del json scaricato
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
    // Creo ora un NSDictionary con i dati del json. L'NSDictionary associa chiavi a valori
        NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
            [self setCurrentCondition:[[[results objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"id"]];
            [self setWeatherIcon:[[[results objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"]];
            [self setCityId:[NSString stringWithFormat:@"%@", [results objectForKey:@"id"]]];
            [self setCityName:[results objectForKey:@"name"]];
            [self setCurrentTemperature:[[results objectForKey:@"main"] objectForKey:@"temp"]];
            [self setCurrentPressure:[[results objectForKey:@"main"] objectForKey:@"pressure"]];
            [self setTempMin:[[results objectForKey:@"main"] objectForKey:@"temp_min"]];
            [self setTempMax:[[results objectForKey:@"main"] objectForKey:@"temp_max"]];
            [self setWindSpeed:[[results objectForKey:@"wind"] objectForKey:@"speed"]];
    [self setPercPrec:[[results objectForKey:@"clouds"] objectForKey:@"all"]];
    [self setMmPrec:[[results objectForKey:@"rain"] objectForKey:@"3h"]];
    if (_mmPrec==nil)
        [self setMmPrec:[NSNumber numberWithUnsignedInt:0]];
    //Questa che trovo è in realtà l'ora di calcolo delle previsioni.
    [self setTimeStamp:[results objectForKey:@"dt"]];
    //Visto che ho un po' di tempo, mi spingo su cose divertenti: usiamo le API di GMaps per trovare il fuso orario
    [self setLatitude:[[results objectForKey:@"coord"] objectForKey:@"lat"]];
    [self setLongitude:[[results objectForKey:@"coord"] objectForKey:@"lon"]];
    //Se la latitudine è nulla, significa che non abbiamo trovato la città
    if(_latitude!=nil){
    NSString *gMapsQuery=[[[[[[[@"https://maps.googleapis.com/maps/api/timezone/json?location=" stringByAppendingString:[_latitude stringValue]] stringByAppendingString:@","] stringByAppendingString:[_longitude stringValue]] stringByAppendingString:@"&timestamp="] stringByAppendingString:[NSString stringWithFormat:@"%@", [_timeStamp stringValue]]] stringByAppendingString:@"&key=AIzaSyDamc-swgxLI_WksG0q9vD5sdqLSqlCU8E"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *jsonGMaps = [[NSString stringWithContentsOfURL:[NSURL URLWithString:gMapsQuery] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *gMapsError = nil;
    NSDictionary *gMapsResults = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonGMaps options:0 error:&gMapsError] : nil;
    // Abbiamo due offset temporali (in secondi), quello del fuso orario, e quello dell'ora solare
    NSNumber *rawOffset = [gMapsResults objectForKey:@"rawOffset"];
    NSNumber *dstOffset = [gMapsResults objectForKey:@"dstOffset"];
    [self setTimeOffset:[NSNumber numberWithFloat:([rawOffset floatValue] + [dstOffset floatValue])]];
    // Il timeStamp è in formato Unix (secondi dal 1970). Creo un oggetto NSDate con la funzione adatta
    [self setLocalTime:[NSDate dateWithTimeIntervalSince1970:([_timeStamp floatValue] + [_timeOffset floatValue])]];
    }
    return self;
}

-(id) initWithCoordinates:(CLLocationCoordinate2D) coordinates{
    
    NSNumber *latitude = [NSNumber numberWithDouble:coordinates.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:coordinates.longitude];
    NSString *query=[[[[@"http://api.openweathermap.org/data/2.5/weather?lat=" stringByAppendingString:[latitude stringValue]] stringByAppendingString:@"&lon="]stringByAppendingString:[longitude stringValue]]stringByAppendingString:@"&appid=77a67b564a92b6bb1549b8a0bd9ec052&units=metric"];
    
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    [self setCurrentCondition:[[[results objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"id"]];
    [self setWeatherIcon:[[[results objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"]];
    [self setCityId:[NSString stringWithFormat:@"%@", [results objectForKey:@"id"]]];
    [self setCityName:[results objectForKey:@"name"]];
    [self setCurrentTemperature:[[results objectForKey:@"main"] objectForKey:@"temp"]];
    [self setCurrentPressure:[[results objectForKey:@"main"] objectForKey:@"pressure"]];
    [self setTempMin:[[results objectForKey:@"main"] objectForKey:@"temp_min"]];
    [self setTempMax:[[results objectForKey:@"main"] objectForKey:@"temp_max"]];
    [self setWindSpeed:[[results objectForKey:@"wind"] objectForKey:@"speed"]];
    [self setPercPrec:[[results objectForKey:@"clouds"] objectForKey:@"all"]];
    [self setMmPrec:[[results objectForKey:@"rain"] objectForKey:@"3h"]];
    if (_mmPrec==nil)
        [self setMmPrec:[NSNumber numberWithUnsignedInt:0]];
    [self setLatitude:[[results objectForKey:@"coord"] objectForKey:@"lat"]];
    [self setLongitude:[[results objectForKey:@"coord"] objectForKey:@"lon"]];
    //Questa che trovo è in realtà l'ora di calcolo delle previsioni.
    [self setTimeStamp:[results objectForKey:@"dt"]];
    //Visto che ho un po' di tempo, mi spingo su cose divertenti: usiamo le API di GMaps per trovare il fuso orario
    [self setLatitude:[[results objectForKey:@"coord"] objectForKey:@"lat"]];
    [self setLongitude:[[results objectForKey:@"coord"] objectForKey:@"lon"]];
    NSString *gMapsQuery=[[[[[[[@"https://maps.googleapis.com/maps/api/timezone/json?location=" stringByAppendingString:[_latitude stringValue]] stringByAppendingString:@","] stringByAppendingString:[_longitude stringValue]] stringByAppendingString:@"&timestamp="] stringByAppendingString:[NSString stringWithFormat:@"%@", [_timeStamp stringValue]]] stringByAppendingString:@"&key=AIzaSyDamc-swgxLI_WksG0q9vD5sdqLSqlCU8E"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *jsonGMaps = [[NSString stringWithContentsOfURL:[NSURL URLWithString:gMapsQuery] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *gMapsError = nil;
    NSDictionary *gMapsResults = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonGMaps options:0 error:&gMapsError] : nil;
    // Abbiamo due offset temporali (in secondi), quello del fuso orario, e quello dell'ora solare
    NSNumber *rawOffset = [gMapsResults objectForKey:@"rawOffset"];
    NSNumber *dstOffset = [gMapsResults objectForKey:@"dstOffset"];
    [self setTimeOffset:[NSNumber numberWithFloat:([rawOffset floatValue] + [dstOffset floatValue])]];
    // Il timeStamp è in formato Unix (secondi dal 1970). Creo un oggetto NSDate con la funzione adatta
    [self setLocalTime:[NSDate dateWithTimeIntervalSince1970:([_timeStamp floatValue] + [_timeOffset floatValue])]];
    return self;
}

@end
