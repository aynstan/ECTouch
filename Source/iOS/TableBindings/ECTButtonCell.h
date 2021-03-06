// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTSimpleCell.h"

// --------------------------------------------------------------------------
//! Button based cell conforming to the ECTSectionDrivenTableCell protocol.
// --------------------------------------------------------------------------

@interface ECTButtonCell : ECTSimpleCell

@property (strong, nonatomic) UIButton* buttonControl;

- (UIButtonType)buttonType;

@end

