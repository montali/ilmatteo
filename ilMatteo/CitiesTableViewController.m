//
//  CitiesTableViewController.m
//  ilMatteo
//
//  Created by Simone Montali on 11/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import "CitiesTableViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface CitiesTableViewController ()

@end

@implementation CitiesTableViewController{
    NSMutableArray *cities;
    NSMutableArray *newCities;
    NSString *searchedCity;
}
// Quando la view appare, fetcho da CoreData le città, aggiungendo l'opzione "Posizione Attuale"
-(void) viewDidAppear:(BOOL)animated{
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    searchedCity=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"City"];
    newCities = [[_managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSString *hereCity=[NSString stringWithFormat:@"Posizione attuale"];
    cities=[NSMutableArray arrayWithObjects:hereCity, nil];
    for(int i=0;i<[newCities count];i++){
        [cities addObject:[[newCities objectAtIndex:i] valueForKey:@"cityName"]];
    }
    [_citiesTable reloadData];

}
// Al primo caricamento della view, invece, preparo gli elementi della UI
- (void)viewDidLoad {
    _citiesTable.delegate=self;
    _citiesTable.dataSource=self;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ilMatteo-2"]];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
// Essendoci una sola sezione, ci basta restituire il numero di città+1 (la posizione attuale)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cities count];
}

// Setuppo la cella con il nome della città trovato in cities
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    cell.textLabel.text=[NSString stringWithFormat:@"%@", [cities objectAtIndex:indexPath.item]];
    return cell;
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"SEGUE  :::: %@",[segue identifier]);
    if ([[segue identifier] isEqualToString:@"weatherOpener"]) {
    if(searchedCity==nil){
    [[segue destinationViewController] setCityName:[cities objectAtIndex:([_citiesTable indexPathForSelectedRow].item)]];
    if([_citiesTable indexPathForSelectedRow].item>0){
        [[segue destinationViewController] setDbObject:[newCities objectAtIndex:([_citiesTable indexPathForSelectedRow].item-1)]];
    }
    }else{
        [[segue destinationViewController] setCityName:searchedCity];
    }
    }
}
+ (NSManagedObjectContext *)managedObjectContext
{
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (IBAction)searchCity:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Cerca città"
                                                                              message: @"Inserisci il nome della città"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Città";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleNone;
        textField.backgroundColor=[UIColor clearColor];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        if(![namefield.text isEqual:@""]){
        searchedCity=namefield.text;
        [self performSegueWithIdentifier:@"weatherOpener" sender:self];
        }

        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}



@end
