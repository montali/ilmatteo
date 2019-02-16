//
//  AboutViewController.m
//  ilMatteo
//
//  Created by Simone Montali on 14/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize managedObjectContext=_managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)exportCSV:(id)sender {
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"City"];
    NSArray *cities = [[_managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSString *writeString = [[NSString alloc] init];
    // Metto dentro writeString tutti i dati ottenuti da cities
    for (int i=0; i<[cities count]; i++) {
        writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@",[[cities objectAtIndex:i] valueForKey:@"cityName"]]];
        // Metto la virgola in tutte tranne l'ultima
        if(i<[cities count]-1)
            writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@","]];
    }
    // Creo un file temporaneo che poi eliminerò
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"Export.csv"]];
    // Genero NSData dalla stringa, poi la scrivo sul file
    NSData *dataToWrite = [writeString dataUsingEncoding:NSUTF8StringEncoding];
    [dataToWrite writeToURL:url atomically:NO];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        NSError *errorBlock;
        // Quando ho finito, elimino il file temporaneo
        if([[NSFileManager defaultManager] removeItemAtURL:url error:&errorBlock] == NO) {
            NSLog(@"error deleting file %@",errorBlock);
            return;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self presentViewController:activityViewController animated:YES completion:nil];
    });
     NSString *alertMessage = [NSString stringWithFormat:@"%@ esportato con successo", [url lastPathComponent]];
     
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Esportazione"
                                              message:alertMessage
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
    
}
// Per importare il CSV, uso uno UIDocumentPicker; Quando il DocumentPicker avrà il file, essendo questa classe <UIDocumentPickerDelegate>, verrà chiamata didPickDocumentAtUrl
- (IBAction)importCSV:(id)sender {
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.item"] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    dispatch_async(dispatch_get_main_queue(), ^{
    [self presentViewController:documentPicker animated:YES completion:nil];
    });
}

// Un po' di karma positivo sotto forma di UIAlertController.
- (IBAction)itWasAGoodDay:(id)sender {            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Aiuta l'Operazione Mato Grosso"
                                                                                                                            message: @"Hai voglia di aiutare Matteo nei suoi progetti di bene? Diventa volontario!"
                                                                                                                     preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Annulla" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Aiuta" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:[NSURL URLWithString: @"http://www.operazionematogrosso.it"] options:@{} completionHandler:nil];
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self presentViewController:alertController animated:YES completion:nil];
    });
}


// Quando il documentPicker restituisce un URL, leggo il file e salvo i dati in CoreData
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        NSString *alertMessage = [NSString stringWithFormat:@"%@ importato con successo", [url lastPathComponent]];
        NSString* fileContents = [NSString stringWithContentsOfFile:[url path] encoding:NSUTF8StringEncoding error:nil];
        NSArray* cities = [fileContents componentsSeparatedByString:@","];
        NSManagedObject *dbObject;
        for (int i=0;i<[cities count];i++){
            dbObject = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:_managedObjectContext];
            [dbObject setValue:[cities objectAtIndex:i]  forKey:@"cityName"];
            NSError *error = nil;
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Importazione"
                                                  message:alertMessage
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
}
}
@end
