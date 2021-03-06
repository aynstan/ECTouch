// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 03/02/2012
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTAlertView.h"

static NSMutableSet* gAlertsInFlight;

@interface ECTAlertView()

@property (strong, nonatomic) UIAlertView* alert;
@property (strong, nonatomic) AlertHandler handler;

@end

@implementation ECTAlertView

@synthesize alert;
@synthesize handler;

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    if ((self = [super init]) != nil)
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
		if (otherButtonTitles)
		{
			va_list args;
			va_start(args, otherButtonTitles);
			for (id buttonTitle = va_arg(args, id); buttonTitle != nil;)
			{
				[av addButtonWithTitle:buttonTitle];
			}
			va_end(args);
		}

        self.alert = av;
        [av release];
    }
    
    return self;
}

- (void)dealloc
{
    [alert release];
    [handler release];

    [super dealloc];
}

- (void)showWithHandler:(AlertHandler)handlerIn
{
    AlertHandler hc = [handlerIn copy];
    self.handler = hc;
    [hc release];

    if (!gAlertsInFlight)
    {
        gAlertsInFlight = [[NSMutableSet alloc] init]; 
    }

    [gAlertsInFlight addObject:self];
    [self.alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.handler(buttonIndex);
    self.alert = nil;
    self.handler = nil;
    [gAlertsInFlight removeObject:self];
    
    // clean up the in flight set if that was the last alert
    if ([gAlertsInFlight count] == 0)
    {
        [gAlertsInFlight release];
        gAlertsInFlight = nil;
    }
}

@end
