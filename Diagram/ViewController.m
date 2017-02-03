//
//  ViewController.m
//  Diagram
//
//  Created by Christian Blomqvist on 2017-01-30.
//  Copyright © 2017 Christian Blomqvist. All rights reserved.
//

#import "ViewController.h"
#import "Diagram.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet Diagram *table1;
@property (weak, nonatomic) IBOutlet Diagram *table2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //self.table1.barColors = @[[UIColor greenColor]];
    
    self.table2.data = @[@{@"name": @"january", @"value": @100},
                        @{@"name": @"february", @"value": @80},
                        @{@"name": @"mars", @"value": @130},
                        @{@"name": @"april", @"value": @80}];
    self.table2.barColors = @[[UIColor yellowColor], [UIColor brownColor]];
    self.table2.colorMode = CycleThroughColors;
    
    
    //self.table1.tableInput = @"Januari = 1; Februari = 2;   Mars=3;April=4; Maj   = 5   ;Juni   =6; Juli = 7;   Augusti=8;September=9;Oktober=10;November=11;December=12";
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
