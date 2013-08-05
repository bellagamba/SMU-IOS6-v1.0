//
//  sc_SiteEditViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 7/26/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_SiteEditViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "sc_GlobalDataObject.h"
#import "sc_AppDelegateProtocol.h"
#import "sc_SettingsViewController.h"
#import "sc_Site.h"
#import "sc_ViewsHelper.h"
#import "sc_GradientButton.h"
#import "sc_Constants.h"
#import "sc_UploadFolderViewController.h"
#import "sc_SitesSelectionViewController.h"
#import "sc_ReloadableViewProtocol.h"
#import "sc_GradientButton.h"
#import "sc_ItemHelper.h"

@interface sc_SiteEditViewController ()
@property bool isRaised;
@property bool isNewSite;
@property UIView* footerView;
@end

@implementation sc_SiteEditViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------------------------------------------------
// reload
//--------------------------------------------------------------------------------------------------------
-(void) reload {
}


//--------------------------------------------------------------------------------------------------------
// Helper to return the global data object
//--------------------------------------------------------------------------------------------------------
- (sc_GlobalDataObject*) getAppDataObject; {
    
    id<sc_AppDelegateProtocol> delegate = (id<sc_AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (sc_GlobalDataObject*) delegate.appDataObject;
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
    _headerLabelEnabled.text = NSLocalizedString(_headerLabelEnabled.text, nil);
    
    _appDataObject = [self getAppDataObject];
    
    self.navigationItem.hidesBackButton = YES;
    _doneButton.target = self;
    _doneButton.action = @selector(save:);
    _cancelButton.target = self;
    _cancelButton.action = @selector(goBack:);
}

//--------------------------------------------------------------------------------------------------------
// viewWillAppear
//--------------------------------------------------------------------------------------------------------
-(void) viewWillAppear:(BOOL)animated {

    [self configureView];
}

//--------------------------------------------------------------------------------------------------------
// set Site
//--------------------------------------------------------------------------------------------------------
- (void)setSite:(sc_Site *) newSite isNew:(bool) isNew {
    
    _isNewSite = isNew;
    if (_site != newSite) {
        _site = newSite;
    }
}

//--------------------------------------------------------------------------------------------------------
// configure View
//--------------------------------------------------------------------------------------------------------
- (void)configureView {
    
    // Update the user interface for the detail item.
    sc_Site *tmpSite = _site;
    
    if (tmpSite) {
        _siteUrlLabel.text = tmpSite.siteUrl;
        [self setUploadMediaFolder:tmpSite.uploadFolderPathInsideMediaLibrary withId:tmpSite.uploadFolderId];
        _site.uploadFolderId = tmpSite.uploadFolderId;
        _selectedForUploadSwitch.On = tmpSite.selectedForUpdate;
    }
}

//--------------------------------------------------------------------------------------------------------
// viewWillDisappear
//--------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        [self save:nil];
        [sc_ViewsHelper reloadParentController:self.navigationController levels:1];
    }
}

//--------------------------------------------------------------------------------------------------------
// isAuthenticated
//--------------------------------------------------------------------------------------------------------
- (void)goBack:(id)sender {
    int levels = 2;
    if (_isNewSite) {
        [self dismissViewControllerAnimated:YES completion:nil];
        levels = 3;
    }
    
    UIViewController * viewController = [sc_ViewsHelper reloadParentController:self.navigationController levels:levels];
    if (viewController != nil) {
        [self.navigationController popToViewController:viewController animated:YES];
    }
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
        
        asyncOp(^(id result, NSError *error)
                {
                    if (error == NULL) {
                        _site.uploadFolderPathInsideMediaLibrary = uploadFolderPathInsideMediaLibrary;
                        _site.uploadFolderId = uploadFolderId;
                        _site.selectedForUpdate = selectedForUpload;
                        
                        [_appDataObject saveSites];
                        
                        [self goBack:nil];
                    }
                    else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Authentication failure.", nil) delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show];
                        [alert show];
                    }
                });
}

//--------------------------------------------------------------------------------------------------------
// save button pushed
//--------------------------------------------------------------------------------------------------------
- (void) save:(id)sender {
    [self authenticateAndSave:_site.siteUrl
              username: _site.username
              password: _site.password
          uploadFolderPathInsideMediaLibrary: _site.uploadFolderPathInsideMediaLibrary
        uploadFolderId: _site.uploadFolderId
     selectedForUpload: _selectedForUploadSwitch.isOn];
}

//--------------------------------------------------------------------------------------------------------
// textFieldShouldReturn
//--------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

//--------------------------------------------------------------------------------------------------------
// setUploadMediaFolder
//--------------------------------------------------------------------------------------------------------
- (void) setUploadMediaFolder:(NSString*) folder withId: (NSString*) folderId {
    
    _site.uploadFolderPathInsideMediaLibrary = folder;
    _site.uploadFolderId = folderId;
    folder = [sc_ItemHelper formatUploadFolder:_site];
    _choosenFolderLabel.text = folder;
}

//--------------------------------------------------------------------------------------------------------
// prepareForSegue
//--------------------------------------------------------------------------------------------------------
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UploadFolder"])
    {
        sc_UploadFolderViewController* destinationController = (sc_UploadFolderViewController * ) segue.destinationViewController;
        [destinationController setSite:_site];
    }
}

//--------------------------------------------------------------------------------------------------------
// didSelectRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//--------------------------------------------------------------------------------------------------------
// validate Url
//--------------------------------------------------------------------------------------------------------
- (BOOL) validateUrl: (NSString *) candidate {
    NSURL* url = [NSURL URLWithString:candidate];
    return !(url == NULL);
}

//--------------------------------------------------------------------------------------------------------
// heightForFooterInSection
//--------------------------------------------------------------------------------------------------------
// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 80;
    }
    return 0;
}

//--------------------------------------------------------------------------------------------------------
// viewForFooterInSection
//--------------------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
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
            
            [(sc_GradientButton*) button setButtonWithStyle:CUSTOMBUTTONTYPE_DANGEROUS];
            
            //the button should be as big as a table view cell
            [button setFrame:CGRectMake(padding, 35, width, 45)];

            //set title, font size and font color
            [button setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
            
            //set action of the button
            [button addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
            
            //add the button to the view
            [_footerView addSubview:button];
        }
    }

    return _footerView;
}


//--------------------------------------------------------------------------------------------------------
// delete button pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) delete:(id)sender {

    [_appDataObject deleteSite:_site];
    [_appDataObject saveSites];
    
    [sc_ViewsHelper reloadParentController:self.navigationController levels:2];
    [self.navigationController popViewControllerAnimated:YES];
}

//--------------------------------------------------------------------------------------------------------
// dismissKeyboardOnTap
//--------------------------------------------------------------------------------------------------------
-(IBAction)dismissKeyboardOnTap:(id)sender
{
    [[self view] endEditing:YES];
}

@end

