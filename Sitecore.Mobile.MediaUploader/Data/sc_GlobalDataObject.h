//
//  sc_GlobaldataObject.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/8/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "sc_AppDataObject.h"
#import "sc_Site.h"
#import "sc_media.h"

@interface sc_GlobalDataObject : sc_AppDataObject
@property NSMutableArray *sites;
@property NSMutableArray *selectedForUploadsites;
@property CLPlacemark *selectedPlaceMark;
@property NSMutableArray *mediaUpload;
@property bool isIpad;
@property bool isOnline;

- (void) loadMediaUpload;
- (void) saveMediaUpload;
- (void) loadSites;
- (void) saveSites;
- (void) addSite:(sc_Site*) site;
- (void) addMediaUpload:(sc_Media*) media;
- (void) deleteSite:(sc_Site*) site;
- (void) initializeSites;
- (void) initializeMediaUpload;
- (NSUInteger)countOfList;
- (sc_Site *)objectInListAtIndex:(NSUInteger)theIndex;
- (NSUInteger)countOfSelectedForUploadList;
- (sc_Site *)objectInSelectedForUploadListAtIndex:(NSUInteger)theIndex;


@end
