//
//  ColorUtils.m
//
//  Version 1.1.3
//
//  Created by Nick Lockwood on 19/11/2011.
//  Copyright (c) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/ColorUtils
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import "ColorUtils.h"


#pragma GCC diagnostic ignored "-Wformat-non-iso"
#pragma GCC diagnostic ignored "-Wconversion"
#pragma GCC diagnostic ignored "-Wgnu"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


@implementation UIColor (ColorUtils)

+ (dispatch_queue_t)sharedDispatchQueue
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        queue = dispatch_queue_create("com.charcoaldesign.ColorUtils", DISPATCH_QUEUE_SERIAL);
    });
    
    return queue;
}

+ (NSMutableDictionary *)standardColors
{
    static NSMutableDictionary *colors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        colors = [@{@"black": [self blackColor], // 0.0 white
                  @"darkgray": [self darkGrayColor], // 0.333 white
                  @"lightgray": [self lightGrayColor], // 0.667 white
                  @"white": [self whiteColor], // 1.0 white
                  @"gray": [self grayColor], // 0.5 white
                  @"red": [self redColor], // 1.0, 0.0, 0.0 RGB
                  @"green": [self greenColor], // 0.0, 1.0, 0.0 RGB
                  @"blue": [self blueColor], // 0.0, 0.0, 1.0 RGB
                  @"cyan": [self cyanColor], // 0.0, 1.0, 1.0 RGB
                  @"yellow": [self yellowColor], // 1.0, 1.0, 0.0 RGB
                  @"magenta": [self magentaColor], // 1.0, 0.0, 1.0 RGB
                  @"orange": [self orangeColor], // 1.0, 0.5, 0.0 RGB
                  @"purple": [self purpleColor], // 0.5, 0.0, 0.5 RGB
                  @"brown": [self brownColor], // 0.6, 0.4, 0.2 RGB
                  @"clear": [self clearColor]} mutableCopy];
    });
    
    return colors;
}

- (void)getRGBAComponents:(CGFloat[4])rgba
{
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    switch (model)
    {
        case kCGColorSpaceModelMonochrome:
        {
            rgba[0] = components[0];
            rgba[1] = components[0];
            rgba[2] = components[0];
            rgba[3] = components[1];
            break;
        }
        case kCGColorSpaceModelRGB:
        {
            rgba[0] = components[0];
            rgba[1] = components[1];
            rgba[2] = components[2];
            rgba[3] = components[3];
            break;
        }
        case kCGColorSpaceModelCMYK:
        case kCGColorSpaceModelDeviceN:
        case kCGColorSpaceModelIndexed:
        case kCGColorSpaceModelLab:
        case kCGColorSpaceModelPattern:
        case kCGColorSpaceModelUnknown:
        {
        
#ifdef DEBUG
            
            //unsupported format
            NSLog(@"Unsupported color model: %i", model);
#endif
            rgba[0] = 0.0f;
            rgba[1] = 0.0f;
            rgba[2] = 0.0f;
            rgba[3] = 1.0f;
            break;
        }
    }
}

+ (void)registerColor:(UIColor *)color forName:(NSString *)name
{
    name = [name lowercaseString];
    
    dispatch_sync([self sharedDispatchQueue], ^{
        
#ifdef DEBUG
        
        //don't allow re-registration
        NSAssert([self standardColors][name] == nil || [[self standardColors][name] isEquivalentToColor:color],
                 @"Cannot re-register the color '%@' as this is already assigned", name);
        
#endif
        
        [self standardColors][[name lowercaseString]] = color;
    });
}

+ (instancetype)colorWithString:(NSString *)string
{
    //convert to lowercase
    string = [string lowercaseString];
    
    //try standard colors first
    __block UIColor *color = nil;
    dispatch_sync([self sharedDispatchQueue], ^{
        
        color = [self standardColors][string];
    });
    
    if (color)
    {
        return color;
    }

    //create new instance
    return [[self alloc] initWithString:string useLookup:NO];
}

+ (instancetype)colorWithRGBValue:(uint32_t)rgb
{
    return [[self alloc] initWithRGBValue:rgb];
}

+ (instancetype)colorWithRGBAValue:(uint32_t)rgba
{
    return [[self alloc] initWithRGBAValue:rgba];
}

- (instancetype)initWithString:(NSString *)string
{
    return [self initWithString:string useLookup:YES];
}

