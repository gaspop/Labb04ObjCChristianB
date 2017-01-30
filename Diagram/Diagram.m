//
//  Diagram.m
//  Diagram
//
//  Created by Christian Blomqvist on 2017-01-30.
//  Copyright © 2017 Christian Blomqvist. All rights reserved.
//

#import "Diagram.h"

@implementation Diagram


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    float offsetX = 0.0f;
    float offsetY = 0.0f;
    
    float viewWidth = rect.size.width - offsetX;
    float viewHeight = rect.size.height - offsetY;
    
    float maxBarHeight = 0.0f;
    float maxBarWidth = 30.0f;
    float maxBarGap = 10.0f;
    
    float barScaleX = 1.0f;
    float barScaleY = 1.0f;
    //float barGap =
    
    BOOL fillViewWidth = YES;
    BOOL fillViewHeight = NO;

    
    self.data = @[@{@"name": @"january", @"value": @100},
                  @{@"name": @"february", @"value": @80},
                  @{@"name": @"mars", @"value": @130},
                  @{@"name": @"april", @"value": @80},
                  ];
    
    if (fillViewWidth) {
        //self.data.count +1
        maxBarGap = ((viewWidth / 4.0) / (self.data.count));
        maxBarWidth = (viewWidth - (maxBarGap * (self.data.count +1))) / (self.data.count);
    }
    
    if (!fillViewHeight)
        maxBarHeight = viewHeight;
    
    NSLog(@"maxBarHeight Before: %f", maxBarHeight);
    for (int i = 0; i < self.data.count; i ++) {
        maxBarHeight = MAX(maxBarHeight, [self.data[i][@"value"] floatValue]);
        barScaleY = viewHeight / maxBarHeight;
    }
    
    NSLog(@"maxBarHeight After: %f", maxBarHeight);
    NSLog(@"barScaleY: %f", barScaleY);
    
    //Background
    CGRect background = CGRectMake(0,0,rect.size.width, rect.size.height);
    UIBezierPath *diagram = [UIBezierPath bezierPathWithRect:background];
    [[UIColor whiteColor] setFill];
    [diagram fill];

    float drawPosX = maxBarGap + offsetX;
    float drawPosY;
    for (int i = 0; i < self.data.count; i ++) {
        drawPosY = viewHeight - ([self.data[i][@"value"] floatValue] * barScaleY);
        float drawWidth = maxBarWidth * barScaleX;
        float drawHeight = [self.data[i][@"value"] floatValue] * barScaleY;
        CGRect barRect = CGRectMake(drawPosX, drawPosY, drawWidth, drawHeight);
        drawPosX += maxBarWidth + maxBarGap;
        
        UIBezierPath *bar = [UIBezierPath bezierPathWithRect:barRect];
        [[UIColor redColor] setFill];
        [bar fill];
    }
    
    //Axis
    CGMutablePathRef axisPath = CGPathCreateMutable();
    CGPathMoveToPoint(axisPath, NULL, offsetX, 0);
    CGPathAddLineToPoint(axisPath, NULL, offsetX, viewHeight);
    CGPathAddLineToPoint(axisPath, NULL, viewWidth, viewHeight);
    UIBezierPath *line = [UIBezierPath bezierPathWithCGPath:axisPath];
    line.lineWidth = 1;
    [line stroke];
    
    //Outline
    [[UIColor blackColor] setStroke];
    //[diagram stroke];
}

- (void)setData:(NSArray*)data {
    _data = data;
}

@end
