//
//  sc_FolderHierarchy.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by Steve Jennings on 7/21/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_FolderHierarchy.h"
#import <SitecoreMobileSDK/SitecoreMobileSDK.h>
#import "SitecoreMobileSDK/SCApiContext.h"
#import "SitecoreMobileSDK/SCCreateMediaItemRequest.h"
#import "SitecoreMobileSDK/SCImageField.h"
#import "sc_QuickImageViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "sc_ActivityIndicator.h"
#import "sc_Site.h"
#import "sc_Constants.h"
#import "sc_ErrorHelper.h"
#import "sc_ConnectivityHelper.h"
#import "sc_ItemHelper.h"

@interface sc_FolderHierarchy ()
@property sc_ActivityIndicator * activityIndicator;
@end

@implementation sc_FolderHierarchy


/*
 {DAF085E8-602E-43A6-8299-038FF171349F} JPEG
 {F1828A2C-7E5D-4BBD-98CA-320474871548} IMAGE
 {E76ADBDF-87D1-4FCB-BA71-274F7DBF5670} MOVIE
 {FE5DD826-48C6-436D-B87A-7C4210C7413B} FOLDER
 */

//--------------------------------------------------------------------------------------------------------
// setSite
//--------------------------------------------------------------------------------------------------------
-(void) setSite:(sc_Site*) site {
    self.currentSite = site;
    [self initializeCurrentPaths:site];
}

