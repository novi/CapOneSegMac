//
//  DummyObj.h
//  CapOneSegMac
//
//  Created by 伊藤 祐輔 on 12/01/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DummyObj : NSObject

- (id)initWithName:(NSString*)string;
- (id)initWithCName:(const char*)ptr;

@end
