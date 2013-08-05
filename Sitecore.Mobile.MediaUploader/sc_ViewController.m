//
//  sc_ViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/2/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_ViewController.h"
#import "sc_GlobalDataObject.h"
#import "sc_AppDelegateProtocol.h"
#import"sc_Upload2ViewController.h"
#import "sc_GradientButton.h"

@interface sc_ViewController ()
@property sc_GlobalDataObject *appDataObject;
@property UIAlertView *noConnectionAlert;
@property UIAlertView *pendingMediaAlert;
@end

@implementation sc_ViewController

//--------------------------------------------------------------------------------------------------------
// viewDidDisappear
//--------------------------------------------------------------------------------------------------------
-(void) viewDidDisappear {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

//--------------------------------------------------------------------------------------------------------
// reload selected site for browse
//--------------------------------------------------------------------------------------------------------
-(void) reload {
    
    [self enableApplication];
}

//--------------------------------------------------------------------------------------------------------
// Helper to return the global data object
//--------------------------------------------------------------------------------------------------------
- (sc_GlobalDataObject*) getAppDataObject; {
    
    id<sc_AppDelegateProtocol> delegate = (id<sc_AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (sc_GlobalDataObject*) delegate.appDataObject;
}

//--------------------------------------------------------------------------------------------------------
// enableApplication
//--------------------------------------------------------------------------------------------------------
- (void)enableApplication {
    
    _messageLabel.text = @"";
    _pendingButton.enabled = false;
    _pendingView.hidden = true;
    
    if (!_appDataObject.isOnline)
    {
        _browseButton.enabled = false;
        _settingsButton.enabled = false;
        _messageLabel.text = NSLocalizedString(@"Please check your internet connection.", nil);
        
        if (_appDataObject.sites.count == 0)
        {
            _uploadButton.enabled = false;
        }
        return;
    }
    
    _uploadButton.enabled = true;
    _settingsButton.enabled = true;
    
    if (_appDataObject.sites.count == 0)
    {
        _browseButton.enabled = false;
        _uploadButton.enabled = false;
        _messageLabel.text = NSLocalizedString(@"Please set up at least one upload site.", nil);
    }
    else {
        _browseButton.enabled = true;
        _uploadButton.enabled = true;
        
        if (_appDataObject.mediaUpload.count > 0 && _appDataObject.isOnline)
        {
            //_pendingView.hidden = false;
            _pendingButton.enabled = true;
            _pendingView.hidden = false;
            _pendingCounterLabel.text = [NSString stringWithFormat:@"%d", _appDataObject.mediaUpload.count];
        }
    }
}

//--------------------------------------------------------------------------------------------------------
// viewDidLoad
//--------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    _appDataObject = [self getAppDataObject];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableApplication) name:UIApplicationWillEnterForegroundNotification object:nil];
    [(sc_GradientButton*) _uploadButton setButtonWithStyle:CUSTOMBUTTONTYPE_NORMAL];
    [(sc_GradientButton*) _browseButton setButtonWithStyle:CUSTOMBUTTONTYPE_NORMAL];
    [(sc_GradientButton*) _pendingButton setButtonWithStyle:CUSTOMBUTTONTYPE_NORMAL];
    
    //Localize buttons
    [_uploadButton setTitle:NSLocalizedString(@"Upload", nil) forState:UIControlStateNormal];
    [_browseButton setTitle:NSLocalizedString(@"Browse", nil) forState:UIControlStateNormal];
    [_pendingButton setTitle:NSLocalizedString(@"Pending", nil) forState:UIControlStateNormal];
}

//--------------------------------------------------------------------------------------------------------
// viewWillAppear
//--------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
    [self enableApplication];
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
