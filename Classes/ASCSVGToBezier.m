//
//  ASCSVGToBezier.m
//  ASCSVGtoBezierDemo
//
//  Created by Aurélien Scelles on 07/04/2014.
//  Copyright (c) 2014 Aurélien Scelles. All rights reserved.
//

#import "ASCSVGToBezier.h"
@interface ASCSVGToBezier () <NSXMLParserDelegate>
@property (nonatomic,strong) BezierPathsBlock block;
@end
@implementation ASCSVGToBezier
{
	CGPoint _lastPoint;
	CGPoint _lastControlPoint;
	NSMutableArray *_bezierPaths;
    CGSize _svgSize;
}
+(void)SVGFile:(NSString *)svgFilePath toBezierPaths:(BezierPathsBlock)bezierPathsBlock
{
    ASCSVGToBezier *svgToBezier = [ASCSVGToBezier new];
    svgToBezier.block = bezierPathsBlock;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:svgFilePath]];
    [parser setDelegate:svgToBezier];
    [parser parse];
}
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	if (!_bezierPaths) {
		_bezierPaths = [NSMutableArray new];
	}
	[_bezierPaths removeAllObjects];
    _svgSize = CGSizeZero;
}
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (_block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _block(_bezierPaths,_svgSize);
        });
    }
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([[elementName lowercaseString] isEqualToString:@"svg"]) {
        _svgSize = CGSizeMake([attributeDict[@"width"] floatValue], [attributeDict[@"height"] floatValue]);
    }
	if ([[elementName lowercaseString] isEqualToString:@"path"]) {
		NSString *path = attributeDict[@"d"];
		path = [path stringByReplacingOccurrencesOfString:@" M" withString:@"|M"];
		path = [path stringByReplacingOccurrencesOfString:@" m" withString:@"|m"];
		path = [path stringByReplacingOccurrencesOfString:@" L" withString:@"|L"];
		path = [path stringByReplacingOccurrencesOfString:@" l" withString:@"|l"];
		path = [path stringByReplacingOccurrencesOfString:@" H" withString:@"|H"];
		path = [path stringByReplacingOccurrencesOfString:@" h" withString:@"|h"];
		path = [path stringByReplacingOccurrencesOfString:@" V" withString:@"|V"];
		path = [path stringByReplacingOccurrencesOfString:@" v" withString:@"|v"];
		path = [path stringByReplacingOccurrencesOfString:@" C" withString:@"|C"];
		path = [path stringByReplacingOccurrencesOfString:@" c" withString:@"|c"];
		path = [path stringByReplacingOccurrencesOfString:@" S" withString:@"|S"];
		path = [path stringByReplacingOccurrencesOfString:@" s" withString:@"|s"];
		path = [path stringByReplacingOccurrencesOfString:@" Z" withString:@"|z"];
		path = [path stringByReplacingOccurrencesOfString:@" z" withString:@"|z"];
		NSArray *pathElements = [path componentsSeparatedByString:@"|"];
		UIBezierPath *bezierPath = [UIBezierPath new];
		[pathElements enumerateObjectsUsingBlock: ^(NSString *pathElement, NSUInteger idx, BOOL *stop) {
		    NSArray *pathElementSeparate = [pathElement componentsSeparatedByString:@" "];
		    if ([[pathElementSeparate firstObject] isEqualToString:@"M"] && ([pathElementSeparate count] > 2)) {
		        _lastPoint = CGPointMake([pathElementSeparate[1] floatValue], [pathElementSeparate[2] floatValue]);
		        [bezierPath moveToPoint:_lastPoint];
			}
		    if ([[pathElementSeparate firstObject] isEqualToString:@"m"] && ([pathElementSeparate count] > 2)) {
		        _lastPoint = CGPointMake(_lastPoint.x + [pathElementSeparate[1] floatValue], _lastPoint.y + [pathElementSeparate[2] floatValue]);
		        [bezierPath moveToPoint:_lastPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"L"] && ([pathElementSeparate count] > 2)) {
		        _lastPoint = CGPointMake([pathElementSeparate[1] floatValue], [pathElementSeparate[2] floatValue]);
		        [bezierPath addLineToPoint:_lastPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"l"] && ([pathElementSeparate count] > 2)) {
		        _lastPoint = CGPointMake(_lastPoint.x + [pathElementSeparate[1] floatValue], _lastPoint.y + [pathElementSeparate[2] floatValue]);
		        [bezierPath addLineToPoint:_lastPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"H"] && ([pathElementSeparate count] > 1)) {
		        _lastPoint = CGPointMake([pathElementSeparate[1] floatValue], _lastPoint.y);
		        [bezierPath addLineToPoint:_lastPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"h"] && ([pathElementSeparate count] > 1)) {
		        _lastPoint = CGPointMake(_lastPoint.x + [pathElementSeparate[1] floatValue], _lastPoint.y);
		        [bezierPath addLineToPoint:_lastPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"V"] && ([pathElementSeparate count] > 1)) {
		        _lastPoint = CGPointMake(_lastPoint.x, [pathElementSeparate[1] floatValue] && ([pathElementSeparate count] > 1));
		        [bezierPath addLineToPoint:_lastPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"v"] && ([pathElementSeparate count] > 1)) {
		        _lastPoint = CGPointMake(_lastPoint.x, _lastPoint.y + [pathElementSeparate[1] floatValue]);
		        [bezierPath addLineToPoint:_lastPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"C"] && ([pathElementSeparate count] > 6)) {
		        CGPoint point1 = CGPointMake([pathElementSeparate[1] floatValue], [pathElementSeparate[2] floatValue]);
		        _lastControlPoint = CGPointMake([pathElementSeparate[3] floatValue], [pathElementSeparate[4] floatValue]);
		        _lastPoint = CGPointMake([pathElementSeparate[5] floatValue], [pathElementSeparate[6] floatValue]);
		        [bezierPath addCurveToPoint:_lastPoint controlPoint1:point1 controlPoint2:_lastControlPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"c"] && ([pathElementSeparate count] > 6)) {
		        CGPoint point1 = CGPointMake(_lastPoint.x + [pathElementSeparate[1] floatValue], _lastPoint.y + [pathElementSeparate[2] floatValue]);
		        _lastControlPoint = CGPointMake(_lastPoint.x + [pathElementSeparate[3] floatValue], _lastPoint.y + [pathElementSeparate[4] floatValue]);
		        _lastPoint = CGPointMake(_lastPoint.x + [pathElementSeparate[5] floatValue], _lastPoint.y + [pathElementSeparate[6] floatValue]);
		        [bezierPath addCurveToPoint:_lastPoint controlPoint1:point1 controlPoint2:_lastControlPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"S"] && ([pathElementSeparate count] > 4)) {
		        CGPoint point1 = CGPointMake(_lastPoint.x + (_lastPoint.x - _lastControlPoint.x), _lastPoint.y + (_lastPoint.y - _lastControlPoint.y));
		        _lastControlPoint = CGPointMake([pathElementSeparate[1] floatValue], [pathElementSeparate[2] floatValue]);
		        _lastPoint = CGPointMake([pathElementSeparate[3] floatValue], [pathElementSeparate[4] floatValue]);
		        [bezierPath addCurveToPoint:_lastPoint controlPoint1:point1 controlPoint2:_lastControlPoint];
			}
		    else if ([[pathElementSeparate firstObject] isEqualToString:@"s"] && ([pathElementSeparate count] > 4)) {
		        CGPoint point1 = CGPointMake(_lastPoint.x + (_lastPoint.x - _lastControlPoint.x), _lastPoint.y + (_lastPoint.y - _lastControlPoint.y));
		        _lastControlPoint = CGPointMake(_lastPoint.x + [pathElementSeparate[1] floatValue], _lastPoint.y + [pathElementSeparate[2] floatValue]);
		        _lastPoint = CGPointMake(_lastPoint.x + [pathElementSeparate[3] floatValue], _lastPoint.y + [pathElementSeparate[4] floatValue]);
		        [bezierPath addCurveToPoint:_lastPoint controlPoint1:point1 controlPoint2:_lastControlPoint];
			}
		    else if ([[[pathElementSeparate firstObject] lowercaseString] isEqualToString:@"z"]) {
		        [bezierPath closePath];
			}
		}];
		[_bezierPaths addObject:bezierPath];
	}
}

@end
