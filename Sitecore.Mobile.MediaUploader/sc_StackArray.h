//
//  sc_StackArray.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 7/30/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sc_StackArray : NSObject {
    NSMutableArray* stackArray;
}

@property  int count;

- (void)push:(id)item;
- (id)pop;
- (void)clear;

@end