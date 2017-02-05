//
//  Diagram.m
//  Diagram
//
//  Created by Christian Blomqvist on 2017-01-30.
//  Copyright © 2017 Christian Blomqvist. All rights reserved.
//

#import "Diagram.h"

@interface Diagram ()

@property (nonatomic) float offsetX;
@property (nonatomic) float offsetY;
@property (nonatomic) float viewWidth;
@property (nonatomic) float viewHeight;
@property (nonatomic) float maxTextHeight;
@property (nonatomic) float maxTextWidth;
@property (nonatomic) long maxTextLength;
@property (nonatomic) float maxValue;
@property (nonatomic) float maxBarHeight;
@property (nonatomic) float barScaleX;
@property (nonatomic) float barScaleY;
@property (nonatomic) float barSpacingShare;
@property (nonatomic) long barCount;
@property (nonatomic) int valuePrintFrequency;

@end


@implementation Diagram

- (void)setBarWidth:(float)width {
    _barWidth = MAX(1,width);
}
- (void)setBarSpacing:(float)spacing {
    _barSpacing = MAX(0,spacing);
}

- (void)setTableTextPadding:(float)padding {
    float maxAllowed = self.bounds.size.height * 0.9f;
    _tableTextPadding = MAX(0,MIN(padding, maxAllowed));
}
- (void)setTableValuePadding:(float)padding {
    float maxAllowed = self.bounds.size.width * 0.5f;
    _tableValuePadding = MAX(0,MIN(padding, maxAllowed));
}
- (float)barSpacingShare {
    return 4.0f;
}
- (float)maxTextHeight {
    CGSize size = [(@"Å") sizeWithAttributes:nil];
    return size.height;
}
- (float)maxTextWidth {
    CGSize size = [[NSString stringWithFormat:@"%d",(int) roundf(self.maxValue)] sizeWithAttributes:nil];
    NSLog(@"maxTextWidth: %f", size.width);
    return size.width;
}
- (float)maxValue {
    float max = 0.0f;
    for (int i = 0; i < self.data.count; i ++) {
        max = MAX(max, [self.data[i][@"value"] floatValue]);
    }
    NSLog(@"maxValue: %f", max);
    return max;
}
- (float)offsetX {
    return self.maxTextWidth + self.tableValuePadding;
}
- (float)offsetY {
    return self.maxTextHeight * 0.5f;
}
- (void)setBarColors:(NSArray *)colors {
    if (!colors || ![colors[0] isKindOfClass:[UIColor class]]) {
        _barColors = @[[UIColor redColor]];
    }
    else
        _barColors = colors;
}

- (void)update{
    [self setNeedsDisplay];
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
    self.tableInput = @"År 1=2000; År 2=1760; År 3 =980; År 4=2250;";
    self.fillWidth = YES;
    self.fillHeight = YES;
    self.enableSpacing = YES;
    self.tableValuePadding = 0.0f;
    self.tableTextPadding = 0.0f;
    self.barWidth = 20.0f;
    self.barSpacing = 10.0f;
    self.barColors = @[[UIColor redColor], [UIColor blueColor]];
    self.colorMode = FadeBetweenTwoColors;

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    self.viewWidth = rect.size.width - self.offsetX;
    self.viewHeight = rect.size.height - self.tableTextPadding - self.maxTextHeight;

    self.maxBarHeight = 0.0f;
    self.barScaleX = 1.0f;
    self.barScaleY = 1.0f;
    
    self.barCount = self.data.count;

    [self calculateBarDimensions];
    [self calculateBarTextLength];
    
    //Background
    CGRect background = CGRectMake(0,0,rect.size.width, rect.size.height);
    UIBezierPath *diagram = [UIBezierPath bezierPathWithRect:background];
    [[UIColor whiteColor] setFill];
    [diagram fill];

    [self drawTableBars];
    [self drawTableValues];
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
    float drawPosX = (self.enableSpacing * self.barSpacing) + self.maxTextWidth + self.tableValuePadding;
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
        CGRect textRect = CGRectMake(drawPosX, self.viewHeight, drawWidth, self.maxTextHeight + self.tableTextPadding);
        [self drawText:[text substringToIndex:MIN(text.length, self.maxTextLength)] inRect:textRect];
        
        drawPosX += self.barWidth + (self.enableSpacing * self.barSpacing);
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

- (void)drawTableValues {
    float value = self.viewHeight;
    if (self.barScaleY >= 1.0f)
        value = self.maxValue;
    
    float space = self.bounds.size.height - (self.maxTextHeight * 1.5) - self.tableTextPadding;
    float iterations = roundf(space / (self.maxTextHeight * 2));
    float increment = value / iterations;
    
    float drawY = 0;
    for (int i = 0; i <= iterations; i ++) {
        NSString *text = [NSString stringWithFormat:@"%d", (int) roundf(value)];
        CGRect rect = CGRectMake(0, drawY, self.offsetX, self.maxTextHeight);
        [self drawText:text inRect:rect];
        value -= increment;
        drawY += self.maxTextHeight*2;
    }
    
}

- (void)drawTableAxisLines {
    CGMutablePathRef axisPath = CGPathCreateMutable();
    CGPathMoveToPoint(axisPath, NULL, self.offsetX, 0);
    CGPathAddLineToPoint(axisPath, NULL, self.offsetX, self.viewHeight);
    CGPathAddLineToPoint(axisPath, NULL, self.viewWidth + self.offsetX, self.viewHeight);
    UIBezierPath *line = [UIBezierPath bezierPathWithCGPath:axisPath];
    [[UIColor blackColor] setStroke];
    line.lineWidth = 2;
    [line stroke];
    CGPathRelease(axisPath);
}

- (void)calculateBarDimensions {
    [self calculateBarWidth];
    [self calculateBarHeight];
    
    float barSpacing = self.enableSpacing * ((self.barSpacing +1) * self.barCount);
    float barWidth = self.barWidth * self.barCount;
    if (barSpacing + barWidth > self.viewWidth) {
        NSLog(@"Error: Content width exceeds view canvas, enabling Fill Width.");
        self.fillWidth = YES;
        [self calculateBarWidth];
    }
}

- (void)calculateBarWidth {
    if (self.fillWidth) {
        self.barSpacing = self.enableSpacing * ((self.viewWidth / self.barSpacingShare) / (self.barCount));
        self.barWidth = (self.viewWidth - (self.barSpacing * (self.barCount +1))) / (self.barCount);
    }
}

- (void)calculateBarHeight {
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
        NSString* current = self.data[i][@"name"];
        if (current.length > maxLength) {
            text = current;
            maxLength = text.length;
        }
    }
    CGSize size = [text sizeWithAttributes:nil];
    if (size.width > self.barWidth) {
        do {
            if (text.length > 3)
                text = [text substringToIndex:MIN(3, text.length)];
            else
                text = [text substringToIndex:(text.length -1)];
            size = [text sizeWithAttributes:nil];
        } while (size.width > self.barWidth && text.length > 1);
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
            NSLog(@"Bad data found in input text!");
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
    [self update];
}

@end
