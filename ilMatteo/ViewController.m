//
//  ViewController.m
//  ilMatteo
//
//  Created by Simone Montali on 08/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import "ViewController.h"
#import "WeatherCondition.h"
#import "AppDelegate.h"
#import <Lottie/Lottie.h>
#import "HistoryViewController.h"




@interface ViewController ()<CLLocationManagerDelegate>

@end

@implementation ViewController{
    NSString *longitude;
    NSString *latitude;
    CLLocationCoordinate2D currentCoordinates;
    UIStatusBarStyle currentStatusBarStyle;
    UIBarButtonItem *saveButton;
}
@synthesize cityName=_cityName;
@synthesize dbObject=_dbObject;
@synthesize cityID=_cityID;

// In viewDidLoad, controllo innanzitutto se la città è salvata. Poi chiamo la funzione per fetchare il tempo
- (void)viewDidLoad {
    [super viewDidLoad];
    saveButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"star-empty"] style:UIBarButtonItemStylePlain target:self action:@selector(saveCity)];
    self.navigationItem.rightBarButtonItem=saveButton;
    if(_dbObject!=nil)
        [saveButton setImage:[UIImage imageNamed:@"star-full"]];
    else
        [_historyToolbar setHidden:YES];
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    currentCoordinates=kCLLocationCoordinate2DInvalid;
    if([_cityName isEqualToString:@"Posizione attuale"]){
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services are not enabled");
    }
        [self fetchCurrentWeatherHere];
    }else{
        [self fetchCurrentWeatherByCity:_cityName];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // Rimettiamo a posto la NavBar quando si lascia la view
    self.navigationController.navigationBar.barStyle=UIBarStyleDefault;
    self.navigationController.navigationBar.alpha = 1;
}

#pragma mark - CLLocationManagerDelegate

// Se c'è un errore con la posizione, creo un'AlertView
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Errore"
                                              message:@"C'è stato un problema nella ricerca della posizione"
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

// Quando la location viene aggiornata, salvo l'ultima
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    if(location!=nil){
        currentCoordinates=CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
     }
}

// Con questa funzione salvo la stringa cityName in CoreData. Di conseguenza, cambio il logo favorite
-(void) saveCity{
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    if(_dbObject==nil){
        _dbObject = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:_managedObjectContext];
        
        [_dbObject setValue:self.cityName forKey:@"cityName"];
        NSError *error = nil;
        // Save the object to persistent store
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [saveButton setImage:[UIImage imageNamed:@"star-full"]];
    }else{
        // Delete object from database
        [_managedObjectContext deleteObject:_dbObject];
        NSError *error = nil;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        [saveButton setImage:[UIImage imageNamed:@"star-empty"]];
        _dbObject=nil;
    }

}

// Su un thread secondario, cerco il tempo per le coordinate attuali. Aspetto però che siano valide. Poi sul main thread aggiorno le labels

-(void)fetchCurrentWeatherHere{
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        WeatherCondition *hereNow;
        while(!CLLocationCoordinate2DIsValid(currentCoordinates)){};
            hereNow = [[WeatherCondition alloc]initWithCoordinates:currentCoordinates];
        dispatch_async(dispatch_get_main_queue(), ^{
            while(hereNow==nil){};
            [self setCityName:[hereNow cityName]];
            [self setCityID:[hereNow cityId]];
            [self updateLabels:hereNow];
        });
                       });
}

