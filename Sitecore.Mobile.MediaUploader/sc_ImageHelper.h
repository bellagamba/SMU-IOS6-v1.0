//
//  sc_ImageHelper.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 8/4/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sc_ImageHelper : NSObject
+ (CGFloat)getCompressionFactor:(int) uploadImageSize;
+ (UIImage *)resizeImageToSize:(UIImage*) image uploadImageSize:(int) uploadImageSize;
+ (void)saveUploadImageSize:(int) uplaodImageSize;
+ (int) loadUploadImageSize;
+ (NSString *)formatLocation:(CLPlacemark *)placemark;
+ (UIImage *)getVideoThumbnail:(NSURL *) videoUrl;
+ (NSString *)getUUID;

@end
