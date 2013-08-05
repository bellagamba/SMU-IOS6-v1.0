//
//  sc_UploadItem.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 7/30/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sc_Site.h"
#import "sc_Media.h"

@interface sc_UploadItem : NSObject

@property  sc_Media *mediaItem;
@property  sc_Site *site;
@property  NSData *data;
@property  int index;

-(id)initWithObjectData:(sc_Media *)mediaItem
               site:(sc_Site *)site
               data:(NSData *) data
               index:(int) index;

@end
