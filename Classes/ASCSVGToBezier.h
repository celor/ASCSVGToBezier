//
//  ASCSVGToBezier.h
//  ASCSVGtoBezierDemo
//
//  Created by Aurélien Scelles on 07/04/2014.
//  Copyright (c) 2014 Aurélien Scelles. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^BezierPathsBlock)(NSArray *bezierPaths,CGSize svgSize);
@interface ASCSVGToBezier : NSObject
+(void)SVGFile:(NSString *)svgFilePath toBezierPaths:(BezierPathsBlock)bezierPathsBlock;
@end