// Come sopra, cerco il meteo per la città, su un altro thread. Poi aggiorno le label. Se ci sono errori, creo un alert
-(void)fetchCurrentWeatherByCity:(NSString*) city{
    
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        
        WeatherCondition *weather = [[WeatherCondition alloc]initWithCity:city];
            //Se la latitudine è nulla, significa che non abbiamo trovato la città
        if([weather latitude]==nil){
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Città inesistente"
                                                                                      message: @"Spiacente, la città che hai cercato non esiste"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[self navigationController] popViewControllerAnimated:YES];
                
            }]];
                [self presentViewController:alertController animated:YES completion:nil];
        } else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateLabels:weather];
            [self setCityName:[weather cityName]];
            [self setCityID:[weather cityId]];
            if(_dbObject!=nil){
                
                
                //Faccio in modo di non salvare più volte dati calcolati alla stessa ora da OpenWeatherMap
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PastWeatherCondition"];
                
                NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"cityId == %@", _cityID], [NSPredicate predicateWithFormat:@"datetime == %@", [weather localTime]]]];
                [fetchRequest setPredicate:andPredicate];
                NSMutableArray *weatherConditions = [[_managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                if([weatherConditions count]==0){
                
                
                
                NSManagedObject *weatherDB = [NSEntityDescription insertNewObjectForEntityForName:@"PastWeatherCondition" inManagedObjectContext:_managedObjectContext];
                
                [weatherDB setValue:[weather cityId] forKey:@"cityId"];
                [weatherDB setValue:[weather currentCondition] forKey:@"condition"];
                [weatherDB setValue:[weather localTime] forKey:@"datetime"];
                [weatherDB setValue:[weather currentPressure] forKey:@"pressure"];
                [weatherDB setValue:[weather currentTemperature] forKey:@"temperature"];
                [weatherDB setValue:[weather tempMax] forKey:@"tempMax"];
                [weatherDB setValue:[weather tempMin] forKey:@"tempMin"];
                NSError *error = nil;
                if (![_managedObjectContext save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
                }
            }
        });
            
        }
    });
}

