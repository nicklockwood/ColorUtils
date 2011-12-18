//
//  ViewController.m
//  ColorUtilsExample
//
//  Created by Nick Lockwood on 18/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+ColorUtils.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //find all labels in view and style them using their text as as a color value
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)view;
            UIColor *color = [UIColor colorWithString:label.text];
            if (color)
            {
                label.textColor = color;
            }
        }
    }
}

@end
