//
//  sc_UploadItem.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 7/30/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_UploadItem.h"

@implementation sc_UploadItem

//--------------------------------------------------------------------------------------------------------
// initWithObjectData
//--------------------------------------------------------------------------------------------------------
-(id)initWithObjectData:(sc_Media *)mediaItem site:(sc_Site *)site data:(NSData *) data index:(int) index {
    self = [super init];
    if (self)
    {
        _mediaItem = mediaItem;
        _site = site;
        _data = data;
        _index = index;
        
    }
    
    return self;
}


@end
