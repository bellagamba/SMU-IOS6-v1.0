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
#import "sc_ViewsHelper.h"
#import "sc_GradientButton.h"
#import <SitecoreMobileSDK/SitecoreMobileSDK.h>
#import "SitecoreMobileSDK/SCApiContext.h"
#import "SitecoreMobileSDK/SCCreateMediaItemRequest.h"
#import "SitecoreMobileSDK/SCImageField.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "sc_ItemHelper.h"

@interface sc_BrowseViewController ()
@end

@implementation sc_BrowseViewController

@synthesize appDataObject = _appDataObject;

//--------------------------------------------------------------------------------------------------------
// Helper to return the global data object
//--------------------------------------------------------------------------------------------------------
- (sc_GlobalDataObject*) getAppDataObject; {
    
    id<sc_AppDelegateProtocol> delegate = (id<sc_AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (sc_GlobalDataObject*) delegate.appDataObject;
}

//--------------------------------------------------------------------------------------------------------
// reload selected site for browse
//--------------------------------------------------------------------------------------------------------
-(void) reload {
    
    [self setCurrentPathLabelText];
    [self setStartingFolder];
    [self setDefaultSite];
    [self readContents];
}

//--------------------------------------------------------------------------------------------------------
// collectionView:didSelectItemAtIndexPath:
//--------------------------------------------------------------------------------------------------------
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self itemTapped:indexPath];
}
 
//--------------------------------------------------------------------------------------------------------
// collectionView
//--------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    SCImageView *cellImageView = (SCImageView *)[cell viewWithTag:100];
    UILabel *label = (UILabel *)[cell viewWithTag:80];
    UIActivityIndicatorView * cellActivityView = (UIActivityIndicatorView * ) [cell viewWithTag:33];
    
    cellImageView.contentMode = UIViewContentModeCenter;
    [cellImageView setImage:NULL];
    label.text = @"";
    cellActivityView.hidden=YES;
    
    SCItem * cellObject=[self.items objectAtIndex:indexPath.row];
    
    //Cell can be image, folder, or back arrow
    NSString * itemType = [sc_ItemHelper itemType:cellObject];
    
    if ([itemType isEqualToString:@"folder"]) {
        
        // We are changing folder, so we should cancel all pending async requests, which may otherwise still
        // arrive and update reused cells.
        // This cancels everything for the SDWebImageLibrary, but should be replaced by the cancelAll equivalent
        // from the SiteCore SDK when it becomes available.
        
        [[SDWebImageManager sharedManager] cancelAll];

        label.text = cellObject.displayName;
        
        //Change first item to up arrow if not in root
        if (indexPath.row == 0 && ![self.itemId isEqualToString:MEDIA_LIBRARY_ID])
        {
            [cellImageView setImage:[UIImage imageNamed: @"up.png"]];
        }
        else
        {
            [cellImageView setImage:[UIImage imageNamed: @"folder.png"]];

        }
    }    
    else if ([itemType isEqualToString:@"image"]) {
        
        cellImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        // Here, we are temporarily using the SDWebImage library https://github.com/rs/SDWebImage until we can
        // use the SiteCore SDK to request images from a specified db, of a given width and height, and cancel
        // the requests when browsing to a different folder
        
        int mw = cell.frame.size.width;
        int mh = cell.frame.size.height;
        NSString * db = [sc_ItemHelper getDefaultDatabase];
        NSString *imageURL=[NSString stringWithFormat:@"http://%@/~/media%@.ashx?db=%@&mw=%d&mh=%d", self.currentSite.siteUrl, [sc_ItemHelper getPath:cellObject.itemId], db, mw, mh];
        NSLog(@"Downloading image at %@",imageURL );
        cellActivityView.hidden=NO;
        [cellImageView setImageWithURL:[NSURL URLWithString:imageURL]
                      placeholderImage:nil
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                 cellActivityView.hidden=YES;
                             }];
        
        /*
        //Using the current SiteCore SDK we can request an image, but only a full-size one from the web database
        cellActivityView.hidden=NO;
        SCAsyncOp imageReader = [self.context imageLoaderForSCMediaPath: [sc_Common getPath:cellObject.itemId]];
        imageReader(^(id result, NSError *error)
                {
                    if (error == NULL) {
                        cellActivityView.hidden=YES;
                        [cellImageView setImage:result];
                    }
                    else
                    {
                       NSLog(@"%@",[error localizedDescription]);
                    }
                }
        
            );
        */
        
    }
    
    return cell;
}


