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

@property (nonatomic) NSArray *data;
@property (nonatomic) IBInspectable NSString *tableInput;

@property (nonatomic) IBInspectable BOOL fillWidth;
@property (nonatomic) IBInspectable BOOL fillHeight;

@property (nonatomic) IBInspectable BOOL enableSpacing;

@property (nonatomic) IBInspectable float barWidth;
@property (nonatomic) IBInspectable float barSpacing;

@property (nonatomic) IBInspectable float tableValuePadding;
@property (nonatomic) IBInspectable float tableTextPadding;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *frameColor;
@property (nonatomic) NSArray *barColors;

@property (nonatomic) enum ColorMode colorMode;

- (void)update;

typedef enum ColorMode ColorMode;

enum ColorMode {
    OneColor = 0,
    CycleThroughColors = 1,
    FadeBetweenTwoColors = 2
};

@end
