//
//  sc_BrosweViewController.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/4/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sc_GlobalDataObject.h"
#import "sc_ReloadableViewProtocol.h"
#import "sc_FolderHierarchy.h"

@class sc_SiteDataController;

@interface sc_BrowseViewController : sc_FolderHierarchy <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, sc_ReloadableViewProtocol> {
    UIActivityIndicatorView *activityView;
    UIView *loadingView;
    UILabel *loadingLabel;
}

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) IBOutlet UILabel *currentPathLabel;
@property (nonatomic, retain) IBOutlet UILabel *singleSiteLabel;
@property (nonatomic, retain) IBOutlet UIButton *siteButton;
@property (nonatomic, retain) IBOutlet UILabel *siteLabel;
@property (nonatomic, retain) IBOutlet UIView *singleSiteBgView;
@property sc_GlobalDataObject *appDataObject;

-(void) reload;
@end