- (instancetype)initWithString:(NSString *)string useLookup:(BOOL)lookup
{
    //convert to lowercase
    string = [string lowercaseString];
    
    if (lookup)
    {
        //try standard colors
        __block UIColor *color = nil;
        dispatch_sync([[self class] sharedDispatchQueue], ^{
            
            color = [[self class] standardColors][string];
        });
        
        if (color)
        {
            return ((self = color));
        }
    }
    
    //try hex
    string = [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    switch ([string length])
    {
        case 0:
        {
            string = @"00000000";
            break;
        }
        case 3:
        {
            NSString *red = [string substringWithRange:NSMakeRange(0, 1)];
            NSString *green = [string substringWithRange:NSMakeRange(1, 1)];
            NSString *blue = [string substringWithRange:NSMakeRange(2, 1)];
            string = [NSString stringWithFormat:@"%1$@%1$@%2$@%2$@%3$@%3$@ff", red, green, blue];
            break;
        }
        case 6:
        {
            string = [string stringByAppendingString:@"ff"];
            break;
        }
        case 8:
        {
            //do nothing
            break;
        }
        default:
        {
            
#ifdef DEBUG
            
            //unsupported format
            NSLog(@"Unsupported color string format: %@", string);
#endif
            return nil;
        }
    }
    uint32_t rgba;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanHexInt:&rgba];
    return [self initWithRGBAValue:rgba];
}

- (instancetype)initWithRGBValue:(uint32_t)rgb
{
    CGFloat red = ((rgb & 0xFF0000) >> 16) / 255.0f;
	CGFloat green = ((rgb & 0x00FF00) >> 8) / 255.0f;
	CGFloat blue = (rgb & 0x0000FF) / 255.0f;
	return [self initWithRed:red green:green blue:blue alpha:1.0f];
}

- (instancetype)initWithRGBAValue:(uint32_t)rgba
{
    CGFloat red = ((rgba & 0xFF000000) >> 24) / 255.0f;
    CGFloat green = ((rgba & 0x00FF0000) >> 16) / 255.0f;
	CGFloat blue = ((rgba & 0x0000FF00) >> 8) / 255.0f;
	CGFloat alpha = (rgba & 0x000000FF) / 255.0f;
	return [self initWithRed:red green:green blue:blue alpha:alpha];
}

- (uint32_t)RGBValue
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
    uint32_t red = rgba[0]*255;
    uint32_t green = rgba[1]*255;
    uint32_t blue = rgba[2]*255;
    return (red << 16) + (green << 8) + blue;
}

- (uint32_t)RGBAValue
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
    uint8_t red = rgba[0]*255;
    uint8_t green = rgba[1]*255;
    uint8_t blue = rgba[2]*255;
    uint8_t alpha = rgba[3]*255;
    return (red << 24) + (green << 16) + (blue << 8) + alpha;
}

- (NSString *)stringValue
{
    //try standard colors
    NSUInteger index = [[[[self class] standardColors] allValues] indexOfObject:self];
    if (index != NSNotFound)
    {
        return [[[self class] standardColors] allKeys][index];
    }
    
    //convert to hex
    if (self.alpha < 1.0f)
    {
        //include alpha component
        return [NSString stringWithFormat:@"#%.8x", self.RGBAValue];
    }
    else
    {
        //don't include alpha component
        return [NSString stringWithFormat:@"#%.6x", self.RGBValue];
    }
}

- (CGFloat)red
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
	return rgba[0];    
}

- (CGFloat)green
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
	return rgba[1];    
}

- (CGFloat)blue
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
	return rgba[2];    
}

- (CGFloat)alpha
{
    return CGColorGetAlpha(self.CGColor);   
}

- (BOOL)isMonochromeOrRGB
{
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    return model == kCGColorSpaceModelMonochrome || model == kCGColorSpaceModelRGB;
}

- (BOOL)isEquivalent:(id)object
{
    if ([object isKindOfClass:[self class]])
    {
        return [self isEquivalentToColor:object];
    }
    return NO;
}

- (BOOL)isEquivalentToColor:(UIColor *)color
{
    if ([self isMonochromeOrRGB] && [color isMonochromeOrRGB])
    {
        return self.RGBAValue == color.RGBAValue;
    }
    return [self isEqual:color];
}

- (instancetype)colorWithBrightness:(CGFloat)brightness
{
    brightness = MAX(brightness, 0.0f);
    
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
    
    return [[self class] colorWithRed:rgba[0] * brightness
                                green:rgba[1] * brightness
                                 blue:rgba[2] * brightness
                                alpha:rgba[3]];
}

- (instancetype)colorBlendedWithColor:(UIColor *)color factor:(CGFloat)factor
{
    factor = MIN(MAX(factor, 0.0f), 1.0f);
    
    CGFloat fromRGBA[4], toRGBA[4];
    [self getRGBAComponents:fromRGBA];
    [color getRGBAComponents:toRGBA];
    
    return [[self class] colorWithRed:fromRGBA[0] + (toRGBA[0] - fromRGBA[0]) * factor
                                green:fromRGBA[1] + (toRGBA[1] - fromRGBA[1]) * factor
                                 blue:fromRGBA[2] + (toRGBA[2] - fromRGBA[2]) * factor
                                alpha:fromRGBA[3] + (toRGBA[3] - fromRGBA[3]) * factor];
}

@end
