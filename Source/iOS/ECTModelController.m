// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/12/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTModelController.h"
#import "ECTAppDelegate.h"

@implementation ECTModelController

ECDefineDebugChannel(ModelChannel);

+ (id)sharedInstance
{
	ECTAppDelegate* app = [ECTAppDelegate sharedInstance];
    return app.model;
}


- (void)startup
{
	ECDebug(ModelChannel, @"model startup");
}

- (void)shutdown
{
	ECDebug(ModelChannel, @"model shutdown");
}

- (void)load
{
	ECDebug(ModelChannel, @"model load");
}

- (void)save
{
	ECDebug(ModelChannel, @"model save");
}

@end
