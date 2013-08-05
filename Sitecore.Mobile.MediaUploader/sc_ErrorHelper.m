//
//  sc_ErrorHelper.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 8/4/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_ErrorHelper.h"

@implementation sc_ErrorHelper

//--------------------------------------------------------------------------------------------------------
// showError
//--------------------------------------------------------------------------------------------------------
+ (void) showError:(NSString*) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message: message delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show];
    [alert show];
}
@end
