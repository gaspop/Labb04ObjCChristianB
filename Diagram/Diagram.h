//
//  Diagram.h
//  Diagram
//
//  Created by Christian Blomqvist on 2017-01-30.
//  Copyright © 2017 Christian Blomqvist. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface Diagram : UIView

@property (nonatomic) NSArray* data;

@property (nonatomic) float barWidth;
@property (nonatomic) float barHeight;
@property (nonatomic) float barGap;

@property (nonatomic) float viewWidth;
@property (nonatomic) float viewHeight;

@property (nonatomic) float offsetX;
@property (nonatomic) float offsetY;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *frameColor;
@property (nonatomic) UIColor *barColor;


@end