// Funzione per aggiornare le label della view
-(void)updateLabels:(WeatherCondition*) withConditions{
    [_labelNomeCitta setText:[withConditions cityName]];
    int temperatureInt = [[withConditions currentTemperature]intValue];
    NSNumber *temperature = [NSNumber numberWithInt:temperatureInt];
    [_temperatureLabel setText:[[temperature stringValue] stringByAppendingString:@"°C"]];
    [_conditionsLabel setText:[[[[[NSNumber numberWithInteger:[[withConditions tempMin] intValue]] stringValue] stringByAppendingString:@"°/"] stringByAppendingString:    [[NSNumber numberWithInteger:[[withConditions tempMax] intValue]] stringValue]] stringByAppendingString:@"°C"]];
    [_mmPrecLabel setText:[[[withConditions mmPrec] stringValue] stringByAppendingString:@" mm"]];
    [_ventoLabel setText:[[[withConditions windSpeed] stringValue] stringByAppendingString:@" m/s"]];
    [_precPercent setText:[[[withConditions percPrec] stringValue] stringByAppendingString:@" %"]];
    [_pressureLabel setText:[[[NSNumber numberWithInteger:[[withConditions currentPressure] integerValue]] stringValue] stringByAppendingString:@" hPa"]];
    NSString *condizioni;
    NSString *icon;
    int iconDim,marginX,marginY;
    // Le API restituiscono dei codici per la condizione meteo. Con uno switch decido il da farsi. Essendo le icone leggermente diverse, modifico dimensione e margini in base all'icona
    switch([[withConditions currentCondition] integerValue]){
        case 200 ... 233:
            condizioni=@"Temporali - ";
            icon=@"thunder";
            iconDim=220;
            marginX=15;
            marginY=75;
            break;
        case 300 ... 633:
            condizioni=@"Pioggia leggera - ";
            icon=@"rain";
            iconDim=220;
            marginX=0;
            marginY=65;
            break;
        case 700 ... 740:
            condizioni=@"Umidità - ";
            icon=@"clouds";
            iconDim=220;
            marginX=15;
            marginY=75;
            break;
        case 741:
            condizioni=@"Nebbia - ";
            icon=@"clouds";
            iconDim=220;
            marginX=15;
            marginY=75;
            break;
        case 800:
            condizioni=@"Sereno - ";
            icon=@"clear";
            iconDim=200;
            marginX=0;
            marginY=65;
            break;
        case 801 ... 804:
            condizioni=@"Nuvoloso - ";
            icon=@"clouds";
            iconDim=220;
            marginX=15;
            marginY=75;
            break;
        default:
            condizioni=@"Sconosciuto - ";
            icon=@"clear";
            iconDim=200;
            marginX=0;
            marginY=65;
            break;
    };
    [_conditionsLabel setText:[condizioni stringByAppendingString:[[[[[withConditions tempMin] stringValue] stringByAppendingString:@"°/"] stringByAppendingString:[[withConditions tempMax] stringValue]] stringByAppendingString:@"°C"]]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH.mm"];
    NSString *strCurrentTime = [dateFormatter stringFromDate:[withConditions localTime]];
    // Se nel luogo cercato è notte, scurisco il tutto e metto un po' di stelle
    if ([strCurrentTime floatValue] >= 18.00 || [strCurrentTime floatValue]  <= 6.00){
        UIColor *myColor = [UIColor colorWithRed:(10.0 / 255.0) green:(27.0 / 255.0)
                                            blue:(37.0 / 255.0) alpha: 1];
        LOTAnimationView *animation = [LOTAnimationView animationNamed:@"stars"];
        animation.frame=CGRectMake(0, 0,700, 700);
        animation.contentMode=UIViewContentModeScaleAspectFill;
        _backgroundView.backgroundColor=myColor;
        [self changeTextColor:[UIColor whiteColor]];
        self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
        [_historyToolbar setBarStyle:UIBarStyleBlackTranslucent];
        [self setNeedsStatusBarAppearanceUpdate];
        [self.backgroundView addSubview:animation];
        animation.loopAnimation=YES;
        [animation play];
        // Aggiungo inoltre "night": tutti i json di lottie hanno una loro controparte notturna
        icon=[@"night" stringByAppendingString:icon];
    }
        LOTAnimationView *animationIcon = [LOTAnimationView animationNamed:icon];
        animationIcon.frame=CGRectMake(marginX, marginY,iconDim, iconDim);
        animationIcon.contentMode=UIViewContentModeScaleAspectFill;
        [self.view addSubview:animationIcon];
        animationIcon.loopAnimation=YES;
        [animationIcon play];    
    if([[withConditions currentCondition] integerValue]>=200 && [[withConditions currentCondition] integerValue]<700){
        [_matteView setImage:[UIImage imageNamed:@"rainMatte" inBundle: nil compatibleWithTraitCollection:nil]];
    }else{
        NSString *photoName;
        // In base alla temperatura, decido il Matte giusto da visualizzare. Se piove metto il Matte bagnato (sperando sia anche fortunato!)
        switch([[withConditions currentTemperature] integerValue]){
            case -60 ... 10:
                photoName=@"coldMatte";
                break;
            case 11 ... 20:
                photoName=@"autumnMatte";
                break;
            case 21 ... 60:
                photoName=@"hotMatte";
                break;
        };
        [_matteView setImage:[UIImage imageNamed:photoName inBundle: nil compatibleWithTraitCollection:nil]];
    }
}

- (void)changeTextColor:(UIColor*) withColor{
        //Ottengo tutte le UIViews
        for (UIView *view in [self.view subviews]) {
            //Se sono label voglio modificare il testo
            if ([view isKindOfClass:[UILabel class]]) {
                //Casto la view a UILabel
                UILabel *label = (UILabel *)view;
                //Imposto infine il colore
                label.textColor = withColor;
            }
        }
    }

-(UIStatusBarStyle)preferredStatusBarStyle {
    return currentStatusBarStyle;
}

// Questa mi serve per CoreData
- (NSManagedObjectContext *)getManagedObjectContext {
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}


// Prima di effettuare il segue, salvo sul ViewController di destinazione il nome della città
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setCityID:_cityID];
 }


- (void)alertController:(UIAlertController *)alertController clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Se lo user volesse rendere il suo Matte più social, gli dò la possibilità di condividere la view (senza tool e status bar)
- (IBAction)shareWeather:(id)sender {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-44), NO, [UIScreen mainScreen].scale);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    UIGraphicsEndImageContext();
    //Condivido
    NSArray *items = @[image];
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    //Il codice che modifica la user interface deve essere sul main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:controller animated:YES completion:nil];
    });
}
@end
