// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/12/2011
//
//  Copyright 2012 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTModelController.h"

#import <CoreData/CoreData.h>

@class NSManagedObjectModel;
@class NSPersistentStoreCoordinator;
@class NSManagedObjectContext;

@interface ECTCoreDataModelController : ECTModelController

@property (nonatomic, retain, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;

- (void)startupCoreData;
- (void)shutdownCoreData;

- (void)save;

- (id)findEntityForName:(NSString*)entityName forKey:(NSString*)key value:(NSString*)value;
- (id)findOrCreateEntityForName:(NSString*)entityName forKey:(NSString*)key value:(NSString*)value wasFound:(BOOL*)wasFound;
- (NSArray*)allEntitiesForName:(NSString*)entityName predicate:(NSPredicate*)predicate sort:(NSArray*)sort;
- (NSArray*)allEntitiesForName:(NSString*)entityName sorted:(NSArray*)sort;

@end
