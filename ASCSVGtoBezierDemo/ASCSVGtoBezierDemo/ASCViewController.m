//
//  ASCViewController.m
//  ASCSVGtoBezierDemo
//
//  Created by Aurélien Scelles on 07/04/2014.
//  Copyright (c) 2014 Aurélien Scelles. All rights reserved.
//

#import "ASCViewController.h"
#import "ASCSVGToBezier.h"

@interface ASCViewController ()

@end

@implementation ASCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [ASCSVGToBezier SVGFile:[[NSBundle mainBundle] pathForResource:@"hello" ofType:@"svg"] toBezierPaths:^(NSArray *bezierPaths, CGSize svgSize) {
        CGFloat scale = 1;
        if (!CGSizeEqualToSize(svgSize, CGSizeZero)) {
            scale = (svgSize.width > svgSize.height) ? self.view.bounds.size.width / svgSize.width : self.view.bounds.size.height / svgSize.height;

        }
        CGFloat duration = 1;
       [bezierPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
           [obj applyTransform:CGAffineTransformMakeScale(scale, scale)];
           CAShapeLayer *objLayer = [CAShapeLayer layer];
           objLayer.path = obj.CGPath;
           
           // Set shape properties
           objLayer.strokeColor = [[UIColor blackColor] CGColor];
           objLayer.lineWidth = 1;
           objLayer.fillColor = [[UIColor blackColor] CGColor];
           [self.view.layer addSublayer:objLayer];
           
           [objLayer addAnimation:(
                                   {
                                       CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                                       pathAnimation.duration = duration/2;
                                       pathAnimation.beginTime = CACurrentMediaTime() + (idx*duration);
                                       pathAnimation.fillMode = kCAFillModeBackwards;
                                       pathAnimation.fromValue = @(0.0f);
                                       pathAnimation.toValue = @(1.0f);
                                       pathAnimation;
                                   })
                           forKey:@"strokeEnd"];
           
           [objLayer addAnimation:(
                                     {
                                         CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
                                         pathAnimation.duration = duration/2;
                                         pathAnimation.beginTime = CACurrentMediaTime() + (idx*duration) +duration/2;
                                         pathAnimation.fillMode = kCAFillModeBackwards;
                                         pathAnimation.fromValue = (id)[UIColor clearColor].CGColor;
                                         pathAnimation.toValue = (id)[UIColor blackColor].CGColor;
                                         pathAnimation;
                                     }) forKey:@"fillColor"];
       }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
