//
//  sc_ViewController.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/2/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sc_ReloadableViewProtocol.h"

@interface sc_ViewController : UIViewController <sc_ReloadableViewProtocol>
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UIButton *browseButton;
@property (nonatomic, retain) IBOutlet UIButton *pendingButton;
@property (nonatomic, retain) IBOutlet UIButton *uploadButton;
@property (nonatomic, retain) IBOutlet UIButton *settingsButton;
@property (nonatomic, retain) IBOutlet UIView *pendingView;
@property (nonatomic, retain) IBOutlet UILabel *pendingCounterLabel;

@end
