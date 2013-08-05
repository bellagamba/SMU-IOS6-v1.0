//
//  sc_ConnectivityHelper.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 8/4/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_ConnectivityHelper.h"

@implementation sc_ConnectivityHelper

//--------------------------------------------------------------------------------------------------------
// connectedToInternet
//--------------------------------------------------------------------------------------------------------
+ (BOOL)connectedToInternet
{
    // Ideally, we would use something like Apple's Reachability class here. However that requires us to
    // #import <SystemConfiguration/SystemConfiguration.h>
    // which is incompatible with the current Sitecore SDK
    
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    return ([response statusCode]==200)?YES:NO;
}


@end
