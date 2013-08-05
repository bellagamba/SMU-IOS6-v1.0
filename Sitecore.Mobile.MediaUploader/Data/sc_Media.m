//
//  sc_Media.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/29/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_Media.h"
#import "sc_Constants.h"
#import "sc_ImageHelper.h"

@interface sc_Media ()
@end

@implementation sc_Media

//--------------------------------------------------------------------------------------------------------
// initWithObjectData
//--------------------------------------------------------------------------------------------------------
-(id)initWithObjectData:(NSString *)name location:(NSString *)location videoUrl:(NSURL*)videoUrl imageUrl:(NSURL*)imageUrl status:(NSInteger)status thumbnail:(UIImage*) thumbnail
{
    self = [super init];
    if (self)
    {
        _index = [sc_ImageHelper getUUID];

        _name = name;
        _location = location;
        _videoUrl = videoUrl;
        _imageUrl = imageUrl;
        _status = status;
        _thumbnail = thumbnail;
        
    }
    
    return self;
}

//--------------------------------------------------------------------------------------------------------
// encodeWithCoder
//--------------------------------------------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_index forKey:@"index"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_location forKey:@"location"];
    [encoder encodeObject:_videoUrl forKey:@"videoUrl"];
    [encoder encodeObject:_imageUrl forKey:@"imageUrl"];
    [encoder encodeInteger:_status forKey:@"status"];
    [encoder encodeObject:_thumbnail forKey:@"thumbnail"];
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
        self.name = [decoder decodeObjectForKey:@"name"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.videoUrl = [decoder decodeObjectForKey:@"videoUrl"];
        self.imageUrl = [decoder decodeObjectForKey:@"imageUrl"];
        self.status = [decoder decodeIntegerForKey:@"status"];
        self.thumbnail = [decoder decodeObjectForKey:@"thumbnail"];
    }
    
    return self;
}


@end