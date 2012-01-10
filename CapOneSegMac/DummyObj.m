//
//  DummyObj.m
//  CapOneSegMac
//
//  Created by 伊藤 祐輔 on 12/01/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DummyObj.h"

@interface DummyObj()
{
    NSString* _name;
}
@end

@implementation DummyObj

- (id)initWithCName:(const char *)ptr
{
    self = [super init];
    if (self) {
        _name = [NSString stringWithUTF8String:ptr];
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"%s, %@", __func__, _name);
}

@end
