//
//  CLTokenSummaryView.m
//  CLTokenInputView
//
//  Created by Craig Bannister on 4/20/16.
//  Copyright © 2016 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenSummaryView.h"
#import "CLToken.h"

static CGFloat const PADDING_X = 4.0;
static CGFloat const PADDING_Y = 2.0;

@interface CLTokenSummaryView ()

@property (strong, nonatomic) UILabel *moreSummaryLabel;
@property (strong, nonatomic) UILabel *tokensSummaryLabel;

@end

@implementation CLTokenSummaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.tokensSummaryLabel = [UILabel new];
    [self addSubview:self.tokensSummaryLabel];

    self.moreSummaryLabel = [UILabel new];
    [self addSubview:self.moreSummaryLabel];

    UIColor *tintColor = [UIColor colorWithRed:0.0823 green:0.4941 blue:0.9843 alpha:1.0];
    if ([self respondsToSelector:@selector(tintColor)]) {
        tintColor = self.tintColor;
    }

    self.userInteractionEnabled = YES;
    [self addTarget:self action:@selector(summaryTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTokens:(NSArray *)tokens
{
    _tokens = [tokens copy];
    if (tokens.count <= 0) {
        self.tokensSummaryLabel.hidden = YES;
        self.moreSummaryLabel.hidden = YES;
        return;
    }
    CGSize fittingSize = CGSizeMake(self.frame.size.width-(2.0*PADDING_X), self.frame.size.height-(2.0*PADDING_Y));

    NSInteger moreTokens = tokens.count - 1;
    CGSize moreLabelSize = CGSizeZero;
    if (moreTokens > 0) {
        // estimate how big the 'more' label will be based on the max number it could be
        self.moreSummaryLabel.text = [NSString stringWithFormat:@" & %ld more", (long)moreTokens];
        moreLabelSize = [self.moreSummaryLabel sizeThatFits:fittingSize];
    }

    // figure out how many tokens can fit
    CGFloat tokenFittingWidth = fittingSize.width - moreLabelSize.width;
    NSString *testTokenString = @"";
    NSString *finalTokenString = nil;
    CGFloat actualTokenLabelWidth = tokenFittingWidth;
    NSInteger numDisplayedTokens = 0;
    CGFloat totalWidth = 0;
    for (NSObject *token in tokens) {
        if ([token isKindOfClass:[CLToken class]]) {
            CLToken *clToken = (CLToken*)token;
            NSString *displayText = clToken.displayText;
            if (numDisplayedTokens > 0) {
                // prepend a spacer between tokens if not the first
                displayText = [@", " stringByAppendingString:displayText];
            }
            testTokenString = [testTokenString stringByAppendingString:displayText];
            CGRect r = [displayText boundingRectWithSize:CGSizeMake(tokenFittingWidth, fittingSize.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                 attributes:@{NSFontAttributeName:self.font}
                                                 context:nil];
            if (numDisplayedTokens == 0 || totalWidth + r.size.width <= tokenFittingWidth) {
                finalTokenString = [testTokenString copy];
                totalWidth += r.size.width;
                numDisplayedTokens++;
            }
            actualTokenLabelWidth = totalWidth;
        }
    }
    if (finalTokenString) {
        self.tokensSummaryLabel.hidden = NO;
        self.tokensSummaryLabel.text = [finalTokenString copy];
        self.tokensSummaryLabel.frame = CGRectMake(PADDING_X,PADDING_Y, actualTokenLabelWidth, fittingSize.height);
    }
    if (numDisplayedTokens < tokens.count) {
        // update the more label with the actual number of 'more' tokens
        self.moreSummaryLabel.text = [NSString stringWithFormat:@" & %ld more", (long)(tokens.count - numDisplayedTokens)];
        self.moreSummaryLabel.frame = CGRectMake(self.tokensSummaryLabel.frame.origin.x + self.tokensSummaryLabel.frame.size.width, PADDING_Y, moreLabelSize.width, fittingSize.height);
        self.moreSummaryLabel.hidden = NO;
    } else {
        self.moreSummaryLabel.hidden = YES;
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    // if the frame changes, trigger a recalculation of the token summary (ie. device rotation)
    self.tokens = self.tokens;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.tokensSummaryLabel.textColor = tintColor;
    self.moreSummaryLabel.textColor = tintColor;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    self.tokensSummaryLabel.font = font;
    self.moreSummaryLabel.font = font;
}

- (void)summaryTouched:(id)sender
{
    [self.delegate tokenSummaryViewPressed];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // consume tap recognizers conflicting with this view
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer*)gestureRecognizer;
        if (tapRecognizer.numberOfTapsRequired == 1 && tapRecognizer.numberOfTouchesRequired == 1) {
            return NO;
        }
    }
    return YES;
}

@end
