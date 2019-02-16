//
//  MyDataController.h
//  QUESTAELABUONA
//
//  Created by Simone Montali on 11/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MyDataController : NSObject
@property (strong, nonatomic, readonly) NSPersistentContainer *persistentContainer;

- (id)initWithCompletionBlock:(CallbackBlock)callback;


@end
