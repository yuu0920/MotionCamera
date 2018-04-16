//
//  OpenCVDiff.h
//  openCVTest
//
//  Created by Yuu Tanimura on 2018/04/12.
//  Copyright © 2018年 Yuu Tanimura. All rights reserved.
//

#ifndef OpenCVDiff_h
#define OpenCVDiff_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVDiff : NSObject
- (NSArray<UIImage*> *)diff:(NSURL *)movieURL;

@end

#endif /* OpenCVDiff_h */
