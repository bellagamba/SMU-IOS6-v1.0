//
//  sc_ItemHelper.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 8/5/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_ItemHelper.h"
#import "sc_Site.h"
#import "sc_Constants.h"

@implementation sc_ItemHelper
//--------------------------------------------------------------------------------------------------------
// getDefaultDatabase
//--------------------------------------------------------------------------------------------------------
+ (NSString *)getDefaultDatabase {
    return @"master";
}

//--------------------------------------------------------------------------------------------------------
// getContext
//--------------------------------------------------------------------------------------------------------
+ (SCApiContext *)getContext:(sc_Site *) site {
    
    SCApiContext * context = [SCApiContext contextWithHost:
                              [NSString stringWithFormat:@"%@/-/item", site.siteUrl]
                                                     login: site.username
                                                  password: site.password];
    context.defaultDatabase = [self getDefaultDatabase];
    return context;
}

//--------------------------------------------------------------------------------------------------------
// formatUploadFolder
//--------------------------------------------------------------------------------------------------------
+ (NSString *)formatUploadFolder:(sc_Site *) site {
    if (site.uploadFolderPathInsideMediaLibrary.length == 0)
    {
        return MEDIA_LIBRARY_FOLDER;
    }
    return [NSString stringWithFormat: @"%@%@", MEDIA_LIBRARY_FOLDER_SLASH, site.uploadFolderPathInsideMediaLibrary];
}

//--------------------------------------------------------------------------------------------------------
// itemType
//--------------------------------------------------------------------------------------------------------
+ (NSString *) itemType: (SCItem *) item {
    
    if ([item.itemTemplate isEqualToString:@"System/Media/Media folder"] || [item.itemTemplate isEqualToString:@ "System/Main section"]) {
        return @"folder";
    }
    
    if ([item.itemTemplate isEqualToString:@"System/Media/Unversioned/Jpeg"] || [item.itemTemplate isEqualToString:@ "System/Media/Unversioned/Image"]) {
        return @"image";
    }
    
    return @"unknown item type";
}

//--------------------------------------------------------------------------------------------------------
// getPath
//--------------------------------------------------------------------------------------------------------
+ (NSString *) getPath: (NSString *) itemId {
    
    //remove { - } and add / to start
    return [NSString stringWithFormat:@"/%@", [[itemId componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"{-}"]] componentsJoinedByString: @""]];
}


//--------------------------------------------------------------------------------------------------------
// formatUploadFolder
//--------------------------------------------------------------------------------------------------------
+ (NSString *)generateItemName:(NSString *) fileName {
    
    NSDate *newDate;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:~ NSTimeZoneCalendarUnit fromDate:[NSDate date]];
    newDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    NSDateFormatter *dtF = [[NSDateFormatter alloc] init];
    [dtF setDateFormat:@"yyyyMMddhhmms"];
    return [NSString stringWithFormat: @"%@_%@", fileName, [dtF stringFromDate:newDate]];
}

@end
