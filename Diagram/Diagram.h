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
@property (nonatomic) IBInspectable NSString* diagramData;

@property (nonatomic) IBInspectable BOOL fillWidth;
@property (nonatomic) IBInspectable BOOL fillHeight;

@property (nonatomic) float barWidth;
@property (nonatomic) float barGap;

@property (nonatomic) float offsetX;
@property (nonatomic) float offsetY;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *frameColor;
@property (nonatomic) UIColor *barColor;


@end
