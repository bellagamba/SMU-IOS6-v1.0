//
//  sc_Site.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/7/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sc_Site : NSObject
@property  NSString *index;
@property  NSString *siteUrl;
@property  NSString *uploadFolderPathInsideMediaLibrary;
@property  NSString *uploadFolderId;
@property  NSString *username;
@property  NSString *password;
@property  BOOL selectedForBrowse;
@property  BOOL selectedForUpdate;

-(id)initWithSiteUrl:(NSString *)siteUrl uploadFolderPathInsideMediaLibrary:(NSString *)uploadFolderPathInsideMediaLibrary uploadFolderId:(NSString *)uploadFolderId username:(NSString *)username password:(NSString *)password selectedForBrowse:(BOOL) selectedForBrowse selectedForUpdate:(BOOL) selectedForUpdate;

@end
