//
//  Diagram.m
//  Diagram
//
//  Created by Christian Blomqvist on 2017-01-30.
//  Copyright © 2017 Christian Blomqvist. All rights reserved.
//

#import "Diagram.h"

@interface Diagram ()

@property (nonatomic) float viewWidth;
@property (nonatomic) float viewHeight;
@property (nonatomic) float maxBarHeight;
@property (nonatomic) float barScaleX;
@property (nonatomic) float barScaleY;
@property (nonatomic) float barShare;
@property (nonatomic) long barCount;

@end


@implementation Diagram

- (float)barShare {
    return 4.0f;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    self.offsetX = 0.0f;
    self.offsetY = 20.0f;
    
    self.viewWidth = rect.size.width - self.offsetX;
    self.viewHeight = rect.size.height - self.offsetY;
    
    self.maxBarHeight = 0.0f;
    self.barWidth = 80.0f;
    self.barGap = 5.0f;
    
    self.barScaleX = 1.0f;
    self.barScaleY = 1.0f;
    
    //self.fillWidth = NO;
    //self.fillHeight = NO;

    [self convertData];
    
    /*
    self.data = @[@{@"name": @"january", @"value": @100},
                  @{@"name": @"february", @"value": @80},
                  @{@"name": @"mars", @"value": @130},
                  @{@"name": @"april", @"value": @80},
                  @{@"name": @"maj", @"value": @20}];*/
    
    self.barCount = self.data.count;

    [self calculateBarDimensions];
    
    //Background
    CGRect background = CGRectMake(0,0,rect.size.width, rect.size.height);
    UIBezierPath *diagram = [UIBezierPath bezierPathWithRect:background];
    [[UIColor whiteColor] setFill];
    [diagram fill];

    //Draw bars
    [[UIColor blackColor] setStroke];
    float drawPosX = self.barGap + self.offsetX;
    float drawPosY;
    for (int i = 0; i < self.barCount; i ++) {
        drawPosY = self.viewHeight - ([self.data[i][@"value"] floatValue] * self.barScaleY);
        float drawWidth = self.barWidth * self.barScaleX;
        float drawHeight = [self.data[i][@"value"] floatValue] * self.barScaleY;
        
        CGRect barRect = CGRectMake(drawPosX, drawPosY, drawWidth, drawHeight);
        UIBezierPath *bar = [UIBezierPath bezierPathWithRect:barRect];
        if (i % 2 == 0)
            [[UIColor redColor] setFill];
        else
            [[UIColor blueColor] setFill];
        [bar fill];
        [bar stroke];
        
        //Get text
        NSString* text = self.data[i][@"name"];
        //Center text
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentCenter;
        NSDictionary *attribute = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
        //Draw text
        CGRect textBox = CGRectMake(drawPosX, self.viewHeight, drawWidth, self.offsetY);
        [text drawInRect:textBox withAttributes: attribute];
        
        drawPosX += self.barWidth + self.barGap;
    }
    
    //Axis
    CGMutablePathRef axisPath = CGPathCreateMutable();
    CGPathMoveToPoint(axisPath, NULL, self.offsetX, 0);
    CGPathAddLineToPoint(axisPath, NULL, self.offsetX, self.viewHeight);
    CGPathAddLineToPoint(axisPath, NULL, self.viewWidth, self.viewHeight);
    UIBezierPath *line = [UIBezierPath bezierPathWithCGPath:axisPath];
    [[UIColor blackColor] setStroke];
    line.lineWidth = 2;
    [line stroke];
    CGPathRelease(axisPath),
    
    //Outline
    [[UIColor blackColor] setStroke];
    //[diagram stroke];
}

- (void)calculateBarDimensions {
    [self calculateBarWidth];
    [self calculateBarHeight];
    
    if (((self.barGap +1) * self.barCount) + (self.barWidth * self.barCount) > self.viewWidth) {
        NSLog(@"Error: Content width exceeds view canvas.");
        NSLog(@"'fillWidth' activated.");
        self.fillWidth = YES;
        [self calculateBarWidth];
    }
}

- (void)calculateBarWidth {
    NSLog(@"calculateBarWidth");
    if (self.fillWidth) {
        self.barGap = ((self.viewWidth / self.barShare) / (self.barCount));
        self.barWidth = (self.viewWidth - (self.barGap * (self.barCount +1))) / (self.barCount);
    }
}

- (void)calculateBarHeight {
    NSLog(@"calculateBarHeight");
    if (!self.fillHeight)
        self.maxBarHeight = self.viewHeight;
    
    //NSLog(@"maxBarHeight Before: %f", self.maxBarHeight);
    for (int i = 0; i < self.barCount; i ++) {
        self.maxBarHeight = MAX(self.maxBarHeight, [self.data[i][@"value"] floatValue]);
        self.barScaleY = self.viewHeight / self.maxBarHeight;
    }
    
    //NSLog(@"maxBarHeight After: %f", self.maxBarHeight);
    //NSLog(@"barScaleY: %f", self.barScaleY);
}

- (void)setDiagramData:(NSString*) input {
    _diagramData = input;
    [self convertData];
}

- (void)convertData {
    NSMutableArray* newData = [[NSMutableArray alloc] init];
    NSMutableArray* components = [[self.diagramData componentsSeparatedByString:@","] mutableCopy];
    for (int i = 0; i < components.count; i ++) {
        NSLog(@"Index %d, before: '%@'", i, components[i]);
        components[i] = [components[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSLog(@"Index %d, after : '%@'", i, components[i]);
        NSLog(@"Index %d, length: %ld", i, (long) [components[i] length]);
        if ([components[i] length] == 0 || components[i] == nil) {
            [components removeObjectAtIndex:i];
            i--;
        }
    }
    NSLog(@"Array count %ld: ", (long) components.count);
    for (int i = 0; i < components.count; i ++) {
        NSDictionary *data = [self convertStringToTableData:components[i]];
        if (data) {
            [newData addObject:data];
        } else {
            NSLog(@"Bad data found in array!");
            self.data = [[NSArray alloc] init];
            return;
        }
    }
    self.data = newData;
    [self setNeedsDisplay];
    //NSArray *text = [self.data componentsSeparatedByString:@","];
}

- (NSDictionary*)convertStringToTableData:(NSString*)string {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    NSMutableArray *components = [[string componentsSeparatedByString:@"="] mutableCopy];
    for (int i = 0; i < components.count; i++) {
        components[0] = [components[0] stringByTrimmingCharactersInSet:set];
        if ([components[i] length] == 0 || components[i] == nil) {
            return nil;
        }
    }
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    format.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *value = [format numberFromString:components[1]];
    if (value) {
        NSLog(@"Conversion succeded, Name: '%@'   Value: %@",components[0], value);
        return @{@"name": components[0], @"value":value};
    } else {
        return nil;
    }
}

- (void)setData:(NSArray*)data {
    _data = data;
}

@end
