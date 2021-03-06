// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTSectionDrivenTableController.h"

#import "ECTBinding.h"
#import "ECTSection.h"
#import "ECTKeys.h"

@interface ECTSectionDrivenTableController()

@property (assign, nonatomic) BOOL editable;
@property (strong, nonatomic, readwrite) NSMutableArray* sections;

- (ECTSection*)sectionForIndex:(NSUInteger)index;
- (ECTSection*)sectionForIndexPath:(NSIndexPath*)indexPath;

@end

@implementation ECTSectionDrivenTableController

#pragma mark - Debug Channels

ECDefineDebugChannel(ECTSectionDrivenTableControllerChannel);

#pragma mark - Properties

@synthesize editable;
@synthesize navigator;
@synthesize sections;
@synthesize representedObject;

#pragma mark - Object Lifecycle

- (id)initWithBinding:(ECTBinding*)binding
{
    BOOL grouped = ([[binding lookupDisclosureKey:ECTStyleKey] isEqualToString:@"grouped"]);
    UITableViewStyle style = grouped ? UITableViewStyleGrouped : UITableViewStylePlain;
    
    if ((self = [self initWithStyle:style]) != nil)
    {
    }
    
    return self;
}


- (void)dealloc
{
    [representedObject release];
    [sections release];
    
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    id selectedObject = self.representedObject.value;
    NSUInteger sectionIndex = 0;
    for (ECTSection* section in self.sections)
    {
        NSUInteger row = 0;
        if (section.canSelect)
        {
            for (ECTBinding* object in section.content)
            {
                if ([object.value isEqual:selectedObject])
                {
                    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
                    [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
                    break;
                }
                     
                ++row;
            }
            
            ++sectionIndex;
        }
    }
    
    [super viewDidAppear:animated];
}
#pragma mark - Section utilities

- (void)clearSections
{
    [self.sections removeAllObjects];
    if (self.editable)
    {
        self.editable = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }
    [[self tableView] reloadData];
}

- (void)addSection:(ECTSection *)section
{
    if (!self.sections)
    {
        self.sections = [NSMutableArray array];
    }

    section.table = self;
    section.binding = self.representedObject;
    [self.sections addObject:section];
    if ([section canEdit])
    {
        self.editable = YES;
        if (!self.navigationItem.rightBarButtonItem)
        {
            self.navigationItem.rightBarButtonItem = [self editButtonItem];
        }
    }
    [[self tableView] reloadData];
}

- (ECTSection*)sectionForIndex:(NSUInteger)index
{
    ECAssert(index < [self.sections count]);
    return [self.sections objectAtIndex:index];
}

- (ECTSection*)sectionForIndexPath:(NSIndexPath*)indexPath
{
    ECAssertNonNil(indexPath);
    ECAssert((NSUInteger) indexPath.section < [self.sections count]);
    
    return [self.sections objectAtIndex:indexPath.section];
}

- (void)pushSubviewForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath detail:(BOOL)detail
{
    ECTSection* section = [self sectionForIndexPath:indexPath];
    ECAssert([section tableView] == tableView);
    
    UIViewController* view = [section disclosureViewForRowAtIndexPath:indexPath detail:detail];
    if (view)
    {
		UINavigationController* navigation = self.navigator; // on iOS 4, we don't have child view controllers, so the navigation controller sometimes has to be set explicitly
		if (!navigation)
		{
			navigation = self.navigationController; // we can infer the navigation controller automatically if we're on it, or (iOS 5 only) a child of a controller on it
		}
		
        ECTBinding* binding = [section bindingForRowAtIndexPath:indexPath];
		[binding setupView:view forNavigationController:navigation];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (navigation)
        {
			[binding pushView:view forNavigationController:navigation];
        }
        else
        {
            ECDebug(ECTSectionDrivenTableControllerChannel, @"couldn't get navigation controller - is the navigator property set?");
        }
    }
}

#pragma mark - Table Utilities


- (void)deselectAllRowsAnimated:(BOOL)animated
{
    NSIndexPath* selection = [self.tableView indexPathForSelectedRow];
    if (selection)
    {
        [self.tableView deselectRowAtIndexPath:selection animated:animated];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    ECTSection* section = [self sectionForIndex:sectionIndex];
    ECAssert([section tableView] == tableView);

    return [section numberOfRowsInSection];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex
{
    ECTSection* section = [self sectionForIndex:sectionIndex];
    ECAssert([section tableView] == tableView);

    return [section titleForHeaderInSection];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionIndex
{
    ECTSection* section = [self sectionForIndex:sectionIndex];
    ECAssert([section tableView] == tableView);

    return [section titleForFooterInSection];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTSection* section = [self sectionForIndexPath:indexPath];
    return [section heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTSection* section = [self sectionForIndexPath:indexPath];
    return [section cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTSection* section = [self sectionForIndexPath:indexPath];
    ECAssert([section tableView] == tableView);
    ECTBinding* binding = [section bindingForRowAtIndexPath:indexPath];
    if (binding.enabled)
    {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
        {
            [self pushSubviewForTableView:tableView atIndexPath:indexPath detail:NO];
        }
        else
        {
            [section didSelectRowAtIndexPath:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self pushSubviewForTableView:tableView atIndexPath:indexPath detail:YES];
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
     ECTSection* section = [self sectionForIndexPath:indexPath];
     ECAssert([section tableView] == tableView);

     return [section canEditRowAtIndexPath:indexPath];
 }

 // Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTSection* section = [self sectionForIndexPath:indexPath];
    ECAssert([section tableView] == tableView);

    [section commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
     ECTSection* fromSection = [self sectionForIndexPath:fromIndexPath];
     ECAssert([fromSection tableView] == tableView);

     ECTSection* toSection = [self sectionForIndexPath:toIndexPath];
     ECAssert([toSection tableView] == tableView);
     
     if (fromSection == toSection)
     {
         [fromSection moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
     }
     else
     {
         [toSection moveRowFromSection:fromSection atIndexPath:fromIndexPath toIndexPath:toIndexPath];
     }
 }

 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
     ECTSection* section = [self sectionForIndexPath:indexPath];
     ECAssert([section tableView] == tableView);

     return [section canMoveRowAtIndexPath:indexPath];
 }

#pragma mark - ECTBindingViewController

- (void)setupForBinding:(ECTBinding *)binding
{
    // remember the binding that showed this view - we'll store the results back in its object
    self.representedObject = binding;
}

@end

