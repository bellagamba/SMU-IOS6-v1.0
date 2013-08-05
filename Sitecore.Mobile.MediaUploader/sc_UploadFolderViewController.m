//
//  sc_BrosweViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/4/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "sc_GlobalDataObject.h"
#import "sc_AppDelegateProtocol.h"
#import "sc_BrowseViewController.h"
#import "sc_QuickImageViewController.h"
#import "sc_SitesSelectionViewController.h"
#import "sc_Site.h"
#import "sc_Constants.h"
#import "sc_UploadFolderViewController.h"
#import "sc_SiteEditViewController.h"
#import <SitecoreMobileSDK/SitecoreMobileSDK.h>
#import "SitecoreMobileSDK/SCApiContext.h"
#import "SitecoreMobileSDK/SCCreateMediaItemRequest.h"
#import "SitecoreMobileSDK/SCImageField.h"
#import "sc_GradientButton.h"
#import "sc_ItemHelper.h"

@interface sc_UploadFolderViewController ()
@property NSString *startingUploadFolder;
@property NSString *startingFolderId;
@property UIView *headerView;
@end

@implementation sc_UploadFolderViewController

@synthesize activityView = _activityView;
@synthesize loadingView = _loadingView;
@synthesize loadingLabel = _loadingLabel;
@synthesize appDataObject = _appDataObject;

//--------------------------------------------------------------------------------------------------------
// setStartingFolder
//--------------------------------------------------------------------------------------------------------
- (void) setStartingFolder {
    
    if ([_startingFolderId isEqualToString:@""]){
        self.itemId = MEDIA_LIBRARY_ID;
    }
    else
    {
        self.itemId = _startingFolderId;
        self.currentPathInsideMediaLibrary = _startingUploadFolder;
    }
}

//--------------------------------------------------------------------------------------------------------
// setSite
//--------------------------------------------------------------------------------------------------------
-(void) setSite:(sc_Site*) site {
    [super setSite:site];
   
    _startingUploadFolder = site.uploadFolderPathInsideMediaLibrary;
    _startingFolderId = site.uploadFolderId;
}

//--------------------------------------------------------------------------------------------------------
// Helper to return the global data object
//--------------------------------------------------------------------------------------------------------
- (sc_GlobalDataObject*) getAppDataObject; {
    
    id<sc_AppDelegateProtocol> delegate = (id<sc_AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (sc_GlobalDataObject*) delegate.appDataObject;
}

//--------------------------------------------------------------------------------------------------------
// return required array
//--------------------------------------------------------------------------------------------------------
- (NSMutableArray*) returnRequired: (NSMutableArray *) folderArray with: (NSMutableArray *) imageArray {

    //Ignore images for folder picking
    return folderArray;
}

//--------------------------------------------------------------------------------------------------------
// tableView:didSelectRowAtIndexPath:
//--------------------------------------------------------------------------------------------------------
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self itemTapped:indexPath];
}

//--------------------------------------------------------------------------------------------------------
// tableView:cellForRowAtIndexPath:
//--------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    SCImageView *cellImageView = (SCImageView *)[cell viewWithTag:100];
    UILabel *label = (UILabel *)[cell viewWithTag:80];
    
    cellImageView.contentMode = UIViewContentModeCenter;
    [cellImageView setImage:NULL];
    label.text = @"";
    
    SCItem * cellObject=[self.items objectAtIndex:indexPath.row];
    
    //Cell can be image, folder, or back arrow
    NSString * itemType = [sc_ItemHelper itemType:cellObject];
    
    if ([itemType isEqualToString:@"folder"]) {
        
        label.text = cellObject.displayName;    
        
        if (indexPath.row == 0 && ![self.itemId isEqualToString:MEDIA_LIBRARY_ID])
        {
            [cellImageView setImage:[UIImage imageNamed: @"up_small.png"]];
        }
        else
        {
            [cellImageView setImage:[UIImage imageNamed: @"folder_small.png"]];
        }
    } 
    
    return cell;
}

//--------------------------------------------------------------------------------------------------------
// numberOfRows
//--------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UICollectionView *)view numberOfRowsInSection:(NSInteger)section {
    
    return [self.items count];
}

//--------------------------------------------------------------------------------------------------------
// Reload data into CollectionView
//--------------------------------------------------------------------------------------------------------
-(void) reloadCollection {
  
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

//--------------------------------------------------------------------------------------------------------
// setCurrentPathLabel
//--------------------------------------------------------------------------------------------------------
- (void)setCurrentPathLabelText {

    self.navigationItem.title = self.currentFolder;
    self.currentSite.uploadFolderPathInsideMediaLibrary = self.currentPathInsideMediaLibrary;
    self.currentSite.uploadFolderId = self.itemId;
}

//--------------------------------------------------------------------------------------------------------
// numberOfSectionsInCollectionView
//--------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return 1;
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
    
    _appDataObject = [self getAppDataObject];
    [self initializeActivityIndicator];
    [super viewDidLoad];
    
    //Localize UI
    _useButton.title = NSLocalizedString(_useButton.title, nil);
    _cancelButton.title =  NSLocalizedString(_cancelButton.title, nil);
    
    _useButton.target = self;
    _useButton.action = @selector(useButtonPushed:);
    
    _cancelButton.target = self;
    _cancelButton.action = @selector(cancelButtonPushed:);

    [self setCurrentPathLabelText];
}

//--------------------------------------------------------------------------------------------------------
// use putton pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) useButtonPushed:(id)sender {
    
    [self setCurrentPathLabelText];
    [self.navigationController popViewControllerAnimated:YES];
}

//--------------------------------------------------------------------------------------------------------
// cancel putton pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) cancelButtonPushed:(id)sender {
    
    self.currentSite.uploadFolderPathInsideMediaLibrary = _startingUploadFolder;
    self.currentSite.uploadFolderId = _startingFolderId;
    [self.navigationController popViewControllerAnimated:YES];
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
