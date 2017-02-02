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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableInput = @"År 1=2000, År 2=1760, År 3 =980, År 4=2250";
        self.fillWidth = YES;
        self.fillHeight = YES;
        self.barWidth = 20.0f;
        self.barSpacing = 10.0f;
    }
    return self;
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
    
    //Background
    CGRect background = CGRectMake(0,0,rect.size.width, rect.size.height);
    UIBezierPath *diagram = [UIBezierPath bezierPathWithRect:background];
    [[UIColor whiteColor] setFill];
    [diagram fill];

    [self drawTableBars];
    [self drawTableBarText];
    [self drawTableAxisLines];
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
        if (i % 2 == 0)
            [[UIColor redColor] setFill];
        else
            [[UIColor blueColor] setFill];
        [bar fill];
        [bar stroke];
        
        drawPosX += self.barWidth + self.barSpacing;
    }
}

- (void)drawTableBarText {
    //
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
    /*CGSize size = [text sizeWithFont:font];
    if (size.width < rect.size.width)
    {
        CGRect r = CGRectMake(rect.origin.x,
                              rect.origin.y + (rect.size.height - size.height)/2,
                              rect.size.width,
                              (rect.size.height - size.height)/2);
        [text drawInRect:r withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft];
    }
    */
    [[UIColor blackColor] setStroke];
    float drawPosX = self.barSpacing + self.offsetX;
    float drawPosY;
    for (int i = 0; i < self.barCount; i ++) {
        drawPosY = self.viewHeight - ([self.data[i][@"value"] floatValue] * self.barScaleY);
        float drawWidth = self.barWidth * self.barScaleX;
        float drawHeight = [self.data[i][@"value"] floatValue] * self.barScaleY;
        
        //Get text
        NSString* text = self.data[i][@"name"];
        CGSize size = [text sizeWithFont:font];
        //Center text
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentCenter;
        NSDictionary *attribute = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
        //Draw text
        CGRect textBox = CGRectMake(drawPosX, self.viewHeight, drawWidth, self.offsetY);
        [text drawInRect:textBox withAttributes: attribute];
        
        drawPosX += self.barWidth + self.barSpacing;
    }
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

- (void)setTableInput:(NSString*) input {
    _tableInput = input;
    NSLog(@"New table data input.");
    [self convertInputToTableData];
}

- (void)convertInputToTableData {
    NSMutableArray* newData = [[NSMutableArray alloc] init];
    NSMutableArray* components = [[self.tableInput componentsSeparatedByString:@","] mutableCopy];
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
