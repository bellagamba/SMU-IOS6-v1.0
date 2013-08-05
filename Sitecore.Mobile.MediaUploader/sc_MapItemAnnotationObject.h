//
//  sc_MapItemAnnotationObject.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/27/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <AddressBook/AddressBook.h>
/**
 * Annotation object for all Map Items displayed after Local Search returns matches.
 */
@interface sc_MapItemAnnotationObject : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

// Title and SubTitle are required for MKAnnotation...
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

-(id)initUsingCoordinate:(CLLocationCoordinate2D)coordinate mapItemName:(NSString *)mapItemName;
-(id)initUsingCoordinate:(CLLocationCoordinate2D)coordinate mapItemName:(NSString *)mapItemName withOptionalSubTitle:(NSString *)subTitle;
@end