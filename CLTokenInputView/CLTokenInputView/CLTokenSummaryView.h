//
//  CLTokenSummaryView.h
//  CLTokenInputView
//
//  Created by Craig Bannister on 4/20/16.
//  Copyright © 2016 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLTokenInputView.h"
#import "CLToken.h"

@protocol CLTokenSummaryViewDelegate <NSObject>

- (void)tokenSummaryViewPressed;

@end

@interface CLTokenSummaryView : UIControl

@property (strong, nonatomic) CL_GENERIC_ARRAY(CLToken *) *tokens;
@property (strong, nonatomic) UIFont *font;
@property (weak, nonatomic) id<CLTokenSummaryViewDelegate> delegate;

@end
