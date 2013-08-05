//
//  sc_ImageHelper.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 8/4/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_ImageHelper.h"
#import "sc_Constants.h"
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVAsset.h>

@implementation sc_ImageHelper
//--------------------------------------------------------------------------------------------------------
// getCompressionFactor
//--------------------------------------------------------------------------------------------------------
+ (CGFloat)getCompressionFactor:(int) uploadImageSize
{
    if (uploadImageSize == UPLODIMAGESIZE_ACTUAL) {
        return 1;
    }
    
    if (uploadImageSize == UPLODIMAGESIZE_MEDIUM) {
        return 0.8;
    }
    
    return 0.6;
}

//--------------------------------------------------------------------------------------------------------
// formatUploadFolder
//--------------------------------------------------------------------------------------------------------
+ (UIImage *)resizeImageToSize:(UIImage*) image uploadImageSize:(int) uploadImageSize
{
    if (uploadImageSize == UPLODIMAGESIZE_ACTUAL) {
        return image;
    }
    
    CGFloat targetWidth = 800;
	CGFloat targetHeight = 600;
    
    if (uploadImageSize == UPLODIMAGESIZE_MEDIUM) {
        targetWidth = 1024;
        targetHeight = 768;
    }
    
    if (image.size.width < image.size.height) {
        CGFloat tmphWidth = targetWidth;
        targetWidth = targetHeight;
        targetHeight = tmphWidth;
    }
    
	UIImage *newImage = nil;
    
	CGSize imageSize = image.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
    
    if ((width < targetWidth)  || (height > targetHeight)) {
        return image;
    }
	
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    scaledWidth  = width * scaleFactor;
    scaledHeight = height * scaleFactor;
    
    if (widthFactor < heightFactor) {
        thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
    } else if (widthFactor > heightFactor) {
        thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }
    
	UIGraphicsBeginImageContext(CGSizeMake(scaledWidth,scaledHeight));
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[image drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) NSLog(@"could not scale image");
	
	return newImage ;
}

//--------------------------------------------------------------------------------------------------------
// saveUploadImageSize
//--------------------------------------------------------------------------------------------------------
+ (void)saveUploadImageSize:(int) uplaodImageSize
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:uplaodImageSize forKey:@"UploadImageSize"];
    [defaults synchronize];
}

//--------------------------------------------------------------------------------------------------------
// loadUploadImageSize
//--------------------------------------------------------------------------------------------------------
+ (int) loadUploadImageSize
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey: @"UploadImageSize"];
}

//--------------------------------------------------------------------------------------------------------
// formatLocation
//--------------------------------------------------------------------------------------------------------
+ (NSString *)formatLocation:(CLPlacemark *)placemark {
    
    if(placemark == nil)
    {
        return NSLocalizedString(@"Location undefined", nil);
    }
    
    NSString * ISOcountryCode = placemark.ISOcountryCode;
    if (ISOcountryCode == nil)
    {
        ISOcountryCode = @"";
    }
    
    NSString *locality = placemark.locality;
    if (locality == nil)
    {
        locality = @"";
    }
    
    NSString *subLocality = placemark.subLocality;
    if (subLocality == nil)
    {
        subLocality = @"";
    }
    
    if(ISOcountryCode.length == 0 & locality.length == 0 && subLocality.length == 0)
    {
        return NSLocalizedString(@"Location undefined", nil);
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@", ISOcountryCode, locality, subLocality];
}

//--------------------------------------------------------------------------------------------------------
// getVideoThumbnail
//--------------------------------------------------------------------------------------------------------
+ (UIImage *)getVideoThumbnail:(NSURL *) videoUrl {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(0,60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage * thumbnail = [[UIImage alloc] initWithCGImage:imgRef];
    return thumbnail;
}

//--------------------------------------------------------------------------------------------------------
// getUUID
//--------------------------------------------------------------------------------------------------------
+(NSString *)getUUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}

@end
