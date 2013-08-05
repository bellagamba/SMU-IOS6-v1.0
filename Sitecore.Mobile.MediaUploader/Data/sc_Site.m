//
//  sc_Site.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/7/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_Site.h"
#import "sc_ImageHelper.h"

@implementation sc_Site

//--------------------------------------------------------------------------------------------------------
// initWithSiteUrl
//--------------------------------------------------------------------------------------------------------
-(id)initWithSiteUrl:(NSString *)siteUrl uploadFolderPathInsideMediaLibrary:(NSString *)uploadFolderPathInsideMediaLibrary uploadFolderId:(NSString *)uploadFolderId username:(NSString *)username password:(NSString *)password selectedForBrowse:(BOOL) selectedForBrowse selectedForUpdate:(BOOL) selectedForUpdate
{
    self = [super init];
    if (self)
    {
        _index = [sc_ImageHelper getUUID];
        _siteUrl = siteUrl;
        _uploadFolderPathInsideMediaLibrary = uploadFolderPathInsideMediaLibrary;
        _uploadFolderId = uploadFolderId;
        _username = username;
        _password = password;
        _selectedForBrowse = selectedForBrowse; 
        _selectedForUpdate = selectedForUpdate;
    }
    
    return self;
}

//--------------------------------------------------------------------------------------------------------
// encodeWithCoder
//--------------------------------------------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_index forKey:@"index"];
    [encoder encodeObject:_siteUrl forKey:@"siteUrl"];
    [encoder encodeObject:_uploadFolderPathInsideMediaLibrary forKey:@"uploadFolderPathInsideMediaLibrary"];
    [encoder encodeObject:_uploadFolderId forKey:@"uploadFolderId"];
    [encoder encodeObject:_username forKey:@"username"];
    [encoder encodeObject:_password forKey:@"password"];
    [encoder encodeBool:_selectedForBrowse forKey:@"selectedForBrowse"];
    [encoder encodeBool:_selectedForUpdate forKey:@"selectedForUpdate"];
}

//--------------------------------------------------------------------------------------------------------
// initWithCoder
//--------------------------------------------------------------------------------------------------------
-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        self.index = [decoder decodeObjectForKey:@"index"];
        self.siteUrl = [decoder decodeObjectForKey:@"siteUrl"];
        self.uploadFolderPathInsideMediaLibrary = [decoder decodeObjectForKey:@"uploadFolderPathInsideMediaLibrary"];
        self.uploadFolderId = [decoder decodeObjectForKey:@"uploadFolderId"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.selectedForBrowse = [decoder decodeBoolForKey:@"selectedForBrowse"];
        self.selectedForUpdate = [decoder decodeBoolForKey:@"selectedForUpdate"];
    }
    
    return self;
}


@end