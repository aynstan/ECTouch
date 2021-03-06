//
//  ECRootTabBarController.m
//  ECFoundation
//
//  Created by Sam Deane on 28/08/2010.
//  Copyright (c) 2010 Elegant Chaos. All rights reserved.
//

#import "ECRootTabBarController.h"
#import "ECNavigationController.h"
#import "ECLabelValueTableController.h"
#import "ECDebugViewController.h"
#import "ECLogging.h"

ECDefineDebugChannel(RootTabBarChannel);

@interface ECRootTabBarController()
- (void) addDebugTab;
@end

@implementation ECRootTabBarController

static const NSInteger kDebugTabTag = 0;

- (void) addDebugTab
{
	ECDebugViewController* debugController = [[ECDebugViewController alloc] initWithStyle: UITableViewStyleGrouped];
	
	ECNavigationController* debugNavigation = [[ECNavigationController alloc] initWithNibName: nil bundle: nil];
	debugNavigation.initialView = debugController;
	debugNavigation.title = @"Debug";
	
	UIImage* image = [UIImage imageNamed: @"debug.png"];
	UITabBarItem* debugItem = [[UITabBarItem alloc] initWithTitle: @"Debug" image: image tag: kDebugTabTag];
	debugNavigation.tabBarItem = debugItem;
	
	NSMutableArray* newControllers = [[NSMutableArray alloc] initWithArray: self.viewControllers];
	[newControllers addObject: debugNavigation];
	[self setViewControllers: newControllers animated: NO];
	
	[newControllers release];
	[debugController release];
	[debugNavigation release];
    [debugItem release];
}

- (void) viewDidLoad
{
	ECDebug(RootTabBarChannel, @"view did load");
	
	#ifdef EC_DEBUG
		[self addDebugTab];
	#endif
}

@end
