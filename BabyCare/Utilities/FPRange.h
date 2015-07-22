//
//  FPRange.h
//  BabyCare
//
//  Created by Chuang HsuanChih on 11/7/14.
//  Copyright (c) 2014 Qiwo SmartLink Technology Ltd. All rights reserved.
//

#ifndef BabyCare_FPRange_h
#define BabyCare_FPRange_h

typedef struct FPRange {
    float location;
    float length;
} FPRange;

typedef FPRange *FPRangePointer;

NS_INLINE FPRange FPMakeRange(float loc, float len) {
    FPRange r;
    r.location = loc;
    r.length = len;
    return r;
}

NS_INLINE double FPMaxRange(FPRange range) {
    return (range.location + range.length);
}

NS_INLINE BOOL FPLocationInRange(float loc, FPRange range) {
    return (!(loc < range.location) && (loc - range.location) < range.length) ? YES : NO;
}

NS_INLINE BOOL FPEqualRanges(FPRange range1, FPRange range2) {
    return (range1.location == range2.location && range1.length == range2.length);
}

#endif
