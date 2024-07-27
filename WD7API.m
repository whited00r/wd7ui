#import "WD7API.h"


@implementation UIImage (AlphaMaster)

- (UIImage *)mergeWithImage:(UIImage *)bottomImage withAlpha:(CGFloat)alpha{


UIImage *image = self;

CGSize newSize = CGSizeMake(self.size.width, self.size.height);
UIGraphicsBeginImageContext( newSize );

// Use existing opacity as is
[bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
// Apply supplied opacity
[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:alpha];

UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

UIGraphicsEndImageContext();

return newImage;

/*
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
	} else {
		UIGraphicsBeginImageContext(self.size);
	}
#else
	UIGraphicsBeginImageContext(self.size);
#endif
    [self drawInRect:CGRectMake(0.0f, 0.0f, self.size.width, self.size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage* alphaImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return alphaImage;

*/
}

@end


@implementation UIImage (ImageBlur)
- (UIImage *)imageWithGaussianBlur {
    float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
    // Blur horizontally
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int x = 1; x < 5; ++x) {
        [self drawInRect:CGRectMake(x, 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
        [self drawInRect:CGRectMake(-x, 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
    }
    UIImage *horizBlurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Blur vertically
    UIGraphicsBeginImageContext(self.size);
    [horizBlurredImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int y = 1; y < 5; ++y) {
        [horizBlurredImage drawInRect:CGRectMake(0, y, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
        [horizBlurredImage drawInRect:CGRectMake(0, -y, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
    }
    UIImage *blurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return blurredImage;
}

@end


@implementation UIImage (Wallpapers)

+(UIImage *)currentLockWallpaper{
NSFileManager *fMgr = [NSFileManager defaultManager]; 
if (![fMgr fileExistsAtPath:@"/var/mobile/Library/LockBackground.jpg"]) { 
return [UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeBackground.jpg"];
}
else{
return [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LockBackground.jpg"];
}

}
+(UIImage *)currentHomeWallpaper{

return [UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeBackground.jpg"];
}



@end


