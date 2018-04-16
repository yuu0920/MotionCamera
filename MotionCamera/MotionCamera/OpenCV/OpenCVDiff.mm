//
//  OpenCVDiff.m
//  openCVTest
//
//  Created by Yuu Tanimura on 2018/04/12.
//  Copyright © 2018年 Yuu Tanimura. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "OpenCVDiff.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@implementation OpenCVDiff

    - (NSArray<UIImage*> *)diff:(NSURL *)movieURL {
        
        NSArray* images = [OpenCVDiff sliceMovie:movieURL];
        cv::Mat base = [OpenCVDiff cvMatFromUIImage:images[0]];

        NSMutableArray<UIImage*>* diffs = [NSMutableArray arrayWithCapacity:10];
        for (UIImage* image in images) {
            cv::Mat comp = [OpenCVDiff cvMatFromUIImage:image];
            cv::Mat ret;
            cv::absdiff(comp, base, ret);
            ret = [OpenCVDiff convertBlackToAlpha:ret];
            [diffs addObject:[OpenCVDiff UIImageFromCVMat:ret]];
        }
        
        return diffs;
    }

    + (NSArray *)sliceMovie:(NSURL *)url {
        AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        if ( ! [asset tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
            NSLog(@"MovieUtil : ビデオタイプのファイルを指定して下さい [%@]", url);
            return nil;
        }
        
        AVAssetImageGenerator *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        [imageGen setAppliesPreferredTrackTransform:YES];
        
        // 動画から一定間隔毎に画像として切り出す
        // 動画再生時間
        NSMutableArray *images = [NSMutableArray new];
        Float64 durationSeconds = CMTimeGetSeconds([asset duration]);   // 動画の再生時間
//        Float64 interval = durationSeconds / 30;                        // 切り出す枚数
        Float64 interval = 0.1f;
        Float64 step = 0.f;
        CMTime midpoint;                                                // 切り出す位置
        CMTime actualTime;
        NSError *error = nil;
        CGImageRef imageRef;
        while (step < durationSeconds) {
            
            // 切り出し箇所の指定
            midpoint = CMTimeMakeWithSeconds(step, 30);
            
            // 切り出し
            imageRef = [imageGen copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
            
            // エラー有無
            if (error != nil) {
                // とりあえず続けてみる
                NSLog(@"MovieUtil : error [%@]", url);
                error = nil;
                continue;
            }
            
            // 切り出したものを保持
            [images addObject:[[UIImage alloc] initWithCGImage:imageRef]];
            
            // 解放
            CGImageRelease(imageRef);
            
            // つぎのぽいんとへ
            step += interval;
            
        }
        
        return images;
    }
    
    + (cv::Mat)cvMatFromUIImage:(UIImage *)image {
        CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
        CGFloat cols = image.size.width;
        CGFloat rows = image.size.height;
        
        cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
        
        CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                        cols,                       // Width of bitmap
                                                        rows,                       // Height of bitmap
                                                        8,                          // Bits per component
                                                        cvMat.step[0],              // Bytes per row
                                                        colorSpace,                 // Colorspace
                                                        kCGImageAlphaNoneSkipLast |
                                                        kCGBitmapByteOrderDefault); // Bitmap info flags
        
        CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
        CGContextRelease(contextRef);
        
        return cvMat;
    }

    + (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
        NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
        CGColorSpaceRef colorSpace;
        
        if (cvMat.elemSize() == 1) {
            colorSpace = CGColorSpaceCreateDeviceGray();
        } else {
            colorSpace = CGColorSpaceCreateDeviceRGB();
        }
        
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
        
        // Creating CGImage from cv::Mat
        CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                            cvMat.rows,                                 //height
                                            8,                                          //bits per component
                                            8 * cvMat.elemSize(),                       //bits per pixel
                                            cvMat.step[0],                            //bytesPerRow
                                            colorSpace,                                 //colorspace
                                            kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                            provider,                                   //CGDataProviderRef
                                            NULL,                                       //decode
                                            false,                                      //should interpolate
                                            kCGRenderingIntentDefault                   //intent
                                            );
        
        
        // Getting UIImage from CGImage
        UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpace);
        
        return finalImage;
    }
    
    + (cv::Mat)convertBlackToAlpha:(cv::Mat)blackImage {
        cv::Mat alpha_image = cv::Mat(blackImage.size(), CV_8UC3);
        cv::cvtColor(blackImage, alpha_image, CV_RGB2RGBA);
        for (int y = 0; y < alpha_image.rows; ++y) {
            for (int x = 0; x < alpha_image.cols; ++x) {
                cv::Vec4b px = alpha_image.at<cv::Vec4b>(x, y);
                if (px[0] + px[1] + px[2] == 0) {
                    px[3] = 0;
                    alpha_image.at<cv::Vec4b>(x, y) = px;
                }
            }
        }
        return alpha_image;
    }
@end
