//
//  sc_SiteEditViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 7/26/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_SiteAddViewController.h"
#import "sc_SiteEditViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "sc_GlobalDataObject.h"
#import "sc_AppDelegateProtocol.h"
#import "sc_SettingsViewController.h"
#import "sc_Site.h"
#import "sc_GradientButton.h"
#import "sc_Constants.h"
#import "sc_UploadFolderViewController.h"
#import "sc_ActivityIndicator.h"
#import "sc_ErrorHelper.h"
#import "sc_ItemHelper.h"

@interface sc_SiteAddViewController ()
@property bool isRaised;
@property bool loggedIn;
@property UIView* loginFooterView;
@property sc_ActivityIndicator * activityIndicator;
@property UIView* footerView;
@end

@implementation sc_SiteAddViewController

//--------------------------------------------------------------------------------------------------------
// initWithStyle:
//--------------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//--------------------------------------------------------------------------------------------------------
// initializeActivityIndicator
//--------------------------------------------------------------------------------------------------------
- (void)initializeActivityIndicator {
    
    _activityIndicator = [[sc_ActivityIndicator alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_activityIndicator];
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------------------------------------------------
// slideFrameUp
//--------------------------------------------------------------------------------------------------------
-(IBAction) slideFrameUp;
{
    [self slideFrame:YES];
}

//--------------------------------------------------------------------------------------------------------
// slideFrameDown
//--------------------------------------------------------------------------------------------------------
-(IBAction) slideFrameDown;
{
    [self slideFrame:NO];
}

//--------------------------------------------------------------------------------------------------------
// slideFrame
//--------------------------------------------------------------------------------------------------------
-(void) slideFrame:(BOOL) up
{
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: SLIDE_FRAME_MOVEMENT_DURATION];
    self.view.frame = CGRectOffset(self.view.frame, 0, (up ? -SLIDE_FRAME_MOVEMENT_DISTANCE : SLIDE_FRAME_MOVEMENT_DISTANCE));
    [UIView commitAnimations];
}

//--------------------------------------------------------------------------------------------------------
// Helper to return the global data object
//--------------------------------------------------------------------------------------------------------
- (sc_GlobalDataObject*) getAppDataObject; {
    
    id<sc_AppDelegateProtocol> delegate = (id<sc_AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (sc_GlobalDataObject*) delegate.appDataObject;
}

//--------------------------------------------------------------------------------------------------------
// dismissKeyboardOnTap
//--------------------------------------------------------------------------------------------------------
-(IBAction)dismissKeyboardOnTap:(id)sender
{
    [[self view] endEditing:YES];
}

//--------------------------------------------------------------------------------------------------------
// initWithNibName
//--------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//--------------------------------------------------------------------------------------------------------
// viewDidLoad
//--------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Localize UI
    self.navigationItem.title = NSLocalizedString(self.navigationItem.title, nil);    
    _passwordTextField.placeholder = NSLocalizedString(_passwordTextField.placeholder, nil);
    _usernameTextField.placeholder = NSLocalizedString(_usernameTextField.placeholder, nil);
    _siteUrlTextField.placeholder = NSLocalizedString(_siteUrlTextField.placeholder, nil);
    
    [self initializeActivityIndicator];
    
    _appDataObject = [self getAppDataObject];
    
    _usernameTextField.delegate = self;
    _passwordTextField.delegate = self;
    _siteUrlTextField.delegate = self;
    
    self.navigationItem.hidesBackButton = YES;
    _saveButton.target = self;
    _saveButton.action = @selector(save:);
    _cancelButton.target = self;
    _cancelButton.action = @selector(cancel:);
    
    if (!_appDataObject.isOnline)
    {
        _saveButton.enabled = false;
    }
    
    _loggedIn = false;
}

//--------------------------------------------------------------------------------------------------------
// viewWillAppear
//--------------------------------------------------------------------------------------------------------
-(void) viewWillAppear:(BOOL)animated {
    
    [self configureView];
}

//--------------------------------------------------------------------------------------------------------
// configure View
//--------------------------------------------------------------------------------------------------------
- (void)configureView {
    
    _site = [[sc_Site alloc] initWithSiteUrl:@"" uploadFolderPathInsideMediaLibrary:@"" uploadFolderId:@"" username:@"" password:@"" selectedForBrowse:NO selectedForUpdate:YES];

    _siteUrlTextField.text = _site.siteUrl;
    _usernameTextField.text = _site.username;
    _passwordTextField.text = _site.password;    
}

//--------------------------------------------------------------------------------------------------------
// numberOfRowsInSection
//--------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


//--------------------------------------------------------------------------------------------------------
// isAuthenticated
//--------------------------------------------------------------------------------------------------------
- (void)authenticateAndSave:(NSString*) siteUrl username:(NSString*) username password:(NSString*) password uploadFolderPathInsideMediaLibrary:(NSString*) uploadFolderPathInsideMediaLibrary uploadFolderId:(NSString*) uploadFolderId selectedForUpload:(BOOL) selectedForUpload {
    
    sc_Site *tmpSite = [[sc_Site alloc] initWithSiteUrl:siteUrl uploadFolderPathInsideMediaLibrary:uploadFolderPathInsideMediaLibrary uploadFolderId:uploadFolderId username:username password:password selectedForBrowse:false selectedForUpdate:selectedForUpload];
    
    SCApiContext *context = [sc_ItemHelper getContext: tmpSite];
    SCItemsReaderRequest *request = [SCItemsReaderRequest new];
    request.requestType = SCItemReaderRequestItemId;
    request.request = MEDIA_LIBRARY_ID;
    SCAsyncOp asyncOp = [context itemsReaderWithRequest:request];
    
    [_activityIndicator showWithLabel:NSLocalizedString(@"Authenticating", nil)];
    
    asyncOp(^(id result, NSError *error)
            {
                [_activityIndicator hide];
                if (error == NULL) {
                    _site.siteUrl = siteUrl;
                    _site.uploadFolderPathInsideMediaLibrary = uploadFolderPathInsideMediaLibrary;
                    _site.uploadFolderId = uploadFolderId;
                    _site.username = username;
                    _site.password = password;
                    _site.selectedForUpdate = selectedForUpload;
                    
                    [_appDataObject addSite:_site];
                    [_appDataObject saveSites];
                    
                    _loggedIn = true;
                                        
                    sc_SiteEditViewController * siteEditViewController = (sc_SiteEditViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SiteEdit"];
                    [siteEditViewController setSite:_site isNew:true];
                    [self.navigationController pushViewController:siteEditViewController animated:YES];
                    
                }
                else {
                    [sc_ErrorHelper showError:@"Authentication failure."];
                }
            });
}

//--------------------------------------------------------------------------------------------------------
// cancel button pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


//--------------------------------------------------------------------------------------------------------
// login button pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) save:(id)sender {
    
    if(![self validateUrl:_siteUrlTextField.text])
    {
        [sc_ErrorHelper showError:@"Please enter a valid site url."];
        return;
    }
    
    if(_usernameTextField.text.length > 0 && _passwordTextField.text.length > 0)
    {
        [self authenticateAndSave:_siteUrlTextField.text
                  username:_usernameTextField.text
                  password: _passwordTextField.text
              uploadFolderPathInsideMediaLibrary: @""
            uploadFolderId: @""
         selectedForUpload: true];
    }
    else
    {
        [sc_ErrorHelper showError:@"Please enter username and password."];
    }
}

//--------------------------------------------------------------------------------------------------------
// textFieldShouldReturn
//--------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//--------------------------------------------------------------------------------------------------------
// shouldPerformSegueWithIdentifier
//--------------------------------------------------------------------------------------------------------
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
    return _loggedIn;
}

