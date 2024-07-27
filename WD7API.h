#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIGraphics.h>

@interface UIImage (ImageBlur)
- (UIImage *)imageWithGaussianBlur;
@end


@interface UIImage (AlphaMaster)
- (UIImage *)mergeWithImage:(UIImage *)bottomImage withAlpha:(CGFloat)alpha;

@end


@interface UIImage (Wallpapers)
+(UIImage *)currentLockBackground;
+(UIImage *)currentHomeBackground;


@end
