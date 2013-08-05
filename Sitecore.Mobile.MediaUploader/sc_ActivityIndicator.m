//
//  sc_ActivityIndicator.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by Steve Jennings on 7/24/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_ActivityIndicator.h"
#import "QuartzCore/QuartzCore.h"

@interface sc_ActivityIndicator()
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UILabel *loadingLabel;
@end

@implementation sc_ActivityIndicator


//--------------------------------------------------------------------------------------------------------
// initWithFrame
//--------------------------------------------------------------------------------------------------------
-(id) initWithFrame:(CGRect)frame {
        
    self = [super initWithFrame:CGRectMake((frame.size.width - 170) /2, (frame.size.height- 170) /2, 170, 170)];
    if( !self ) return nil;
    
    self.hidden=YES;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 10.0;
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.frame = CGRectMake(65, 40, _activityView.bounds.size.width, _activityView.bounds.size.height);
    [self addSubview:_activityView];
    
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    _loadingLabel.backgroundColor = [UIColor clearColor];
    _loadingLabel.textColor = [UIColor whiteColor];
    _loadingLabel.adjustsFontSizeToFitWidth = YES;
    _loadingLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview:_loadingLabel];
    [_activityView startAnimating];
    
    return self;
}

//--------------------------------------------------------------------------------------------------------
// showWithLabel:
//--------------------------------------------------------------------------------------------------------
-(void) showWithLabel: (NSString *)label {
    
    [self showWithLabel:label afterDelay:0];
}

//--------------------------------------------------------------------------------------------------------
// showWithLabel:afterDelay:
//--------------------------------------------------------------------------------------------------------
-(void) showWithLabel: (NSString *)label afterDelay: (float) wait {
    
    [self cancelAllRequests];
    _loadingLabel.text = label;
    [self performSelector:@selector(showActivityView) withObject:nil afterDelay:wait];
}

//--------------------------------------------------------------------------------------------------------
// showActivityView:
//--------------------------------------------------------------------------------------------------------
-(void) showActivityView {
    
    self.hidden = NO; 
}

//--------------------------------------------------------------------------------------------------------
// cancel
//--------------------------------------------------------------------------------------------------------
-(void) hide {
    
    [self cancelAllRequests];
    self.hidden=YES;
}

//--------------------------------------------------------------------------------------------------------
// cancelPreviousRequests
//--------------------------------------------------------------------------------------------------------
-(void) cancelAllRequests {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end