//--------------------------------------------------------------------------------------------------------
// validate Url
//--------------------------------------------------------------------------------------------------------
- (BOOL) validateUrl: (NSString *) url {
    if (url.length == 0)
    {
        return false;
    }
    
    NSURL* tmpUrl = [NSURL URLWithString:url];
    return !(tmpUrl == NULL);
}

//--------------------------------------------------------------------------------------------------------
// heightForFooterInSection
//--------------------------------------------------------------------------------------------------------
// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 80;
    }
    return 0;
}

//--------------------------------------------------------------------------------------------------------
// viewForFooterInSection
//--------------------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        if(_footerView == nil) {
            //allocate the view if it doesn't exist yet
            _footerView  = [[UIView alloc] init];
            
            int padding = 10;
            int fontSize = 18;
            int width = 136;
            if (_appDataObject.isIpad) {
                padding = 45;
                fontSize = 24;
                width = 260;
            }
   
            //create the button
            sc_GradientButton *button = [sc_GradientButton buttonWithType:UIButtonTypeCustom];
            
            [(sc_GradientButton*) button setButtonWithStyle:CUSTOMBUTTONTYPE_IMPORTANT];
            
            //the button should be as big as a table view cell
            [button setFrame:CGRectMake(tableView.frame.size.width- padding - width, 20, width, 45)];
            
            //set title, font size and font color
            [button setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
            
            //set action of the button
            [button addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
            
            //add the button to the view
            [_footerView addSubview:button];
        }
    }
    
    return _footerView;
}


@end