//--------------------------------------------------------------------------------------------------------
// collectionView
//--------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.items count];
}

//--------------------------------------------------------------------------------------------------------
// setDefaultSite
//--------------------------------------------------------------------------------------------------------
- (void)setDefaultSite {
    bool anySelection = false;
    if (!_appDataObject.sites || _appDataObject.sites.count == 0) {
        _siteButton.hidden = true;
        _singleSiteLabel.hidden = false;
        _singleSiteLabel.text = NSLocalizedString(@"No sites defined", nil);
        return;
    }
    
    if (_appDataObject.sites.count == 1) {
        sc_Site* firstSite = ((sc_Site *)[_appDataObject.sites objectAtIndex:0]);
        firstSite.selectedForBrowse = true;
        [self setButtonTitle:firstSite];
        _siteButton.hidden = true;
        _singleSiteLabel.hidden = false;
        _singleSiteLabel.text = firstSite.siteUrl;
        self.currentSite = firstSite;
        return;
    }
    
    _siteButton.hidden = false;
    _singleSiteLabel.hidden = true;
    
    for (sc_Site *site in _appDataObject.sites) {
        if (site.selectedForBrowse) {
            [self setButtonTitle:site];
            self.currentSite = site;
            anySelection = true;
        }
    }
    
    if (!anySelection) {
        sc_Site* firstSite = ((sc_Site *)[_appDataObject.sites objectAtIndex:0]);
        firstSite.selectedForBrowse = true;
        self.currentSite = firstSite;
        [self setButtonTitle:firstSite];
    }
}


//--------------------------------------------------------------------------------------------------------
// setButtonTitle
//--------------------------------------------------------------------------------------------------------
- (void)setButtonTitle:(sc_Site *)site
{
    [self setButtonTitleWithName: site.siteUrl];
}

//--------------------------------------------------------------------------------------------------------
// setButtonTitle
//--------------------------------------------------------------------------------------------------------
- (void)setButtonTitleWithName:(NSString *) siteName
{
    _siteLabel.text = siteName;
}

//--------------------------------------------------------------------------------------------------------
// didSelectRow
//--------------------------------------------------------------------------------------------------------
- (void) didSelectRow:(sc_Site*)selectedSite
{
    for (sc_Site *site in _appDataObject.sites) {
        site.selectedForBrowse = false;
    }
    
    selectedSite.selectedForBrowse = true;
    
    [self setButtonTitle:selectedSite];
}

//--------------------------------------------------------------------------------------------------------
// Reload data into CollectionView
//--------------------------------------------------------------------------------------------------------
-(void) reloadCollection {
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
  
}

//--------------------------------------------------------------------------------------------------------
// setCurrentPathLabel
//--------------------------------------------------------------------------------------------------------
- (void)setCurrentPathLabelText {
    
    _currentPathLabel.text = self.currentPathInsideSitecore;
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
    self.navigationItem.title = NSLocalizedString(self.navigationItem.title, nil);
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Home", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationItem.backBarButtonItem = backButton;
    [_singleSiteBgView setBackgroundColor:LABEL_BG];
    [(sc_GradientButton*) _siteButton setButtonWithStyle:CUSTOMBUTTONTYPE_NORMAL];
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------------------------------------------------
// numberOfRowsInSection
//--------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        [sc_ViewsHelper reloadParentController:self.navigationController levels:1];
    }
}

//--------------------------------------------------------------------------------------------------------
// textFieldShouldReturn
//--------------------------------------------------------------------------------------------------------
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    return YES;
}

@end

