//
//  sc_GlobaldataObject.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/8/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_GlobalDataObject.h"
#import "sc_Media.h"
#import "sc_Constants.h"

@implementation sc_GlobalDataObject
{
}

//--------------------------------------------------------------------------------------------------------
// initialize Sites
//--------------------------------------------------------------------------------------------------------
- (void) initializeSites
{
    [self loadSites];
}

//--------------------------------------------------------------------------------------------------------
// initialize Sites
//--------------------------------------------------------------------------------------------------------
- (void) initializeMediaUpload
{
    [self loadMediaUpload];
}

//--------------------------------------------------------------------------------------------------------
// Add site
//--------------------------------------------------------------------------------------------------------
- (void) addSite:(sc_Site*) site {
    [_sites addObject:site];
}

//--------------------------------------------------------------------------------------------------------
// Add mediaUpload
//--------------------------------------------------------------------------------------------------------
- (void) addMediaUpload:(sc_Media*) media {
    [_mediaUpload addObject:media];
}

//--------------------------------------------------------------------------------------------------------
// deleteSite
//--------------------------------------------------------------------------------------------------------
- (void) deleteSite:(sc_Site*) site {
    
    [_sites removeObject:site];
}

//--------------------------------------------------------------------------------------------------------
// Get setting file
//--------------------------------------------------------------------------------------------------------
- (NSString *)getSettingFile {
    return [self getFile:@"sites.txt"];
}

//--------------------------------------------------------------------------------------------------------
// Get MediaUpload file
//--------------------------------------------------------------------------------------------------------
- (NSString *)getMediaUploadFile {
    return [self getFile:@"mediaUpload.txt"];
}

//--------------------------------------------------------------------------------------------------------
// Get setting file
//--------------------------------------------------------------------------------------------------------
- (NSString *)getFile:(NSString*) fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    return appFile;
}


//--------------------------------------------------------------------------------------------------------
// Load sites
//--------------------------------------------------------------------------------------------------------
- (void) loadSites {
    
    NSString *appFile = [self getSettingFile];
    
    _sites = [NSKeyedUnarchiver unarchiveObjectWithFile:appFile];
    if (!_sites)
    {
        _sites = [[NSMutableArray alloc] init];
    }
    
    [self setSelecteForUploadSites];
}

//--------------------------------------------------------------------------------------------------------
// Load sites
//--------------------------------------------------------------------------------------------------------
- (void) loadMediaUpload {
    
    NSString *appFile = [self getMediaUploadFile];
    
    _mediaUpload = [NSKeyedUnarchiver unarchiveObjectWithFile:appFile];
    if (!_mediaUpload)
    {
        _mediaUpload = [[NSMutableArray alloc] init];
    }
}

//--------------------------------------------------------------------------------------------------------
// setSelecteForUploadSites
//--------------------------------------------------------------------------------------------------------
-(void) setSelecteForUploadSites {
    
    _selectedForUploadsites = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [_sites count]; ++i)
    {
        sc_Site *site = [_sites objectAtIndex:i];
        if (site.selectedForUpdate) {
            [_selectedForUploadsites addObject:site];
        }
    }
}

//--------------------------------------------------------------------------------------------------------
// Save sites
//--------------------------------------------------------------------------------------------------------
- (void) saveSites {
    
    [self setSelecteForUploadSites];
    NSString *appFile = [self getSettingFile];
    [NSKeyedArchiver archiveRootObject:_sites toFile:appFile];
}

//--------------------------------------------------------------------------------------------------------
// Save sites
//--------------------------------------------------------------------------------------------------------
- (void) saveMediaUpload {
    
    NSMutableArray *mediaItemstoRemove = [NSMutableArray arrayWithCapacity:_mediaUpload.count];
    for(sc_Media *media in  _mediaUpload)
    {

        if (media.status == MEDIASTATUS_UPLOADED || media.status == MEDIASTATUS_REMOVED)
        {
             [mediaItemstoRemove addObject:media];
        }
    }
    [_mediaUpload removeObjectsInArray:mediaItemstoRemove];
    
    NSString *appFile = [self getMediaUploadFile];
    [NSKeyedArchiver archiveRootObject:_mediaUpload toFile:appFile];
}

//--------------------------------------------------------------------------------------------------------
// countOfList
//--------------------------------------------------------------------------------------------------------
- (NSUInteger)countOfList {
    if(_sites == NULL)
    {
        return 0;
    }
    return [_sites count];
}

//--------------------------------------------------------------------------------------------------------
// objectInListAtIndex
//--------------------------------------------------------------------------------------------------------
- (sc_Site *)objectInListAtIndex:(NSUInteger)theIndex {
    if(_sites == NULL)
    {
        return NULL;
    }
    return [_sites objectAtIndex:theIndex];
}

//--------------------------------------------------------------------------------------------------------
// countOfList
//--------------------------------------------------------------------------------------------------------
- (NSUInteger)countOfSelectedForUploadList {
    if(_selectedForUploadsites == NULL)
    {
        return 0;
    }
    return [_selectedForUploadsites count];
}

//--------------------------------------------------------------------------------------------------------
// objectInListAtIndex
//--------------------------------------------------------------------------------------------------------
- (sc_Site *)objectInSelectedForUploadListAtIndex:(NSUInteger)theIndex {
    if(_selectedForUploadsites == NULL)
    {
        return NULL;
    }
    return [_selectedForUploadsites objectAtIndex:theIndex];
}



@end
