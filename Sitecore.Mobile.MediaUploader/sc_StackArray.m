//
//  sc_StackArray.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 7/30/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_StackArray.h"

@implementation sc_StackArray
- (id)init
{
    if( self=[super init] )
    {
        stackArray = [[NSMutableArray alloc] init];
        _count = 0;
    }
    return self;
}

- (void)push:(id)anObject
{
    [stackArray addObject:anObject];
    _count = stackArray.count;
}

- (id)pop
{
    id obj = nil;
    if(stackArray.count > 0)
    {
        obj = [stackArray objectAtIndex:0];
        [stackArray removeObjectAtIndex:0];
        _count = stackArray.count;
    }
    return obj;
}

- (void)clear
{
    [stackArray removeAllObjects];
    _count = 0;
}

@end