//
//  MeterTable.m
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-10.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "MeterTable.h"

@implementation MeterTable

double DbToAmp(double inDb)
{
	return pow(10., 0.05 * inDb);
}

- (id)init
{
    self = [super init];
    if (self)
    {
        mMinDecibels = -80.;
        mDecibelResolution = mMinDecibels / (400 - 1);
        mScaleFactor = 1. / mDecibelResolution;
    }
    
    mTable = (float*)malloc(400*sizeof(float));
    
	double minAmp = DbToAmp(mMinDecibels);
	double ampRange = 1. - minAmp;
	double invAmpRange = 1. / ampRange;
	
	double rroot = 1. / 2.0;
	for (size_t i = 0; i < 400; ++i)
    {
		double decibels = i * mDecibelResolution;
		double amp = DbToAmp(decibels);
		double adjAmp = (amp - minAmp) * invAmpRange;
		mTable[i] = pow(adjAmp, rroot);
	}
    
    return self;
}

- (float)valueAt:(float)inDecibels
{
    if (inDecibels < mMinDecibels) return  0.;
    if (inDecibels >= 0.) return 1.;
    int index = (int)(inDecibels * mScaleFactor);
    return mTable[index];
}


@end
