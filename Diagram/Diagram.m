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
@property (nonatomic) long maxTextLength;
@property (nonatomic) float maxBarHeight;
@property (nonatomic) float barScaleX;
@property (nonatomic) float barScaleY;
@property (nonatomic) float barShare;
@property (nonatomic) long barCount;

@end


@implementation Diagram

//NSArray* _barColors;

- (float)barWidth {
    if (_barWidth <= 0.0f)
        _barWidth = 20.0f;
    
    return _barWidth;
}
- (float)barSpacing {
    if (_barSpacing < 0.0f)
        _barSpacing = 0.0f;
    
    return _barSpacing;
}
- (float)barShare {
    return 4.0f;
}
/*
- (NSArray*)barColors {
    if (!_barColors) {
        _barColors = @[[UIColor redColor]];
    }
    
    return _barColors;
}
*/
- (void)setBarColors:(NSArray *)colors {
    if (!colors || ![colors[0] isKindOfClass:[UIColor class]]) {
        _barColors = @[[UIColor redColor]];
    }
    else
        _barColors = colors;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (void)initCommon {
    self.tableInput = @"År 1=2000, År 2=1760, År 3 =980, År 4=2250";
    self.fillWidth = YES;
    self.fillHeight = YES;
    self.barWidth = 20.0f;
    self.barSpacing = 10.0f;
    self.barColors = @[[UIColor redColor], [UIColor blueColor]];
    self.colorMode = FadeBetweenTwoColors;

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    self.offsetX = 0.0f;
    self.offsetY = 20.0f;
    
    self.viewWidth = rect.size.width - self.offsetX;
    self.viewHeight = rect.size.height - self.offsetY;
    
    self.maxBarHeight = 0.0f;
    self.barScaleX = 1.0f;
    self.barScaleY = 1.0f;
    
    //self.fillWidth = NO;
    //self.fillHeight = NO;
    
    self.barCount = self.data.count;

    [self calculateBarDimensions];
    [self calculateBarTextLength];
    
    //Background
    CGRect background = CGRectMake(0,0,rect.size.width, rect.size.height);
    UIBezierPath *diagram = [UIBezierPath bezierPathWithRect:background];
    [[UIColor whiteColor] setFill];
    [diagram fill];

    [self drawTableBars];
    //[self drawTableBarText];
    [self drawTableAxisLines];
}

- (UIColor*)pickTableBarColor:(int)fromBarIndex {
    if (self.colorMode == OneColor) {
        return self.barColors[0];
    }
    else if (self.colorMode == CycleThroughColors) {
        return self.barColors[fromBarIndex % self.barColors.count];
    }
    else if (self.colorMode == FadeBetweenTwoColors) {
        if (self.barCount <= 1 || self.barColors.count <= 1) {
            return self.barColors[0];
        }
        else {
            UIColor *startColor = self.barColors[0];
            UIColor *endColor = self.barColors[1];
            const CGFloat *startValues  = CGColorGetComponents(startColor.CGColor);
            const CGFloat *endValues = CGColorGetComponents(endColor.CGColor);
            double diffRed = endValues[0] - startValues[0];
            double diffGreen = endValues[1] - startValues[1];
            double diffBlue = endValues[2] - startValues[2];
            double scale = (fromBarIndex + 0.0f) / (self.barCount -1.0f);
            double red = startValues[0] + (diffRed * scale);
            double green = startValues[1] + (diffGreen * scale);
            double blue = startValues[2] + (diffBlue * scale);
            return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        }
    }
    return self.barColors[0];
}

- (void)drawTableBars {
    [[UIColor blackColor] setStroke];
    float drawPosX = self.barSpacing + self.offsetX;
    float drawPosY;
    for (int i = 0; i < self.barCount; i ++) {
        drawPosY = self.viewHeight - ([self.data[i][@"value"] floatValue] * self.barScaleY);
        float drawWidth = self.barWidth * self.barScaleX;
        float drawHeight = [self.data[i][@"value"] floatValue] * self.barScaleY;
        
        CGRect barRect = CGRectMake(drawPosX, drawPosY, drawWidth, drawHeight);
        UIBezierPath *bar = [UIBezierPath bezierPathWithRect:barRect];
        [[self pickTableBarColor: i] setFill];
        [bar fill];
        [bar stroke];
        
        NSString* text = self.data[i][@"name"];
        CGRect textRect = CGRectMake(drawPosX, self.viewHeight, drawWidth, self.offsetY);
        [self drawText:[text substringToIndex:MIN(text.length, self.maxTextLength)] inRect:textRect];
        
        drawPosX += self.barWidth + self.barSpacing;
    }
}

- (void)drawText:(NSString*)text inRect:(CGRect)rect {
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByClipping;
    NSDictionary *attribute = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
    
    CGSize size = [text sizeWithAttributes:attribute];
    CGRect newRect = CGRectMake(rect.origin.x,
                                rect.origin.y + (rect.size.height - size.height)/2,
                                rect.size.width,
                                size.height);
    [text drawInRect:newRect withAttributes:attribute];
}

- (void)drawTableAxisLines {
    CGMutablePathRef axisPath = CGPathCreateMutable();
    CGPathMoveToPoint(axisPath, NULL, self.offsetX, 0);
    CGPathAddLineToPoint(axisPath, NULL, self.offsetX, self.viewHeight);
    CGPathAddLineToPoint(axisPath, NULL, self.viewWidth, self.viewHeight);
    UIBezierPath *line = [UIBezierPath bezierPathWithCGPath:axisPath];
    [[UIColor blackColor] setStroke];
    line.lineWidth = 2;
    [line stroke];
    CGPathRelease(axisPath);
}

- (void)calculateBarDimensions {
    [self calculateBarWidth];
    [self calculateBarHeight];
    
    if (((self.barSpacing +1) * self.barCount) + (self.barWidth * self.barCount) > self.viewWidth) {
        NSLog(@"Error: Content width exceeds view canvas.");
        NSLog(@"'fillWidth' activated.");
        self.fillWidth = YES;
        [self calculateBarWidth];
    }
}

- (void)calculateBarWidth {
    NSLog(@"calculateBarWidth");
    if (self.fillWidth) {
        self.barSpacing = ((self.viewWidth / self.barShare) / (self.barCount));
        self.barWidth = (self.viewWidth - (self.barSpacing * (self.barCount +1))) / (self.barCount);
    }
}

- (void)calculateBarHeight {
    NSLog(@"calculateBarHeight");
    if (!self.fillHeight)
        self.maxBarHeight = self.viewHeight;

    for (int i = 0; i < self.barCount; i ++) {
        self.maxBarHeight = MAX(self.maxBarHeight, [self.data[i][@"value"] floatValue]);
        self.barScaleY = self.viewHeight / self.maxBarHeight;
    }
}

- (void)calculateBarTextLength {
    NSString* text;
    long maxLength = 0;
    for (int i = 0; i < self.barCount; i ++) {
        if ([self.data[i][@"name"] length] > maxLength) {
            maxLength = [self.data[i][@"name"] length];
            text = self.data[i][@"name"];
        }
    }
    CGSize size = [text sizeWithAttributes:nil];
    if (size.width > self.barWidth) {
        text = [text substringToIndex:MIN(3, text.length)];
        size = [text sizeWithAttributes:nil];
        while (size.width > self.barWidth && text.length > 1) {
            text = [text substringToIndex:(text.length -1)];
            size = [text sizeWithAttributes:nil];
        }
    }
    self.maxTextLength = text.length;
}

- (void)setTableInput:(NSString*) input {
    _tableInput = input;
    NSLog(@"New table data input.");
    [self convertInputToTableData];
}

- (void)convertInputToTableData {
    NSMutableArray* newData = [[NSMutableArray alloc] init];
    NSMutableArray* components = [[self.tableInput componentsSeparatedByString:@";"] mutableCopy];
    for (int i = 0; i < components.count; i ++) {
        components[i] = [components[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([components[i] length] == 0 || components[i] == nil) {
            [components removeObjectAtIndex:i];
            i--;
        }
    }
    for (int i = 0; i < components.count; i ++) {
        NSDictionary *data = [self convertStringToTableEntryData:components[i]];
        if (data) {
            [newData addObject:data];
        } else {
            NSLog(@"Bad data found in array!");
            self.data = [[NSArray alloc] init];
            return;
        }
    }
    self.data = newData;
}

- (NSDictionary*)convertStringToTableEntryData:(NSString*)string {
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

- (void)validateData {
    for (int i = 0; i < self.data.count; i ++) {
        if (!self.data[i][@"name"] || !self.data[i][@"value"]) {
            NSLog(@"Invalid data found at index: %d", i);
            self.data = [[NSArray alloc] init];
            return;
        }
    }
    NSLog(@"Table data is valid.");
}

- (void)setData:(NSArray*)data {
    _data = data;
    NSLog(@"New table data set.");
    [self validateData];
    [self setNeedsDisplay];
}

@end