//--------------------------------------------------------------------------------------------------------
// initializeActivityIndicator
//--------------------------------------------------------------------------------------------------------
- (void)initializeActivityIndicator {
    
    _activityIndicator = [[sc_ActivityIndicator alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_activityIndicator];
}

//--------------------------------------------------------------------------------------------------------
// itemTapped
//--------------------------------------------------------------------------------------------------------
-(void) itemTapped:(NSIndexPath *)indexPath {
    
    SCItem * scItem=[self.items objectAtIndex:indexPath.row];
    
    //Cell can show image or folder
    NSString * itemType = [sc_ItemHelper itemType:scItem];
    
    if ([itemType isEqualToString:@"folder"]) {
        
        [self setCurrentPaths: scItem];
        self.itemId = scItem.itemId;
        [self setCurrentPathLabelText];
        [self readContents];
    }
    else if ([itemType isEqualToString:@"image"]) {
        
        //Open image in quick view
        sc_QuickImageViewController *quickImageViewController = (sc_QuickImageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"sc_QuickImageViewController"];
        quickImageViewController.items = [self.items mutableCopy];
        quickImageViewController.selectedImage = indexPath.row;
        quickImageViewController.context = self.context;
        [self.navigationController pushViewController:quickImageViewController animated:YES];
    }
    
}

//--------------------------------------------------------------------------------------------------------
// setCurrentPaths
//--------------------------------------------------------------------------------------------------------
- (void) initializeCurrentPaths: (sc_Site *) site {
    
    NSString *currentFolder = site.uploadFolderPathInsideMediaLibrary;
    if ([currentFolder isEqualToString:@""]) {
        currentFolder = MEDIA_LIBRARY_FOLDER;
    }
    else {
        NSRange start = [currentFolder rangeOfString:@"/" options:NSBackwardsSearch];
        if (start.location != NSNotFound && start.location == 0)
        {
            currentFolder = [currentFolder substringFromIndex:start.length];
        }
    }

    _currentFolder = currentFolder;
    _currentPathInsideSitecore = [NSString stringWithFormat:@"%@%@", MEDIA_LIBRARY_FOLDER_SLASH, site.uploadFolderPathInsideMediaLibrary];
    _currentPathInsideMediaLibrary =  site.uploadFolderPathInsideMediaLibrary;
}

//--------------------------------------------------------------------------------------------------------
// setCurrentPaths
//--------------------------------------------------------------------------------------------------------
- (void) setCurrentPaths: (SCItem *) scItem {
    
    _currentFolder = scItem.displayName;
    _currentPathInsideSitecore = [self getPathInsideSitecore:scItem.path];
    _currentPathInsideMediaLibrary =  [self getPathInsideMediaLibrary: _currentPathInsideSitecore];
}

//--------------------------------------------------------------------------------------------------------
// setContext
//--------------------------------------------------------------------------------------------------------
- (void) setContext {
    
    _context = [sc_ItemHelper getContext: _currentSite];
}

//--------------------------------------------------------------------------------------------------------
// setStartingFolder
//--------------------------------------------------------------------------------------------------------
- (void) setStartingFolder {
    
    _itemId = MEDIA_LIBRARY_ID;
}

//--------------------------------------------------------------------------------------------------------
// currentItemId
//--------------------------------------------------------------------------------------------------------
- (NSString *) getCurrentItemId {
    
    return _itemId;
}

//--------------------------------------------------------------------------------------------------------
// removeSitecoreFromPath
//--------------------------------------------------------------------------------------------------------
- (NSString *) getPathInsideSitecore: (NSString *) path {
    
    //remove '/sitecore/' from begining of path
    return [path substringFromIndex:10];
}

//--------------------------------------------------------------------------------------------------------
// removeSitecoreFromPath
//--------------------------------------------------------------------------------------------------------
- (NSString *) getPathInsideMediaLibrary: (NSString *) path {
    
    //remove 'media library/' from begining of path
    NSString *parsedPath = path;
    NSRange start = [[path lowercaseString] rangeOfString:MEDIA_LIBRARY_FOLDER_SLASH];
    if (start.location != NSNotFound && start.location == 0)
    {
        parsedPath = [path substringFromIndex:start.length];
    }
    else {
        start = [[path lowercaseString] rangeOfString:MEDIA_LIBRARY_FOLDER];
        if (start.location != NSNotFound && start.location == 0)
        {
            
            parsedPath = [path substringFromIndex:start.length];
        }
    }
    
    return parsedPath;
}

//--------------------------------------------------------------------------------------------------------
// read Contents
//--------------------------------------------------------------------------------------------------------
- (void) readContents {
    
    SCItemsReaderRequest *request = [SCItemsReaderRequest new];
    request.requestType = SCItemReaderRequestItemId;
    request.flags = SCItemReaderRequestIngnoreCache; //SCItemReaderRequestReadFieldsValues;
    request.fieldNames = [NSSet setWithObjects: nil];
    request.request = self.itemId;
    request.scope = ([self.itemId isEqualToString:MEDIA_LIBRARY_ID]) ? SCItemReaderChildrenScope : SCItemReaderParentScope | SCItemReaderChildrenScope ;
    
    [_activityIndicator showWithLabel:NSLocalizedString(@"Loading...", nil) afterDelay:0.5];
    
    [self.context itemsReaderWithRequest: request](^(NSArray* result, NSError *error)
                                                   {
                                                        [_activityIndicator hide];
                                                       
                                                       if ( ![result objectAtIndex:0]) {
                                                           [sc_ErrorHelper showError: @"Server connectiion error."];
                                                           return;
                                                       }
                                                       
                                                       self.items=[self sortFolderFirst:[result mutableCopy]];
                                                       [self reloadCollection];
                                                   });
}

//--------------------------------------------------------------------------------------------------------
// sortFolderFirst
//--------------------------------------------------------------------------------------------------------
- (NSMutableArray*) sortFolderFirst: (NSMutableArray *) array {
    
    //Split into two arrays, one for folders, the other for images
    NSMutableArray *folderItems = [NSMutableArray array];
    NSMutableArray *imageItems = [NSMutableArray array];
    
    SCItem *item;
    for (item in array) {
        NSString * itemType = [sc_ItemHelper itemType:item];
        if ([itemType isEqualToString:@"folder"]) {
            [folderItems addObject:item];
        }
        else if ([itemType isEqualToString:@"image"]) {
            [imageItems addObject:item];
        }
    }
   return [self returnRequired:folderItems with:imageItems];
    
}

//--------------------------------------------------------------------------------------------------------
// return required array
//--------------------------------------------------------------------------------------------------------
- (NSMutableArray*) returnRequired: (NSMutableArray *) folderArray with: (NSMutableArray *) imageArray {
    
    //This method is overwritten in the sc_UploadFolderViewController subclass to return only folders
    [folderArray addObjectsFromArray: imageArray];
    return folderArray;
}

//--------------------------------------------------------------------------------------------------------
// Reload data into views
//--------------------------------------------------------------------------------------------------------
-(void) reloadCollection {
}

//--------------------------------------------------------------------------------------------------------
// setCurrentPathLabel
//--------------------------------------------------------------------------------------------------------
- (void)setCurrentPathLabelText {    
}

//--------------------------------------------------------------------------------------------------------
// setCurrentPathLabel
//--------------------------------------------------------------------------------------------------------
- (void)setDefaultSite {
}

//--------------------------------------------------------------------------------------------------------
// viewDidLoad
//--------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setDefaultSite];
    [self setContext];
    [self setStartingFolder];
    [self readContents];
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//-------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
