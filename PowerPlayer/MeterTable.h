//
//  MeterTable.h
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-10.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeterTable : NSObject
{
    float mMinDecibels;
	float mDecibelResolution;
	float mScaleFactor;
	float *mTable;
}

- (float)valueAt:(float)inDecibels;

@end
