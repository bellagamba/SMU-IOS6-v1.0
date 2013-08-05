//
//  sc_Media.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/29/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sc_Media : NSObject
@property  NSString *index;
@property  UIImage *thumbnail;
@property  NSString *name;
@property  NSString *description;
@property  NSString *location;
@property  NSURL *videoUrl;
@property  NSURL *imageUrl;
@property  NSInteger status;



-(id)initWithObjectData:(NSString *)name
               location:(NSString *)location
               videoUrl:(NSURL *) videoUrl
               imageUrl:(NSURL *) imageUrl
                 status:(NSInteger)status
              thumbnail:(UIImage*) thumbnail;


@end