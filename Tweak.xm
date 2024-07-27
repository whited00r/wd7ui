#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <IOSurface/IOSurface.h>
#import <QuartzCore/QuartzCore2.h>
#import <QuartzCore/CAAnimation.h>
#import <UIKit/UIGraphics.h>

#import "UIImage+StackBlur.h"
#import <sys/types.h>
#import <sys/stat.h>
#import <SpringBoard/SBNowPlayingArtView.h>
#import <objc/runtime.h>
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <notify.h>
#import <Foundation/NSTask.h>
#import "SBIconList.h"

@interface SBButtonBar : SBIconList

@end

static BOOL isWhited00r = FALSE;
static BOOL launchImages = FALSE;
static BOOL prefsLoaded = FALSE;
static BOOL iconAnimationEnabled = TRUE;
static BOOL snapShotApps = TRUE;
static BOOL iconLaunchAnimation = FALSE;
static BOOL iOS4Folders = FALSE;
static BOOL shouldAnimateApp = FALSE;
static BOOL spotlightEnabled = FALSE;
static BOOL fadeScatter = FALSE;
@interface SBApplicationIcon : UIView
@end
static SBApplicationIcon *lastLaunchedIcon;
UIKIT_EXTERN CGImageRef UIGetScreenImage();
#define prefsPlist @"/var/mobile/Library/Preferences/com.whited00r.wd7ui.plist"


/*
@interface UINavigationItem : NSObject <NSCoding> {
 @private

    UINavigationBar *_navigationBar;

}

@end
*/

NSMutableArray *currentDisplayStacks = nil;
// Display stack names
#define WDSBWPreActivateDisplayStack        [currentDisplayStacks objectAtIndex:0]
#define WDSBWActiveDisplayStack             [currentDisplayStacks objectAtIndex:1]
#define WDSBWSuspendingDisplayStack         [currentDisplayStacks objectAtIndex:2]
#define WDSBWSuspendedEventOnlyDisplayStack [currentDisplayStacks objectAtIndex:3]

%hook SBDisplayStack

- (id)init
{
    id stack = %orig;
    [currentDisplayStacks addObject:stack];
    return stack;
}

- (void)dealloc
{
    [currentDisplayStacks removeObject:self];
    %orig;
}

%end


%hook SpringBoard
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // NOTE: SpringBoard creates four stacks at startup
    // NOTE: Must create array before calling original implementation
    currentDisplayStacks = [[NSMutableArray alloc] initWithCapacity:4];

    %orig;
}

- (void)dealloc
{
 
    [currentDisplayStacks release];
    %orig;
}
%end

%class TPLCDTextView
%class UIBarButtonItem

@interface UIImage (Tint)

- (UIImage *)tintedImageUsingColor:(UIColor *)tintColor;

@end

@implementation UIImage (Tint)

- (UIImage *)tintedImageUsingColor:(UIColor *)tintColor {
  UIGraphicsBeginImageContext(self.size);
  CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
  [self drawInRect:drawRect];
  [tintColor set];
  UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
  UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return tintedImage;
}

@end


@interface UIImage (CropThis)

- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;

@end

@implementation UIImage (CropThis)
- (UIImage *)croppedToRect:(CGRect)rect {

   CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef); 
    return cropped;
}
@end

static void loadPrefs();
static void initStuffWithSmileyFace();
	/*
__attribute__((constructor))
static void initialize() {
if(!prefsLoaded){

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if([[NSFileManager defaultManager]fileExistsAtPath:prefsPlist]){
		NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefsPlist];

		launchImages = [[prefs objectForKey:@"launchImages"] boolValue];
        iconAnimationEnabled = [[prefs objectForKey:@"iconAnimation"] boolValue];
        snapShotApps = [[prefs objectForKey:@"snapShotApps"] boolValue];
        iconLaunchAnimation = [[prefs objectForKey:@"iconLaunchAnimation"] boolValue];
        iOS4Folders = [[prefs objectForKey:@"iOS4Folders"] boolValue];
		//NSLog(@"AppID: %@", [prefs objectForKey:@"appID"]);
		[prefs release];



	}else{
		NSMutableDictionary *prefs=[[NSMutableDictionary alloc]init];
		[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"launchImages"];
		[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"iconLaunchAnimation"];
        [prefs setObject:[NSNumber numberWithBool:TRUE] forKey:@"iconAnimation"];
        [prefs setObject:[NSNumber numberWithBool:TRUE] forKey:@"snapShotApps"];
        [prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"iOS4Folders"];
		[prefs writeToFile:prefsPlist atomically:YES];
		[prefs release];
	}
	if(!isWhited00r){
		initStuffWithSmileyFace();
	}


	[pool drain];
prefsLoaded = TRUE;

}
}
*/
static void loadPrefs(){
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if([[NSFileManager defaultManager]fileExistsAtPath:prefsPlist]){
		NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefsPlist];

		launchImages = [[prefs objectForKey:@"launchImages"] boolValue];
        iconAnimationEnabled = [[prefs objectForKey:@"iconAnimation"] boolValue];
        snapShotApps = [[prefs objectForKey:@"snapShotApps"] boolValue];
        iconLaunchAnimation = [[prefs objectForKey:@"iconLaunchAnimation"] boolValue];
        iOS4Folders = [[prefs objectForKey:@"iOS4Folders"] boolValue];
        fadeScatter = [[prefs objectForKey:@"fadeScatter"] boolValue];
        spotlightEnabled = [[[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.whited00r.configurator.plist"] valueForKey:@"Spotlight"] boolValue];
		//NSLog(@"AppID: %@", [prefs objectForKey:@"appID"]);
		[prefs release];




	}else{
		NSMutableDictionary *prefs=[[NSMutableDictionary alloc]init];
		[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"launchImages"];
		[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"iconLaunchAnimation"];
        [prefs setObject:[NSNumber numberWithBool:TRUE] forKey:@"iconAnimation"];
        [prefs setObject:[NSNumber numberWithBool:TRUE] forKey:@"snapShotApps"];
        [prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"iOS4Folders"];
        [prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"fadeScatter"];
		[prefs writeToFile:prefsPlist atomically:YES];
		[prefs release];
	}
	if(!isWhited00r){
		initStuffWithSmileyFace();
	}
	[pool drain];
prefsLoaded = TRUE;

}

static void initStuffWithSmileyFace(){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSFileManager *fMgr = [NSFileManager defaultManager]; 


NSString *firstLevel = [NSString stringWithFormat:@"%@-CantCrackDis",[[UIDevice currentDevice] uniqueIdentifier]];
NSString *arguments = [NSString stringWithFormat:@"echo %@ | openssl dgst -sha1 -hmac \"PlsNo\"", firstLevel];
NSPipe *resultPipe = [[NSPipe alloc] init];
NSTask *taskCrypt = [[NSTask alloc] init];
NSArray *argsCrypt = [NSArray arrayWithObjects:@"-c", arguments, nil];
[taskCrypt setStandardOutput:resultPipe];

[taskCrypt setLaunchPath:@"/bin/bash"];
[taskCrypt setArguments:argsCrypt];
[taskCrypt launch];    // Run
[taskCrypt waitUntilExit]; // Wait
NSData *result = [[resultPipe fileHandleForReading] readDataToEndOfFile];
NSString *licenseKey = [[NSString alloc] initWithData: result
                               encoding: NSUTF8StringEncoding];

licenseKey = [licenseKey substringToIndex:[licenseKey length] - 1];

NSString *magicFilePath = [NSString stringWithFormat:@"/var/mobile/Whited00r/%@", licenseKey];
//NSLog(magicFilePath);

if ([fMgr fileExistsAtPath:magicFilePath] && [fMgr fileExistsAtPath:@"/var/lib/dpkg/info/com.whited00r.whited00r.list"]) { 
//NSLog(@"LicenceKey isWhited00r: /var/mobile/Whited00r/%@", licenseKey);

isWhited00r = TRUE;
}
[taskCrypt release];
//[result release];
//[licenseKey release];
[resultPipe release];


[pool drain];

}

@interface UIImage (AlphaMaster)
- (UIImage *)mergeWithImage:(UIImage *)bottomImage withAlpha:(CGFloat)alpha;

@end

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


@interface SBAwayDateView : UIView

@property(assign, nonatomic, getter=isPlaying) BOOL playing;
@property(retain, nonatomic) NSString* title;

@end

@interface SBAwayView
UIView *musicFade;

@end



%hook SBStatusBarSignalView


-(id)initWithFrame:(CGRect)frame{
CGRect newFrame = CGRectMake(frame.origin.x,frame.origin.y,frame.size.width+20,frame.size.height);
return %orig(newFrame);

}
%end





static NSString *lastAppToAttemptLaunch = nil;
static BOOL attemptingUnlockLaunch = FALSE;

%hook SBUIController
%new(@@:)
-(BOOL)isWhited00r{
return isWhited00r;
}

%new(@@:)
- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {

   CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef); 
    return cropped;
}

%new(v@:)
-(void)prewarmAppForLaunch:(NSString*)appID{
SBApplication *fromApp = [WDSBWActiveDisplayStack topApplication];
[fromApp setDeactivationSetting:0x2 flag:YES];
[fromApp setDeactivationSetting:0x8 value:[NSNumber numberWithDouble:1]];
[WDSBWSuspendingDisplayStack pushDisplay:fromApp];
}


%new(v@:)
-(void)cancelAppLaunch{
	attemptingUnlockLaunch = FALSE;
	//if([[%c(SBAwayController) sharedAwayController] isLocked]){
	
	if(lastAppToAttemptLaunch){
		/*
	SBApplication *app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:lastAppToAttemptLaunch];
if(app){
	if ([WDSBWActiveDisplayStack containsDisplay:app]) {
		
                    [app setDeactivationSetting:0x2 flag:YES]; // animate
                  
                    [app setDeactivationSetting:0x8 value:[NSNumber numberWithDouble:1]]; // animationStart

                    // Remove from active display stack
                    [WDSBWActiveDisplayStack popDisplay:app];
                    NSLog(@"Removed from active display stack");
                }

                // Deactivate the application
                NSLog(@"Pushing to suspending display stack");
              // [WDSBWSuspendingDisplayStack pushDisplay:app];
               // [app deactivate];
                NSLog(@"Pushed to suspending display stack");
                [app _clearContextHostView];
                [app kill];

	//}
}*/
lastAppToAttemptLaunch = nil;
[self openAppWithBundleID:[NSString stringWithFormat:@"com.apple.springboard"]];

}
}



%new(v@:)
-(void)openAppWithBundleID:(NSString *)appID{
	if(!appID){
	UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"WD7 Error"
                             message: @"Whatever executed this method didn't provide a bundle identifier. "
                             delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
    return;
}



if([[%c(SBAwayController) sharedAwayController] isLocked]){
	attemptingUnlockLaunch = TRUE;
	lastAppToAttemptLaunch = [appID copy];
	[[%c(SBAwayController) sharedAwayController] unlockWithSound:TRUE];
	return;
}

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    SBApplication *fromApp = [WDSBWActiveDisplayStack topApplication];
    NSString *fromDisplayId = fromApp ? [fromApp displayIdentifier] : @"com.apple.springboard";


    // Make sure that the target app is not the same as the current app
    // NOTE: This is checked as there is no point in proceeding otherwise
    if (![fromDisplayId isEqualToString:appID]) {
        

        // NOTE: Save the identifier for later use
        //deactivatingApp = [fromDisplayId copy];

        BOOL switchingToSpringBoard = [appID isEqualToString:@"com.apple.springboard"];

        SBApplication *app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:appID];
        if (app) {
            // FIXME: Handle case when app == nil
            if ([fromDisplayId isEqualToString:@"com.apple.springboard"]) {
                // Switching from SpringBoard; simply activate the target app
                [app setDisplaySetting:0x4 flag:YES]; // animate
                [app setActivationSetting:0x1000 value:[NSNumber numberWithDouble:1]]; // animationStart

                // Activate the target application
                [WDSBWPreActivateDisplayStack pushDisplay:app];
            } else {
                // Switching from another app
                if (!switchingToSpringBoard) {
                    // Switching to another app; setup app-to-app
                    [app setActivationSetting:0x40 flag:YES]; // animateOthersSuspension
                    [app setActivationSetting:0x20000 flag:YES]; // appToApp
                    [app setDisplaySetting:0x4 flag:YES]; // animate

                  
                        [app setActivationSetting:0x1000 value:[NSNumber numberWithDouble:1]]; // animationStart

                    // Activate the target application (will wait for
                    // deactivation of current app)
                    [WDSBWPreActivateDisplayStack pushDisplay:app];
                }

                // Deactivate the current application

                // NOTE: Must set animation flag for deactivation, otherwise
                //       application window does not disappear (reason yet unknown)
                [fromApp setDeactivationSetting:0x2 flag:YES]; // animate

                [fromApp setDeactivationSetting:0x8 value:[NSNumber numberWithDouble:1]]; // animationStart

                // Deactivate by moving from active stack to suspending stack
                [WDSBWActiveDisplayStack popDisplay:fromApp];
                [WDSBWSuspendingDisplayStack pushDisplay:fromApp];
            }
        }
    }
    [pool drain];

}

%end




%hook SBAwayController
-(void)_unlockWithSound:(BOOL)sound{
%orig;
if(musicFade){
[musicFade release];
musicFade = nil;

}

if(attemptingUnlockLaunch){
		[[%c(SBUIController) sharedInstance] openAppWithBundleID:lastAppToAttemptLaunch];
}
lastAppToAttemptLaunch = nil;
attemptingUnlockLaunch = FALSE;

}
-(void)unlockWithSound:(BOOL)sound{
%orig;
if(musicFade){
[musicFade release];
musicFade = nil;

}

}

-(void)unlockWithSound:(BOOL)sound alertDisplay:(id)display{
%orig;
if(musicFade){
[musicFade release];
musicFade = nil;

}

}
-(void)dimScreen:(BOOL)screen{
if(musicFade){
[musicFade removeFromSuperview];
}
if(attemptingUnlockLaunch){
	attemptingUnlockLaunch = FALSE;
	//[[%c(SBUIController) sharedInstance] cancelAppLaunch];
}
%orig;
}


-(void)_undimScreen{
if(musicFade && ![[%c(SBAwayController) sharedAwayController] isShowingMediaControls]){
[musicFade removeFromSuperview];
}
[[[self awayView] nowPlayingArtView] setReflectionVisible:FALSE withDuration:0.0];
//shouldAnimateApp = FALSE;
%orig;

}

-(void)undimScreen{
if(musicFade && ![[%c(SBAwayController) sharedAwayController] isShowingMediaControls]){
[musicFade removeFromSuperview];
}
[[[self awayView] nowPlayingArtView] setReflectionVisible:FALSE withDuration:0.0];
//shouldAnimateApp = FALSE;
%orig;

}

-(void)didAnimateLockKeypadOut{

%orig;
if([[%c(SBAwayController) sharedAwayController] isLocked]){
	attemptingUnlockLaunch = FALSE;
}
}

%end

%hook SBAwayView
-(id)initWithFrame:(CGRect)frame{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
if(!prefsLoaded){
loadPrefs();
musicFade = [[UIView alloc] initWithFrame:frame];
musicFade.backgroundColor = [UIColor blackColor];
UIImageView *fadeBlur = [[UIImageView alloc] initWithFrame:[musicFade bounds]];
fadeBlur.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LockWallpaperBlurred.png"];
fadeBlur.alpha = 0.7;
[musicFade addSubview:fadeBlur];
[fadeBlur release];
[self setDrawsBlackBackground:FALSE];
//[musicFade release];
}
if(!isWhited00r){
initStuffWithSmileyFace();
}




UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");
SBNowPlayingArtView *artView = MSHookIvar<SBNowPlayingArtView *>(self, "_albumArtView");
artView.frame = CGRectMake(50,170, 220, 220);
[artView setReflectionVisible:FALSE withDuration:0.0];
[pool drain];
return %orig;
}



-(id)nowPlayingArtView{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");
UIView *lockBar = MSHookIvar<UIView *>(self, "_lockBar");

//SBNowPlayingArtView *artView =  MSHookIvar<SBNowPlayingArtView *>(self, "_albumArtView");
//[[artView alloc] init];
//artView.frame = CGRectMake(0,dateView.frame.size.height,lockBar.frame.origin.y - dateView.frame.size.height, lockBar.frame.origin.y);
//[artView setReflectionVisible:FALSE withDuration:0.0];
SBNowPlayingArtView *artView = %orig;
artView.frame = CGRectMake(50,170, 220, 220);
[artView setReflectionVisible:FALSE withDuration:0.0];
[pool drain];
return artView;
}


-(BOOL)isShowingMediaControls{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");
UIView *lockBar = MSHookIvar<UIView *>(self, "_lockBar");
SBNowPlayingArtView *artView = MSHookIvar<SBNowPlayingArtView *>(self, "_albumArtView");
artView.frame = CGRectMake(50,170, 220, 220);
[artView setReflectionVisible:FALSE withDuration:0.0];
BOOL value = %orig;
if(value){
//[musicFade removeFromSuperview];
UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");
dateView.frame = CGRectMake(0,0,320,100);
UIView *lockBar = MSHookIvar<UIView *>(self, "_lockBar");


}
else{

UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");
dateView.frame = CGRectMake(0,0,320,130);

}
[pool drain];
return value;
}

-(void)showMediaControls{
	%orig;
	[self showBlurView];
}

-(void)hideMediaControls{
	%orig;
[self hideBlurView];


}

- (void)removeFadeAnimated:(NSString *)animationID finished:(BOOL)finished context:(void *)context{
		[musicFade removeFromSuperview];
}

-(void)addChargingView{
	%orig;
	//[self showBlurView];
	//[self performSelector:@selector(hideChargingView) withObject:nil afterDelay:5];
}

%new(v@:)
-(void)showBlurView{
if(!musicFade){
musicFade = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
musicFade.backgroundColor = [UIColor blackColor];
UIImageView *fadeBlur = [[UIImageView alloc] initWithFrame:[musicFade bounds]];
fadeBlur.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LockWallpaperBlurred.png"];
fadeBlur.alpha = 0.7;
[musicFade addSubview:fadeBlur];
[fadeBlur release];
}

if(![[[self subviews] objectAtIndex:3] isEqual:musicFade]){
	[self insertSubview:musicFade atIndex:2];
}
musicFade.alpha = 0.0;
[UIView beginAnimations:nil context:nil];
[UIView setAnimationDuration:0.15];
musicFade.alpha = 1.0;
[UIView commitAnimations];
}

%new(v@:)
-(void)hideBlurView{
[UIView beginAnimations:nil context:nil];
[UIView setAnimationDuration:0.15];
[UIView setAnimationDidStopSelector:@selector(removeFadeAnimated:finished:context:)];
[UIView setAnimationDelegate:self];
musicFade.alpha = 0.0;
[UIView commitAnimations];
}
%end



//-----------Animation testing stuff I guess?--------------\\



%hook SBUIController



%new(v@:)
-(void)saveLaunchImage:(NSDictionary *)info{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSData * binaryImageData = UIImagePNGRepresentation([info objectForKey:@"image"]);
CGImageRef imageRef = CGImageCreateWithImageInRect([[info objectForKey:@"image"] CGImage], CGRectMake(0,20,320,460));
NSData *croppedImage = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
UIGraphicsBeginImageContext(CGSizeMake(152,228));
[[UIImage imageWithCGImage:imageRef] drawInRect:CGRectMake(0, 0, 152, 228)];
UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();    
UIGraphicsEndImageContext();

NSData *scaledImage = UIImagePNGRepresentation(destImage);

if(snapShotApps){
	[scaledImage writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/WD7UI/LaunchImages/%@.png", [info objectForKey:@"identifier"]] atomically:YES];
}

if(launchImages){
[binaryImageData writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/WD7UI/LaunchImages/%@-Large.png", [info objectForKey:@"identifier"]] atomically:YES];
}
CGImageRelease(imageRef);
[pool drain];
}

-(void)showZoomLayerWithDefaultImageOfApp:(id)app{

    %orig;
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(lastLaunchedIcon && iconLaunchAnimation){
   UIView *zoomView = [self valueForKey:@"zoomLayer"];
   //zoomView.hidden = TRUE;
   [[zoomView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
   zoomView.backgroundColor = [UIColor colorWithPatternImage:[app defaultImage:NULL]];
   //
    zoomView.frame = CGRectMake(lastLaunchedIcon.center.x - (lastLaunchedIcon.frame.size.width / 2), lastLaunchedIcon.center.y - (lastLaunchedIcon.frame.size.height / 2), lastLaunchedIcon.frame.size.width, lastLaunchedIcon.frame.size.height);
}
    if(fadeScatter){
      UIView *zoomView = [self valueForKey:@"zoomLayer"];
   //zoomView.hidden = TRUE;
   [[zoomView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
   zoomView.backgroundColor = [UIColor colorWithPatternImage:[app defaultImage:NULL]];
   //
    zoomView.frame = CGRectMake(1,1,319,479);  
    //zoomView.alpha = 0.0;
    }
[pool drain];
}

-(void)animateApplicationActivation:(id)activation animateDefaultImage:(BOOL)image scatterIcons:(BOOL)icons{

   %orig(activation, image, icons);

if(fadeScatter){

    UIView *zoomView = [self valueForKey:@"zoomLayer"];
  
    zoomView.frame = CGRectMake(0, 0, 320, 480);
    //zoomView.frame = CGRectMake(lastLaunchedIcon.center.x - (lastLaunchedIcon.frame.size.width / 2), lastLaunchedIcon.center.y - (lastLaunchedIcon.frame.size.height / 2), lastLaunchedIcon.frame.size.width, lastLaunchedIcon.frame.size.height);
[UIView beginAnimations:nil context:nil];   
[UIView setAnimationDelegate:self];
//[UIView setAnimationDidStopSelector:@selector(animateApplicationActivationDidStop:finished:context:)];  
[UIView setAnimationDuration:1.0f];
    zoomView.frame = CGRectMake(0, 0, 320, 480);
    // [[[%c(SBIconController) sharedInstance] currentIconList] setAlpha:0.0];
     zoomView.alpha = 1.0;
[UIView commitAnimations];
     return;
    }

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(lastLaunchedIcon && iconLaunchAnimation && image){
  // [self showZoomLayerWithDefaultImageOfApp:activation];
    UIView *zoomView = [self valueForKey:@"zoomLayer"];
    //zoomView.frame = CGRectMake(lastLaunchedIcon.center.x - (lastLaunchedIcon.frame.size.width / 2), lastLaunchedIcon.center.y - (lastLaunchedIcon.frame.size.height / 2), lastLaunchedIcon.frame.size.width, lastLaunchedIcon.frame.size.height);
[UIView beginAnimations:nil context:nil];   
[UIView setAnimationDelegate:self];
//[UIView setAnimationDidStopSelector:@selector(animateApplicationActivationDidStop:finished:context:)];  
[UIView setAnimationDuration:0.5f];
    zoomView.frame = CGRectMake(0, 0, 320, 480);
[UIView commitAnimations];
}
[pool drain];
}

-(void)animateApplicationSuspend:(id)suspend{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
if(snapShotApps || launchImages){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSFileManager *fMgr = [NSFileManager defaultManager]; 
if (![fMgr fileExistsAtPath:@"/var/mobile/Library/WD7UI"]) { 
[fMgr createDirectoryAtPath:@"/var/mobile/Library/WD7UI" attributes:nil];
[fMgr createDirectoryAtPath:@"/var/mobile/Library/WD7UI/LaunchImages" attributes:nil];
}

CGImageRef screen = UIGetScreenImage();
UIImage *appScreen = [UIImage imageWithCGImage:screen];
CGImageRelease(screen);
NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
[infoDict setObject:appScreen forKey:@"image"];
[infoDict setObject:[suspend displayIdentifier] forKey:@"identifier"];
[self performSelectorInBackground:@selector(saveLaunchImage:) withObject:infoDict];
[infoDict release];
[pool drain];
}
  
  //id superview = zoomView.superview;

//forcing the dock to update the background image... :)
[[[%c(SBIconModel) sharedInstance] buttonBar] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/SBDockBG.png"]]];
if(!fadeScatter) [self clearZoomLayer];
%orig;
if(lastLaunchedIcon && iconLaunchAnimation && isWhited00r){
UIView *zoomView = [self valueForKey:@"zoomLayer"];
zoomView.center = CGPointMake(lastLaunchedIcon.center.x, lastLaunchedIcon.center.y);
//[superview addSubview:zoomView];
   // zoomView.frame = CGRectMake(0, 0, 320, 480);
[UIView beginAnimations:nil context:nil];   

//[UIView setAnimationDidStopSelector:@selector(animateApplicationActivationDidStop:finished:context:)];  
[UIView setAnimationDuration:0.5f];
zoomView.frame = CGRectMake(lastLaunchedIcon.center.x, lastLaunchedIcon.center.y, 0, 0);

[UIView commitAnimations];
//[[%c(UIApplication) sharedApplication] quitTopApplication:nil];

}

if(fadeScatter){
        UIView *zoomView = [self valueForKey:@"zoomLayer"];
    zoomView.frame = CGRectMake(0, 0, 320, 480);
    //zoomView.frame = CGRectMake(lastLaunchedIcon.center.x - (lastLaunchedIcon.frame.size.width / 2), lastLaunchedIcon.center.y - (lastLaunchedIcon.frame.size.height / 2), lastLaunchedIcon.frame.size.width, lastLaunchedIcon.frame.size.height);
[UIView beginAnimations:nil context:nil];   
[UIView setAnimationDelegate:self];
//[UIView setAnimationDidStopSelector:@selector(animateApplicationActivationDidStop:finished:context:)];  
[UIView setAnimationDuration:1.0f];

    // [[[%c(SBIconController) sharedInstance] currentIconList] setAlpha:1.0];
     zoomView.alpha = 0.0;
[UIView commitAnimations];


}

[pool drain];
}

%end

%hook SBApplication
-(id)defaultImage:(BOOL*)image{
if(isWhited00r){
if(launchImages){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSFileManager *fMgr = [NSFileManager defaultManager]; 
if ([fMgr fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Library/WD7UI/LaunchImages/%@-Large.png", [self displayIdentifier]]]) { 
//NSLog(@"LicenceKey isWhited00r: /var/mobile/Whited00r/%@", licenseKey);
[pool drain];
return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/WD7UI/LaunchImages/%@-Large.png", [self displayIdentifier]]];

}
else{
[pool drain];
return %orig;
}
}
else{
return %orig;
}
}
else{
return %orig;
}
}

%end


%hook SBAwayDateView 

-(id)initWithFrame:(CGRect)frame{

self = %orig;


frame = CGRectMake(0,0,320,100);


return self;
}

/*
-(void)updateClockFormat{
%orig;
if([self isShowingControls]){
self.frame = CGRectMake(0,0,320,140);


}
else{
self.frame = CGRectMake(0,0,320,80);
}


}
*/

- (id)labelWithFontSize:(float)arg1 origin:(struct CGPoint)arg2 fontName:(const char *)arg3
{
if(isWhited00r){
		if (arg1 == 65.000000) return %orig(95.0, CGPointMake(arg2.x, arg2.y + 5), arg3);
		else if (arg1 == 17.000000) return %orig(arg1, CGPointMake(arg2.x, arg2.y + 35), arg3);
}
else{
		if (arg1 == 65.000000) return %orig(200.0, arg2, arg3);
		else if (arg1 == 17.000000) return %orig(arg1, CGPointMake(arg2.x, arg2.y + 100), arg3);

}
	return %orig;
}


-(void)updateLabels{
%orig;
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

UILabel *titleLabel = MSHookIvar<UILabel *>(self, "_nowPlayingTitleLabel");
CGRect newTitleLabelFrame = CGRectMake(titleLabel.frame.origin.x, 50, titleLabel.frame.size.width, titleLabel.frame.size.height);
titleLabel.frame = newTitleLabelFrame;
titleLabel.font = [UIFont systemFontOfSize:16];
[titleLabel setShadowColor:[UIColor clearColor]];
UILabel *albumLabel = MSHookIvar<UILabel *>(self, "_nowPlayingAlbumLabel");
CGRect newAlbumLabelFrame = CGRectMake(160, 75, 145, albumLabel.frame.size.height);
albumLabel.frame = newAlbumLabelFrame;
albumLabel.textAlignment = UITextAlignmentLeft;
albumLabel.font = [UIFont systemFontOfSize:14];
albumLabel.alpha = 0.7;
albumLabel.hidden = TRUE;
[albumLabel setShadowColor:[UIColor clearColor]];
if(!isWhited00r){
albumLabel.text = @"Hi n00b";

}

UILabel *artistLabel = MSHookIvar<UILabel *>(self, "_nowPlayingArtistLabel");
CGRect newArtistLabelFrame = CGRectMake(10, 75, 300, artistLabel.frame.size.height);
artistLabel.frame = newArtistLabelFrame;
artistLabel.textAlignment = UITextAlignmentCenter;
artistLabel.font = [UIFont systemFontOfSize:14];
artistLabel.alpha = 0.7;
[artistLabel setShadowColor:[UIColor clearColor]];
if(artistLabel.text){
artistLabel.text = [NSString stringWithFormat:@"%@ - %@", artistLabel.text, albumLabel.text];
}
if(!isWhited00r){
artistLabel.text = [NSString stringWithFormat:@"Whited00r <3"];

}

//Hope this works...
TPLCDTextView *timeLabel = MSHookIvar<TPLCDTextView *>(self, "_timeLabel");
if([self isShowingControls]){

titleLabel.hidden = FALSE;
[timeLabel setFont:[UIFont fontWithName:@"LockClock-Light" size:0.00]];
[timeLabel setShadowColor:[UIColor clearColor]];
titleLabel.text = self.title;
}
else{
titleLabel.hidden = TRUE;
titleLabel.text = @" ";
[timeLabel setFont:[UIFont fontWithName:@"LockClock-Light" size:95.0]];
[timeLabel setShadowColor:[UIColor clearColor]];
}

TPLCDTextView *dateLabel = MSHookIvar<TPLCDTextView *>(self, "_titleLabel");
[dateLabel setShadowColor:[UIColor clearColor]];


[pool drain];

}


%end


%hook SBAwayMediaControlsView

-(id)initWithFrame:(CGRect)frame{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
UIView *date = [[[%c(SBAwayController) sharedAwayController] awayView] dateView];
frame = date.frame;
[pool drain];
return %orig;

}

-(void)layoutSubviews{

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
UISlider *slider = MSHookIvar<UISlider *>(self, "_slider");
CGRect newSliderFrame = CGRectMake(slider.frame.origin.x, 10, slider.frame.size.width, slider.frame.size.height);
slider.frame = newSliderFrame;


UIButton *prevButton = MSHookIvar<UIButton *>(self, "_prevButton");
prevButton.frame = CGRectMake(80, 110, 20, 20);

UIButton *nextButton = MSHookIvar<UIButton *>(self, "_nextButton");
nextButton.frame = CGRectMake(140, 110, 20, 20);

UIButton *playPauseButton = MSHookIvar<UIButton *>(self, "_playPauseButton");

playPauseButton.frame = CGRectMake(280, 110, 20, 20);
[pool drain];
%orig;
}

%end

//-----Navigation bar titles
%hook UINavigationItem
- (id)initWithTitle:(NSString *)title
{
  self = %orig;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    UILabel *titleView = (UILabel *)self.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
       // titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.numberOfLines = 1;
        titleView.lineBreakMode = UILineBreakModeTailTruncation;
        titleView.textColor = [UIColor blackColor]; // Change to desired color

        self.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;

    [titleView sizeToFit];
    //Don't want this too long... back buttons need to work :p
    if(titleView.frame.size.width >= 200 && titleView.frame.origin.x <= 100){
        titleView.frame = CGRectMake(100,0,200,titleView.frame.size.height);
    }
    [pool drain];

    return self;
}


%end

//-----Navigation bar backgrounds
%hook UINavigationBar
-(void)drawBackgroundInRect:(CGRect)rect withStyle:(int)style{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	   CGContextRef context = UIGraphicsGetCurrentContext(); 

    CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y,rect.size.width, rect.size.height);
//First off-white
       CGContextStrokePath(context);
        CGContextSetRGBFillColor(context, 242.0/255.0, 242.0/255.0, 242.0/255.0, 1.0f);
        CGContextFillRect(context, CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height ));

//Then grey

        CGContextStrokePath(context);
        CGContextSetRGBFillColor(context, 200.0/255.0, 200.0/255.0, 200.0/255.0, 1.0f);
        CGContextFillRect(context, CGRectMake(0, rect.size.height -1, rect.size.width, 1));
        /*
        CGContextSetLineWidth(context, 1.0);

        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0].CGColor);

        CGContextMoveToPoint(context, 0, rect.size.height - 1);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 1);
        */

  
     
        /*
                CAFilter *filter = [CAFilter filterWithType:@"gaussianBlur"];
                [filter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputRadius"];
               NSArray * filters = [[NSArray alloc] initWithObjects:filter, nil];

            CALayer *layer = self.layer;
            layer.filters = filters;
          //  layer.shouldRasterize = YES;
            [filters release];
            */
[pool drain];
}


%end

//---Navigation buttons and such
%hook UINavigationItemView
-(void)drawText:(id)text inRect:(CGRect)rect{
    if(![self isKindOfClass:[%c(UINavigationItemButtonView) class]]){
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	UINavigationItem *item = [self valueForKey:@"item"];
    UILabel *titleView = (UILabel *)item.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        //titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.numberOfLines = 1;
        titleView.lineBreakMode = UILineBreakModeTailTruncation;
        titleView.textColor = [UIColor blackColor]; // Change to desired color

        item.titleView = titleView;
        [titleView release];
    }
    titleView.text = text;
    [titleView sizeToFit];
    if(titleView.frame.size.width >= 200 && titleView.frame.origin.x <= 100){
    	titleView.frame = CGRectMake(100,0,200,titleView.frame.size.height);
    }


    [pool drain];
}
    %orig;
}



%end

@interface UINavigationItemButtonView : UIView

BOOL drawn;
UILabel *titleView;
NSString *lastTitle;
-(UIImage*)image;
@end

%hook UINavigationItemButtonView


-(void)drawRect:(CGRect)rect{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

if([self title]){

    if(!titleView){
    CGContextRef context = UIGraphicsGetCurrentContext(); 

    CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y,rect.size.width, rect.size.height);

    CGContextSetRGBFillColor(context, 242.0/255.0f, 242.0/255.0f, 242.0/255.0f, 0.0f);

    CGContextFillRect(context, drawRect);
}


        for(UIView *subview in [self subviews]){
            [subview removeFromSuperview];
            subview = nil;
        }
    // [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
      titleView = [[UILabel alloc] initWithFrame:CGRectMake(20,0, 60, self.frame.size.height)];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont systemFontOfSize:14.0];
       // titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.numberOfLines = 1;
        titleView.lineBreakMode = UILineBreakModeCharacterWrap;
        if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
        titleView.textColor = [UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0];
        }
        else{
        titleView.textColor = [UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0];
        }
        titleView.textAlignment = UITextAlignmentLeft;
       // NSLog(@"Adding titleView to self");
        [self addSubview:titleView];
        //NSLog(@"Added titleView to self, releasing titleView");
        [titleView release];
        //NSLog(@"Released titleView, setting text to [self title]");
        titleView.text = [self title];


        UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,18, 30)];
        if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"]){
            backImage.image = [[UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Back.png"] tintedImageUsingColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0]];
        }
        else{
            backImage.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Back.png"];
        }
       
        [self addSubview:backImage];
       // NSLog(@"Added backImage, releasing");
        [backImage release];
        //NSLog(@"BackImage release");
      
   // }
   

}
else{
    %orig;

}
//%orig;
[pool drain];
}



%end





//-----------------------------------------UIAlertViews (Popups)-----------------------------\\
@interface UIAlertView (Private)

-(CGRect)backgroundSize;
-(CGRect)titleRect;
@end
%class UIPushButton

%hook UIAlertView

/*
+(id)_popupAlertBackground:(BOOL)background{


	  CGContextRef context = UIGraphicsGetCurrentContext(); 
        CGContextSetRGBFillColor(context, 242.0/255.0, 242.0/255.0, 242.0/255.0, 1.0f);
        CGContextFillRect(context, CGRectMake(0,0, 320, 480));
CGImageRef imgRef = CGBitmapContextCreateImage(context);
  UIImage* img = [UIImage imageWithCGImage:imgRef];
  CGImageRelease(imgRef);
  CGContextRelease(context);

	return %orig;
}
  */



-(void)layout{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UILabel *bodyTextLabel = [self valueForKey:@"bodyTextLabel"];
	bodyTextLabel.textColor = [UIColor blackColor];	
	bodyTextLabel.shadowColor = [UIColor clearColor];

	UILabel *titleLabel = [self valueForKey:@"titleLabel"];

	titleLabel.textColor = [UIColor blackColor];
	titleLabel.shadowColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:16];


	UILabel *taglineTextLabel = [self valueForKey:@"taglineTextLabel"];
	taglineTextLabel.textColor = [UIColor blackColor];	
	taglineTextLabel.shadowColor = [UIColor clearColor];

	UILabel *subtitleLabel = [self valueForKey:@"subtitleLabel"];
	subtitleLabel.textColor = [UIColor blackColor];	
	subtitleLabel.shadowColor = [UIColor clearColor];

	for(UIPushButton *button in [self valueForKey:@"buttons"]){
		if([button respondsToSelector:@selector(setDrawLine:)]) [button setDrawLine:TRUE];
	}

/*
	for(UITextField *field in [self valueForKey:@"textFields"]){
		field.textColor = [UIColor blackColor];
	}
	*/
	[pool drain];
%orig;

}
%end

//More popups

@interface UIModalView : UIView
-(CGRect)titleRect;
@end
%hook UIModalView




- (void)layoutSubviews
{

	%orig;
		
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UILabel *titleLabel = [self valueForKey:@"titleLabel"];
	[titleLabel setTextColor:[UIColor blackColor]];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.shadowColor = [UIColor clearColor];

	UILabel *bodyTextLabel = [self valueForKey:@"bodyTextLabel"];
	bodyTextLabel.textColor = [UIColor blackColor];	
	bodyTextLabel.shadowColor = [UIColor clearColor];

	for(UIPushButton *button in [self valueForKey:@"buttons"]){

		if([button respondsToSelector:@selector(setDrawLine:)]) [button setDrawLine:TRUE];
	}

	//UILabel *titleLabel = [self valueForKey:@"titleLabel"];

	/*
	[titleLabel setTextColor:[UIColor blackColor]];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.shadowColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:16];
*/

	UILabel *taglineTextLabel = [self valueForKey:@"taglineTextLabel"];
	taglineTextLabel.textColor = [UIColor blackColor];	
	taglineTextLabel.shadowColor = [UIColor clearColor];

	UILabel *subtitleLabel = [self valueForKey:@"subtitleLabel"];
	subtitleLabel.textColor = [UIColor blackColor];	
	subtitleLabel.shadowColor = [UIColor clearColor];


	//titleLabel.font = [UIFont boldSystemFontOfSize:16];
	/*
    for (UIView *subview in self.subviews){ //Fast Enumeration
        if ([subview isMemberOfClass:[UIImageView class]]) {
           // subview.hidden = YES; //Hide UIImageView Containing Blue Background
        }
        if ([subview isMemberOfClass:[UILabel class]]) { //Point to UILabels To Change Text
            UILabel *label = (UILabel*)subview; //Cast From UIView to UILabel
            label.textColor = [UIColor blackColor];
            label.shadowColor = [UIColor blackColor];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        }
    }
    */
    /*
    CAFilter *filter = [CAFilter filterWithType:@"gaussianBlur"];
    [filter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputRadius"];
    NSArray * filters = [[NSArray alloc] initWithObjects:filter, nil];
    UIView *originalWindow = [[self subviews] objectAtIndex:0];
    CALayer *layer = originalWindow.layer;
    layer.filters = filters;
     //  layer.shouldRasterize = YES;
     [filters release];
     */
    [pool drain];
}
%end



//------------------------------Icon animations maybe?--------------------------------------\\

static int iconListCount = 1;



@interface SBIconList (Extras)
-(CGPoint)originForIcon:(id)icon;
-(CGPoint)icon:(UIView *)icon centerForX:(int)currentX andY:(int)currentY unscatter:(BOOL)unscatter;
-(float)scaleForX:(int)currentX andY:(int)currentY;
-(CGPoint)xyForIcon:(UIView *)oldIcon;
-(UIView *)iconForX:(float)x andY:(float)y;
-(void)moveIcon:(UIView *)icon scatter:(BOOL)scatter centerPoint:(CGPoint)centerPoint iconPoint:(CGPoint)iconPoint;
@end

%hook SBIconList
-(void)unscatter:(BOOL)unscatter startTime:(double)time{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

if(![[[%c(SBIconController) sharedInstance] currentIconList] isEqual:self]){
	//shouldAnimateApp = FALSE;
	%orig;
    return;
}

if(fadeScatter){
[UIView beginAnimations:nil context:nil];  
[UIView setAnimationDelegate:self];
[UIView setAnimationDuration:0.6f];  
[self setAlpha:1.0];
[UIView commitAnimations];
return;
}

if(!shouldAnimateApp){
if(!iconAnimationEnabled){
shouldAnimateApp = FALSE;
   
     %orig;
     return;
}

int currentX = 1;
int currentY = 1;
   for(UIView *icon in [self icons]){
      icon.center = [self icon:icon centerForX:currentX andY:currentY unscatter:FALSE];
        if(currentY == 2){
            if(currentX == 2 || currentX == 3){
                icon.alpha = 0.0;
            }
        }
        float scale = [self scaleForX:currentX andY:currentY];
        icon.transform = CGAffineTransformMakeScale(scale, scale);
        currentX = currentX + 1;
        if(currentX > 4){
            currentX = 1;
            currentY = currentY + 1;
        }
    }

currentX = 1;
currentY = 1;

UIView *x2Y2 = [self iconForX:2 andY:2];
UIView *x3Y2 = [self iconForX:3 andY:2];

[self firstStageUnscatterAnimationDone];

[UIView beginAnimations:nil context:nil];   
[UIView setAnimationDelegate:self];
//[UIView setAnimationDidStopSelector:@selector(firstStageUnscatterAnimationDone:finished:context:)];  
[UIView setAnimationDuration:0.3f];

if(x2Y2){
x2Y2.alpha = 1.0;
x2Y2.center = [self icon:x2Y2 centerForX:2 andY:2 unscatter:TRUE];
x2Y2.transform = CGAffineTransformMakeScale(1.0, 1.0);  
}
if(x3Y2){
x3Y2.alpha = 1.0;
x3Y2.center = [self icon:x3Y2 centerForX:3 andY:2 unscatter:TRUE];
x3Y2.transform = CGAffineTransformMakeScale(1.0, 1.0);  
}

[UIView commitAnimations];
shouldAnimateApp = FALSE;
return;
}

else{
if(!iconLaunchAnimation || !lastLaunchedIcon){
	shouldAnimateApp = FALSE;
    %orig;
    return;
}
    int currentX = 1;
    int currentY = 1;
UIView *centerIcon = lastLaunchedIcon;
CGPoint centerIconPoint = [self xyForIcon:centerIcon];
UIView *upCenter = [self iconForX:centerIconPoint.x andY:centerIconPoint.y - 1];

UIView *upLeft = [self iconForX:centerIconPoint.x -1 andY:centerIconPoint.y - 1];

UIView *upRight = [self iconForX:centerIconPoint.x + 1 andY:centerIconPoint.y - 1];

UIView *right = [self iconForX:centerIconPoint.x + 1 andY:centerIconPoint.y];

UIView *left = [self iconForX:centerIconPoint.x - 1 andY:centerIconPoint.y];

UIView *downCenter = [self iconForX:centerIconPoint.x andY:centerIconPoint.y + 1];

UIView *downLeft = [self iconForX:centerIconPoint.x - 1 andY:centerIconPoint.y + 1];

UIView *downRight = [self iconForX:centerIconPoint.x + 1 andY:centerIconPoint.y + 1];

//Restting posistions to off-screen...
for(UIView *icon in [self icons]){
if(![icon isEqual:centerIcon] && ![icon isEqual:upCenter] && ![icon isEqual:upLeft] && ![icon isEqual:upRight] && ![icon isEqual:right] && ![icon isEqual:left] && ![icon isEqual:downRight] && ![icon isEqual:downLeft] && ![icon isEqual:downCenter]){
         [self moveIcon:icon scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(currentX, currentY)];
    }
        currentX = currentX + 1;
        if(currentX > 4){
            currentX = 1;
            currentY = currentY + 1;
        }
}

currentX = 1;
currentY = 1;

if(centerIcon) [self moveIcon:centerIcon scatter:TRUE centerPoint:centerIconPoint iconPoint:centerIconPoint];
if(upCenter) [self moveIcon:upCenter scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x, centerIconPoint.y -1)];
if(upLeft) [self moveIcon:upLeft scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x -1, centerIconPoint.y -1)];
if(upRight) [self moveIcon:upRight scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x +1, centerIconPoint.y -1)];  
if(right) [self moveIcon:right scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x + 1, centerIconPoint.y)];
if(left) [self moveIcon:left scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x - 1, centerIconPoint.y)];
if(downCenter) [self moveIcon:downCenter scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x, centerIconPoint.y +1)];   
if(downRight) [self moveIcon:downRight scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x + 1, centerIconPoint.y + 1)];
if(downLeft) [self moveIcon:downLeft scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x - 1, centerIconPoint.y + 1)];

[UIView beginAnimations:nil context:nil];   
[UIView setAnimationDelegate:self];
//[UIView setAnimationDidStopSelector:@selector(firstStageAnimationDone:finished:context:)];  
[UIView setAnimationDuration:0.3f];


if(centerIcon) [self moveIcon:centerIcon scatter:FALSE centerPoint:centerIconPoint iconPoint:centerIconPoint];
if(upCenter) [self moveIcon:upCenter scatter:FALSE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x, centerIconPoint.y -1)];
if(upLeft) [self moveIcon:upLeft scatter:FALSE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x -1, centerIconPoint.y -1)];
if(upRight) [self moveIcon:upRight scatter:FALSE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x +1, centerIconPoint.y -1)];  
if(right) [self moveIcon:right scatter:FALSE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x + 1, centerIconPoint.y)];
if(left) [self moveIcon:left scatter:FALSE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x - 1, centerIconPoint.y)];
if(downCenter) [self moveIcon:downCenter scatter:FALSE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x, centerIconPoint.y +1)];   
if(downRight) [self moveIcon:downRight scatter:FALSE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x + 1, centerIconPoint.y + 1)];
if(downLeft) [self moveIcon:downLeft scatter:FALSE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x - 1, centerIconPoint.y + 1)];
for(UIView *icon in [self icons]){
if(![icon isEqual:centerIcon] && ![icon isEqual:upCenter] && ![icon isEqual:upLeft] && ![icon isEqual:upRight] && ![icon isEqual:right] && ![icon isEqual:left] && ![icon isEqual:downRight] && ![icon isEqual:downLeft] && ![icon isEqual:downCenter]){
         [self moveIcon:icon scatter:FALSE centerPoint:centerIconPoint iconPoint:CGPointMake(currentX, currentY)];
    }
        currentX = currentX + 1;
        if(currentX > 4){
            currentX = 1;
            currentY = currentY + 1;
        }
}

   [UIView commitAnimations];


}
shouldAnimateApp = FALSE;
[pool drain];
}

-(void)scatter:(BOOL)scatter startTime:(double)time{

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
if(![[[%c(SBIconController) sharedInstance] currentIconList] isEqual:self]){
    %orig;
    return;
}

if(fadeScatter){
[UIView beginAnimations:nil context:nil];  
[UIView setAnimationDelegate:self];
[UIView setAnimationDuration:0.6f];  
[self setAlpha:0.0];
[UIView commitAnimations];
return;
}


int currentX = 1;
int currentY = 1;

if(!shouldAnimateApp){
if(!iconAnimationEnabled){
    %orig;
    return;
}
if(![[%c(SBAwayController) sharedAwayController] isLocked]){
	//%orig;
	//return;
}
[self performSelector:@selector(firstStageScatterAnimationDone) withObject:nil afterDelay:0.2];
        for(UIView *icon in [self icons]){

        if(currentY == 2){
            if(currentX == 2 || currentX == 3){
                icon.alpha = 0.0;
                float scale = [self scaleForX:currentX andY:currentY];
                icon.center = [self icon:icon centerForX:currentX andY:currentY unscatter:FALSE];
                icon.transform = CGAffineTransformMakeScale(scale, scale);
            }
        }

        currentX = currentX + 1;
        if(currentX > 4){
            currentX = 1;
            currentY = currentY + 1;
        }
    }
    return;
}

if(!iconLaunchAnimation || !lastLaunchedIcon){
    %orig;
    return;
}

currentX = 1;
currentY = 1;
UIView *centerIcon = lastLaunchedIcon;
CGPoint centerIconPoint = [self xyForIcon:centerIcon];
//NSLog(@"CenterIconPoint: %@", centerIconPoint);

UIView *upCenter = [self iconForX:centerIconPoint.x andY:centerIconPoint.y - 1];

UIView *upLeft = [self iconForX:centerIconPoint.x -1 andY:centerIconPoint.y - 1];

UIView *upRight = [self iconForX:centerIconPoint.x + 1 andY:centerIconPoint.y - 1];

UIView *right = [self iconForX:centerIconPoint.x + 1 andY:centerIconPoint.y];

UIView *left = [self iconForX:centerIconPoint.x - 1 andY:centerIconPoint.y];

UIView *downCenter = [self iconForX:centerIconPoint.x andY:centerIconPoint.y + 1];

UIView *downLeft = [self iconForX:centerIconPoint.x - 1 andY:centerIconPoint.y + 1];

UIView *downRight = [self iconForX:centerIconPoint.x + 1 andY:centerIconPoint.y + 1];


[UIView beginAnimations:nil context:nil];   
[UIView setAnimationDelegate:self];
//[UIView setAnimationDidStopSelector:@selector(firstStageAnimationDone:finished:context:)];  
[UIView setAnimationDuration:0.6f];


if(centerIcon) [self moveIcon:centerIcon scatter:TRUE centerPoint:centerIconPoint iconPoint:centerIconPoint];
if(upCenter) [self moveIcon:upCenter scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x, centerIconPoint.y -1)];
if(upLeft) [self moveIcon:upLeft scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x -1, centerIconPoint.y -1)];
if(upRight) [self moveIcon:upRight scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x +1, centerIconPoint.y -1)];  
if(right) [self moveIcon:right scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x + 1, centerIconPoint.y)];
if(left) [self moveIcon:left scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x - 1, centerIconPoint.y)];
if(downCenter) [self moveIcon:downCenter scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x, centerIconPoint.y +1)];   
if(downRight) [self moveIcon:downRight scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x + 1, centerIconPoint.y + 1)];
if(downLeft) [self moveIcon:downLeft scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(centerIconPoint.x - 1, centerIconPoint.y + 1)];
for(UIView *icon in [self icons]){
if(![icon isEqual:centerIcon] && ![icon isEqual:upCenter] && ![icon isEqual:upLeft] && ![icon isEqual:upRight] && ![icon isEqual:right] && ![icon isEqual:left] && ![icon isEqual:downRight] && ![icon isEqual:downLeft] && ![icon isEqual:downCenter]){
        [self moveIcon:icon scatter:TRUE centerPoint:centerIconPoint iconPoint:CGPointMake(currentX, currentY)];
    }
        currentX = currentX + 1;
        if(currentX > 4){
            currentX = 1;
            currentY = currentY + 1;
        }
}

   [UIView commitAnimations];
   [self performSelector:@selector(layoutIconsNow) withObject:nil afterDelay:0.5f];
[pool drain];
}

%new(v@:)
-(void)moveIcon:(UIView *)icon scatter:(BOOL)scatter centerPoint:(CGPoint)centerPoint iconPoint:(CGPoint)iconPoint{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    float xOffset;
    float yOffset;
    float scale;
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    float mainScreenHeight = mainScreen.size.height;
    float mainScreenWidth = mainScreen.size.width;
    if(scatter){

        if(iconPoint.x <= centerPoint.x - 1){
            xOffset = icon.center.x - mainScreenWidth - icon.frame.size.width;
        }
        if(iconPoint.x == centerPoint.x){
            xOffset = icon.center.x;
        }
        if(iconPoint.x >= centerPoint.x + 1){
            xOffset = icon.center.x + mainScreenWidth + icon.frame.size.width;
        }

        if(iconPoint.y <= centerPoint.y - 1){
            yOffset = icon.center.y - mainScreenHeight - icon.frame.size.height;
        }
        if(iconPoint.y == centerPoint.y){
            yOffset = icon.center.y;
        }
        if(iconPoint.y >= centerPoint.y + 1){
            yOffset = icon.center.y + mainScreenHeight + icon.frame.size.height;
        }
        scale = 5.0;

    }
    if(!scatter){
        if(iconPoint.x <= centerPoint.x - 1){
            xOffset = icon.center.x + mainScreenWidth + icon.frame.size.width;
        }
        if(iconPoint.x == centerPoint.x){
            xOffset = icon.center.x;
        }
        if(iconPoint.x >= centerPoint.x + 1){
            xOffset = icon.center.x - mainScreenWidth - icon.frame.size.width;
        }

        if(iconPoint.y <= centerPoint.y - 1){
            yOffset = icon.center.y + mainScreenHeight + icon.frame.size.height;
        }
        if(iconPoint.y == centerPoint.y){
            yOffset = icon.center.y;
        }
        if(iconPoint.y >= centerPoint.y + 1){
            yOffset = icon.center.y - mainScreenHeight - icon.frame.size.height;
        }
        scale = 1.0;
    }
    icon.center = CGPointMake(xOffset, yOffset);
    icon.transform = CGAffineTransformMakeScale(scale, scale);
[pool drain];
}


%new(v@:)
-(void)firstStageUnscatterAnimationDone{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
int currentX = 1;
int currentY = 1;

[UIView beginAnimations:nil context:nil];   
[UIView setAnimationDelegate:self];
[UIView setAnimationDidStopSelector:@selector(finishedScatterAnimations:finished:context:)];  
[UIView setAnimationDuration:0.2f];
//[UIView setAnimationDelay:0.3];
[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    for(UIView *icon in [self icons]){

        icon.center = [self icon:icon centerForX:currentX andY:currentY unscatter:TRUE];
        if(currentY == 2){
            if(currentX == 2 || currentX == 3){
                icon.alpha = 1.0;
            }
        }
        icon.transform = CGAffineTransformMakeScale(1.0, 1.0);
        currentX = currentX + 1;
        if(currentX > 4){
            currentX = 1;
            currentY = currentY + 1;
        }
    }
    [UIView commitAnimations];
    [pool drain];
}

%new(v@:)
-(void)firstStageScatterAnimationDone{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
int currentX = 1;
int currentY = 1;
[UIView beginAnimations:nil context:nil];   
[UIView setAnimationDelegate:self];
[UIView setAnimationDidStopSelector:@selector(finishedScatterAnimations:finished:context:)];  
[UIView setAnimationDuration:0.2f];

    for(UIView *icon in [self icons]){
        icon.center = [self icon:icon centerForX:currentX andY:currentY unscatter:FALSE];
        //icon.alpha = 0.0;
        if(currentY == 2){
            if(currentX == 2 || currentX == 3){
                icon.alpha = 0.0;
            }
        }
        float scale = [self scaleForX:currentX andY:currentY];
        icon.transform = CGAffineTransformMakeScale(scale, scale);
        currentX = currentX + 1;
        if(currentX > 4){
            currentX = 1;
            currentY = currentY + 1;
        }
    }

    [UIView commitAnimations];
    [pool drain];
}

%new(@@:)
-(float)scaleForX:(int)currentX andY:(int)currentY{
    float scale = 1.0;
    if(currentY == 1){
        
        if(currentX == 1 || currentX == 4){
            scale = scale + 3.0;
        }
    }
    else{
        if(currentY == 2){
            if(currentX == 1 || currentX == 4){
            scale = 3.0;
            } 
            if(currentX == 2 || currentX == 3){
            scale = 7.0;
            } 
        }
        else{
            if(currentY == 3){
                scale = 3.0;
        }
        else{
            if(currentY == 4){
            if(currentX ==1 || currentX == 4){
            scale = scale + 2.0;
            } 
            else{
                scale = scale + 7.0;
            }
        }
        } 
        }
    }
    return scale;
}

//Cheaty, slow, but beautiful.
%new(@@:)
-(UIView *)iconForX:(float)x andY:(float)y{
int currentX = 1;
int currentY = 1;
for(UIView *icon in [self icons]){
if(currentY == y){
if(currentX == x){
               return icon;
            }
        }
currentX = currentX + 1;
if(currentX > 4){
   currentX = 1;
   currentY = currentY + 1;
        }
}

}


%new(@@:)
-(CGPoint)xyForIcon:(UIView *)oldIcon{
float currentX = 1;
float currentY = 1;
for(UIView *icon in [self icons]){
if([icon isEqual:oldIcon]){
    return CGPointMake(currentX, currentY);
}
        currentX = currentX + 1;
        if(currentX > 4){
            currentX = 1;
            currentY = currentY + 1;
        }
}
}

%new(@@:)
-(CGPoint)icon:(UIView *)icon centerForX:(int)currentX andY:(int)currentY unscatter:(BOOL)unscatter{
    float xOrigin;
    float yOrigin;
        if(currentX < 3){

            if(!unscatter) xOrigin = icon.center.x - 200;
            if(unscatter) xOrigin = icon.center.x + 200;

            if(currentY == 2){
               if(!unscatter) xOrigin = xOrigin - 25;
               if(unscatter) xOrigin = xOrigin + 25;

                if(currentX == 2){
                  if(!unscatter)  xOrigin = xOrigin + 225;
                  if(unscatter)  xOrigin = xOrigin - 225;
                }
            }
            if(currentY == 3){
                if(!unscatter) xOrigin = xOrigin - 50;
                if(unscatter) xOrigin = xOrigin + 50;
            }
        }
        if(currentX >= 3){
            if(!unscatter) xOrigin = icon.center.x + 50;
            if(unscatter) xOrigin = icon.center.x - 50;

            if(currentY == 2){

               if(!unscatter) xOrigin = xOrigin + 175;
             if(unscatter) xOrigin = xOrigin - 175;

                if(currentX == 3){

                if(!unscatter) xOrigin = xOrigin - 225;
                 if(unscatter) xOrigin = xOrigin + 225;
                }
            }
            if(currentY == 3){

                if(!unscatter) xOrigin = xOrigin - 25;
                if(unscatter) xOrigin = xOrigin + 25;
            }
        }
        if(currentY == 1){

           if(!unscatter) yOrigin = icon.center.y - 500;
           if(unscatter) yOrigin = icon.center.y + 500;

            if(currentX == 2){

               if(!unscatter) yOrigin = yOrigin - 125;
               if(unscatter) yOrigin = yOrigin + 125;

            }
            if(currentX == 3){
              if(!unscatter)  yOrigin = yOrigin - 150;
              if(unscatter)  yOrigin = yOrigin + 150;
            }
        }
        if(currentY == 2){

            if(!unscatter) yOrigin = icon.center.y + 200;
            if(unscatter) yOrigin = icon.center.y - 200;

            if(currentX == 1){

              if(!unscatter)  yOrigin = yOrigin - 50;
              if(unscatter)  yOrigin = yOrigin + 50;

            }
            if(currentX == 2){

              if(!unscatter)  yOrigin = yOrigin - 200;
              if(unscatter)  yOrigin = yOrigin + 200;

            }
            if(currentX == 3){

              if(!unscatter)  yOrigin = yOrigin - 200;
              if(unscatter)  yOrigin = yOrigin + 200;
            }
            if(currentX == 4){

              if(!unscatter)  yOrigin = yOrigin - 50;
              if(unscatter)  yOrigin = yOrigin + 50;
            }
        }
        if(currentY == 3){

            if(!unscatter) yOrigin = icon.center.y + 600;
            if(unscatter) yOrigin = icon.center.y - 600;

            if(currentX == 2){

               if(!unscatter) yOrigin = yOrigin + 150;
               if(unscatter) yOrigin = yOrigin - 150;

            }
            if(currentX == 3){

                if(!unscatter) yOrigin = yOrigin + 175;
                if(unscatter) yOrigin = yOrigin - 175;

            }
        }
        if(currentY == 4){

           if(!unscatter) yOrigin = icon.center.y + 800;
           if(unscatter) yOrigin = icon.center.y - 800;

            if(currentX == 2){

                if(!unscatter) yOrigin = yOrigin + 125;
                if(unscatter) yOrigin = yOrigin - 125;

            }
            if(currentX == 3){

                if(!unscatter) yOrigin = yOrigin + 150;
                if(unscatter) yOrigin = yOrigin - 150;
            }
        }
        return CGPointMake(xOrigin, yOrigin);
}

%new(v@:)
-(void)setEnabled:(BOOL)enabled{
   // iconAnimationEnabled = enabled;
}

%new(v@:)
- (void)finishedScatterAnimations:(NSString *)animationID finished:(BOOL)finished context:(void *)context{
[self layoutIconsNow];

}

-(void)stopJittering{
	%orig;
	if(![[%c(SBAwayController) sharedAwayController] isLocked] && snapShotApps && [self isEqual:[[%c(SBIconController) sharedInstance] currentIconList]]){
	[[%c(SBIconController) sharedInstance] scrollToIconListAtIndex:0 animate:TRUE]; //Go to the first screen first...
	[self performSelector:@selector(startHomescreenSnapshotThread) withObject:nil afterDelay:0.5];
}
}

%new(v@:)
-(void)startHomescreenSnapshotThread{
	[self performSelectorInBackground:@selector(makeHomescreenSnapshot) withObject:nil];
}

%new(v@:)
-(void)makeHomescreenSnapshot{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *iconLists = [[%c(SBIconModel) sharedInstance] iconLists];
	SBIconList *dock = [[%c(SBIconModel) sharedInstance] buttonBar];
	//UIView *dock = [[%c(SBUIController) sharedInstance] valueForKey:@"buttonBarContainerView"];
	SBIconList *firstPage = [iconLists objectAtIndex:0];
	//SBButtonBar *dock = [[objc_getClass("SBIconModel") sharedInstance] buttonBar];
	/*
	for(SBIconList *list in iconLists){
		if([list isDock]){
			dock = list;
		}
	}
	*/

UIGraphicsBeginImageContext(CGSizeMake(320,480));
CGContextRef ctx = UIGraphicsGetCurrentContext();
[firstPage.layer renderInContext:ctx];

UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

UIGraphicsBeginImageContext(dock.superview.bounds.size);
CGContextRef ctx2 = UIGraphicsGetCurrentContext();
[dock.superview.layer renderInContext:ctx2];
UIImage *dockImage = UIGraphicsGetImageFromCurrentImageContext();
//NSData *croppedImage = UIImagePNGRepresentation(image);
UIGraphicsBeginImageContext(CGSizeMake(152,228));
[image drawInRect:CGRectMake(0, 0, 152, 228)];
[dockImage drawInRect:CGRectMake(0, 228 - (dock.superview.frame.size.height/2.105), 152, dock.superview.frame.size.height/2.105)];
UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
[UIImagePNGRepresentation(destImage) writeToFile:@"/var/mobile/Library/WD7UI/LaunchImages/com.apple.springboard.png" atomically:TRUE];
UIGraphicsEndImageContext();


[pool drain];
}
%end

%hook SBApplicationIcon

-(void)launch{
    iconListCount = 1;
    
    if(![self isInDock]){

    if(iconAnimationEnabled){
    shouldAnimateApp = TRUE;
    lastLaunchedIcon = self;
}
}
    %orig;
}

-(void)dealloc{
	%orig;
	lastLaunchedIcon = nil;
	shouldAnimateApp = FALSE;
}
%end

static UIAlertView *blurAlert;
static BOOL changedWallpaper = FALSE;
//Making the blurs of the homescreen wallpapers.
%hook SetWallpaperSheet

-(void)setLockScreen{

	if(!blurAlert){
	blurAlert =
        [[UIAlertView alloc] initWithTitle:nil
                             message: @"Applying Wallpaper and creating blurs. This may take a moment."
                             delegate: self
                             cancelButtonTitle:nil
                             otherButtonTitles: nil];
    [blurAlert show];
}
changedWallpaper = TRUE;
	%orig;
}

-(void)setHomeScreen{
		
	if(!blurAlert){
	blurAlert =
        [[UIAlertView alloc] initWithTitle:nil
                             message: @"Applying Wallpaper and creating blurs. This may take a moment."
                             delegate: self
                             cancelButtonTitle:nil
                             otherButtonTitles: nil];
    [blurAlert show];
}
changedWallpaper = TRUE;
%orig;
}

-(void)setBoth{
	
if(!blurAlert){
	blurAlert =
        [[UIAlertView alloc] initWithTitle:nil
                             message: @"Applying Wallpaper and creating blurs. This may take a moment."
                             delegate: self
                             cancelButtonTitle:nil
                             otherButtonTitles: nil];
    [blurAlert show];
}
changedWallpaper = TRUE;
	%orig;
}

-(void)dealloc{
%orig;

if(changedWallpaper){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];


UIImage *image = [[UIImage imageWithContentsOfFile:@"/var/mobile/Library/LockBackground.jpg"] stackBlur:30];
[UIImagePNGRepresentation(image) writeToFile:@"/var/mobile/Library/LockWallpaperBlurred.png" atomically:TRUE];


UIImage *image2 = [[UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeBackground.jpg"] stackBlur:30];
[UIImagePNGRepresentation(image2) writeToFile:@"/var/mobile/Library/HomeWallpaperBlurred.png" atomically:TRUE];

//Lighter and darker versions. Could be useful.
[UIImagePNGRepresentation([[UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeWallpaperBlurred.png"] tintedImageUsingColor:[UIColor colorWithWhite:1.0 alpha:0.4]]) writeToFile:@"/var/mobile/Library/HomeWallpaperBlurred_light.png" atomically:TRUE];
[UIImagePNGRepresentation([[UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeWallpaperBlurred.png"] tintedImageUsingColor:[UIColor colorWithWhite:0.0 alpha:0.4]]) writeToFile:@"/var/mobile/Library/HomeWallpaperBlurred_dark.png" atomically:TRUE];
[UIImagePNGRepresentation([[UIImage imageWithContentsOfFile:@"/var/mobile/Library/LockWallpaperBlurred.png"] tintedImageUsingColor:[UIColor colorWithWhite:1.0 alpha:0.4]]) writeToFile:@"/var/mobile/Library/LockWallpaperBlurred_light.png" atomically:TRUE];
[UIImagePNGRepresentation([[UIImage imageWithContentsOfFile:@"/var/mobile/Library/LockWallpaperBlurred.png"] tintedImageUsingColor:[UIColor colorWithWhite:0.0 alpha:0.4]]) writeToFile:@"/var/mobile/Library/LockWallpaperBlurred_dark.png" atomically:TRUE];
[UIImagePNGRepresentation([[UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeWallpaperBlurred_dark.png"] croppedToRect:CGRectMake(0,381, 320, 91)]) writeToFile:@"/var/mobile/Library/AppSwitcherBG.png" atomically:TRUE];
[UIImagePNGRepresentation([[[UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeWallpaperBlurred.png"] croppedToRect:CGRectMake(0,381, 320, 91)] tintedImageUsingColor:[UIColor colorWithWhite:1.0 alpha:0.2]]) writeToFile:@"/var/mobile/Library/AppSwitcherBG_light.png" atomically:TRUE];

[blurAlert dismiss];
[blurAlert release];
changedWallpaper = FALSE;
[pool drain];
}
}
%end


@interface SBFolder : UIWindow{
	//SBIcon* folderSBIconRef;
	UIImageView* top;
	UIImageView* btm;
	UIImageView* topSub;
	UIImageView* btmSub;
	UIView* iconList;
	UITextField* title;
	CGPoint divisionPoint;
	BOOL inDock;
	BOOL animating;
	BOOL isJittering;
	BOOL isRenaming;
	BOOL offsetForKeyboard;
	BOOL statusBarHidden;
	NSString* displayName;
	NSString* displayIdentifier;
	float verticalPosition;
	float folderHeight;
	float moveUpBy;
	float moveDownBy;
	float folderBadgeValue;
	UIImageView* folderIcon;
	UIImageView* titleEditBar;
	NSMutableArray* iconState;

	//UIKeyboard* keyboard;
}

@property(assign, nonatomic) float verticalPosition;
@property(assign, nonatomic) CGPoint divisionPoint;
@property(assign, nonatomic) float folderHeight;
@property(assign, nonatomic) BOOL isJittering;
@property(assign, nonatomic) BOOL isRenaming;
@property(assign, nonatomic) BOOL inDock;
//@property(retain, nonatomic) SBIcon* folderSBIconRef;
@property(retain, nonatomic) UIView* iconList;
@property(retain, nonatomic) NSString* displayName;
@property(retain, nonatomic) NSString* displayIdentifier;
@property(retain, nonatomic) NSMutableArray* iconState;
+(void)popAppToSpringboard:(id)springboard;
-(id)initWithFrame:(CGRect)frame;
-(void)initWithApps:(id)apps;
-(id)sectionOfScreen:(CGRect)screen type:(int)type;
-(id)masked:(id)masked which:(int)which;
-(id)borderLayer;
-(void)touchesEnded:(id)ended withEvent:(id)event;
-(void)animateIn:(BOOL)anIn;
-(void)exitFolder;
-(void)animationDone:(id)done finished:(id)finished context:(void*)context;
-(void)showStatusBar:(BOOL)bar;
-(void)saveFolderName;
-(void)saveFolderIconState;
-(void)launchAppWithDisplayIdentifier:(id)displayIdentifier;
-(void)setTitleEditBarVisible:(BOOL)visible animated:(BOOL)animated;
-(void)presentKeyboardAndEditField:(BOOL)field;
-(void)removeAppFromFolder:(id)folder destructiveErase:(BOOL)erase;
-(void)eraseEmptyFolder;
-(void)relayoutIcons;
-(void)dealloc;
@end


//%class SBApplicationIcon
%class SBApplication

%hook SBFolder

%new(@@:)
- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {

   CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef); 
    return cropped;
}

-(void)initWithApps:(id)apps{
	//NSLog(@"Apps: %@ class: %@", apps, [apps class]);
if(!iOS4Folders && isWhited00r){
[self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeWallpaperBlurred_dark.png"]]];
	//%orig;

UIImageView *top = [self valueForKey:@"top"];
UIImageView *bottom = [self valueForKey:@"btm"];
[[self valueForKey:@"topSub"] setHidden:TRUE];
[[self valueForKey:@"btmSub"] setHidden:TRUE];
[top removeFromSuperview];
[bottom removeFromSuperview];
self.alpha = 0.0;
[UIView beginAnimations:nil context:nil];
[UIView setAnimationDuration:0.3];
[UIView setAnimationDidStopSelector:@selector(animationDone:finished:context:)];
[UIView setAnimationDelegate:self];
[[self valueForKey:@"folderIcon"] setAlpha:0.0];
self.alpha = 1.0;
[[[%c(SBIconController) sharedInstance] currentIconList] setAlpha:0.0];
[UIView commitAnimations];

//UIView *iconList = [self valueForKey:@"iconList"];
//iconList.frame = CGRectMake(30,160,240, 240);
//iconList.backgroundColor = [UIColor whiteColor];
[self relayoutIcons];
}
%orig;
}

-(void)animationDone:(id)done finished:(id)finished context:(void*)context{
	%orig;
//NSLog(@"Done: %@, finished: %@", done, finished);
}

-(id)borderLayer{
if(!iOS4Folders && isWhited00r){
	return nil;
}
else{
	return %orig;
}
}

-(id)sectionOfScreen:(CGRect)screen type:(int)type{
if(!iOS4Folders && isWhited00r){
	return nil;
}
else{
	return %orig;
}
//screen.size.height = screen.size.height - 60;
//return [self cropImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeWallpaperBlurred.png"] toRect:screen];
}

-(void)exitFolder{
if(!iOS4Folders && isWhited00r){
	self.alpha = 1.0;
[UIView beginAnimations:nil context:nil];
[UIView setAnimationDuration:0.2];
[UIView setAnimationDidStopSelector:@selector(animationDone:finished:context:)];
[UIView setAnimationDelegate:self];
self.alpha = 0.0;
[[self valueForKey:@"folderIcon"] setAlpha:1.0];
[[[%c(SBIconController) sharedInstance] currentIconList] setAlpha:1.0];
[UIView commitAnimations];
}
%orig;
}

- (void)animateIn:(BOOL)animate{

if(!iOS4Folders && isWhited00r){

if(animate){
[[self valueForKey:@"folderIcon"] setAlpha:0.0];
}
else{


//[self exitFolder];
%orig;
}
}
else{
	%orig;
}

}



%end


//--------------TelephonyUI stuff---------------------\\

%hook TPBottomDualButtonBar


-(void)setButton:(id)button{
[button setDontModify:TRUE];
%orig;
}

-(void)setButton2:(id)a2{
	[a2 setDontModify:TRUE];
	%orig;
}

%end


%hook TPBottomButtonBar
-(void)setButton:(id)button{
[button setDontModify:TRUE];
%orig;
}

%end


//--------------------Preferences cells----------------------\\
/*
%hook UIPreferencesTableCell
-(void)setFrame:(CGRect)frame{
	CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, 320, frame.size.height);
	%orig(newFrame);
}

-(void)drawBackgroundInRect:(CGRect)frame withFade:(float)fade{
	CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, 320, frame.size.height);
	%orig(newFrame, fade);
}
%end
*/


//-----------------------------iOS 7 Style Text Buttons---------------------------\\

@interface UIPushButton
BOOL shouldKeepOriginal;
BOOL drawLine;
-(void)setDontModify:(BOOL)modify;
-(void)setDrawLine:(BOOL)modify;
@end

%hook UIPushButton
-(void)setImage:(id)image forState:(unsigned)state{
    if([self title] && !shouldKeepOriginal){
        image = nil;

    }

    %orig;
}

-(void)setTitleColor:(id)color forState:(unsigned)state{
    if(!shouldKeepOriginal){
    if(state == UIControlStateNormal){
        color = [UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
    if(state == UIControlEventTouchDown){
        color = [UIColor blackColor];
    }
}
    %orig;
}

-(void)setShadowColor:(id)color forState:(unsigned)state{
    if([self title] && !shouldKeepOriginal){

        color = [UIColor clearColor];

    }

    %orig;
}

-(void)setBackground:(id)background forState:(unsigned)state{
    if([self title] && !shouldKeepOriginal){
        background = nil;

    }

    %orig;
}

%new(v@:)
-(void)setDrawLine:(BOOL)line{
    drawLine = line;
}

-(void)drawRect:(CGRect)rect{
    %orig;

    if([self title] && !shouldKeepOriginal && drawLine){
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
           CGContextRef context = UIGraphicsGetCurrentContext(); 

        CGContextSetLineWidth(context, 1.0);

        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:240/255.0 green:220.0/255.0 blue:240.0/255.0 alpha:1.0].CGColor);

        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, rect.size.width, 0);

        CGContextStrokePath(context);
       [pool drain];
    }

}

//This will help later on down the road.
%new(v@:)
-(void)setDontModify:(BOOL)modify{
    shouldKeepOriginal = modify;
}
%end

//Fixing the phone app
%hook DialerButton
-(void)setDialerController:(id)controller{
    [self setDontModify:TRUE];
    %orig;
}

%end

@interface UITabBarButton
BOOL isSelected;
BOOL wasRed;
@end

%hook UITabBarButton

+(id)_defaultLabelColor{
    return [UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
}

-(void)_setSelected:(BOOL)selected{
    %orig;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    isSelected = selected;
    if(selected){
        UILabel *label = [self valueForKey:@"label"];
        if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
        label.textColor = [UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0];
        wasRed = TRUE;
        }
        else{
        wasRed = FALSE;
        label.textColor = [UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0];
        }

    }
    else{
        UILabel *label = [self valueForKey:@"label"];
        label.textColor = [UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
    }
    [pool drain];

}

-(id)initWithImage:(id)image selectedImage:(id)image2 label:(id)label withInsets:(UIEdgeInsets)insets{

if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    image2 = [image2 tintedImageUsingColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0]];
}
else{
    image2 = [image2 tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}

image = [image tintedImageUsingColor:[UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0]];

        

    return %orig;
}

%end



%hook UIBarButtonItem
-(id)initWithTitle:(NSString *)title style:(int)style target:(id)target action:(SEL)action{
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point

    [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
     if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
        [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    else{
    [button setTitleColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [[button titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];

    CGRect buttonFrame = [button frame];
    buttonFrame.size.width = [title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].width + 24.0;
    buttonFrame.size.height = [title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].height + 10;
    [button setFrame:buttonFrame];

    [button setTitle:title forState:UIControlStateNormal];

    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    //UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(id)initWithImage:(id)image style:(int)style target:(id)target action:(SEL)action{
   if([image isMemberOfClass:[UIImage class]]){
    if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    image = [image tintedImageUsingColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0]];
}
else{
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
}

    return %orig;

}

-(void)setTitle:(NSString *)title{
    if([self.customView isMemberOfClass:[UIButton class]]){
        [self.customView setTitle:title forState:UIControlStateNormal];
    }
    else{

        %orig;
    }

}

-(id)initWithBarButtonSystemItem:(int)barButtonSystemItem target:(id)target action:(SEL)action{
    if(barButtonSystemItem == 4){
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:34.0]];
     if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
        [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    else{
    [button setTitleColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [[button titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];

    CGRect buttonFrame = [button frame];
    buttonFrame.size.width = [[NSString stringWithFormat:@"+"] sizeWithFont:[UIFont boldSystemFontOfSize:34.0]].width + 24.0;
    buttonFrame.size.height = [[NSString stringWithFormat:@"+"] sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].height + 10;
    [button setFrame:buttonFrame];



    [button setTitle:@"+" forState:UIControlStateNormal];

    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    //UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

return [[UIBarButtonItem alloc] initWithCustomView:button];
}
else{
self = %orig;

  return self;  
} 
}



-(void)setImage:(UIImage*)image{

if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"]){
    image = [image tintedImageUsingColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0]];
}
else{
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
%orig;
}




%end


//---------------Tab bar pill things--------------------------------\\

%hook UIToolbarButton

-(id)initWithImage:(id)image selectedImage:(id)image2 label:(UILabel*)label labelHeight:(float)height withBarStyle:(int)barStyle withStyle:(int)style withInsets:(UIEdgeInsets)insets possibleTitles:(id)titles withTintColor:(id)tintColor bezel:(BOOL)bezel imageInsets:(UIEdgeInsets)insets11 glowInsets:(UIEdgeInsets)insets12{
if(label){
    image = nil;
    image2 = nil;
    bezel = FALSE;
    label.textColor = [UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0];
    tintColor = [UIColor clearColor];
}

if([image isMemberOfClass:[UIImage class]]){
image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}

if([image2 isMemberOfClass:[UIImage class]]){
    if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    image2 = [image2 tintedImageUsingColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0]];
}
else{
    image2 = [image2 tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
}

    return %orig;

}


-(void)setImage:(UIImage*)image{
if([self _isOn]){
if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
else{
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
}
else{

image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
%orig(image);
}


%end
/*
%hook UIToolbarTextButton


-(void)layoutSubviews{
    %orig;


    UIView *background = [self valueForKey:@"info"];
        for (UIView *subview in background.subviews){
        if ([subview isMemberOfClass:[UIImageView class]]) {
           subview.hidden = YES; //Hide UIImageView Containing Blue Background
        }
        if ([subview isMemberOfClass:[UILabel class]]) { //Point to UILabels To Change Text
            UILabel *titleLabel = (UILabel*)subview; //Cast From UIView to UILabel
            titleLabel.backgroundColor = [UIColor clearColor];
    if(![self _isOn]){

    titleLabel.textColor = [UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0];

    }
    else{
        titleLabel.textColor = [UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
    }
        }
    }

}



%end



*/

%hook UIToolbar


-(void)layoutSubviews{
    self.tintColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    %orig;
}


-(void)setButtonItems:(id)items{
    for(UIBarButtonItem *item in items){
        if(item.image){
            if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
                item.image = [item.image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
            }
            else{
                item.image = [item.image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
            }
        }
    }
    %orig;
}
%end
/*
%hook UINavigationBar
-(void)layoutSubviews{
    %orig;
    
    for (UIView *subview in self.subviews) {
    if ([subview isMemberOfClass:[UIImageView class]]) {
           subview.hidden = YES; //Hide UIImageView Containing Blue Background
        }
        if ([subview isMemberOfClass:[UILabel class]]) { //Point to UILabels To Change Text
            UILabel *titleLabel = (UILabel*)subview; //Cast From UIView to UILabel
            titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor =  [UIColor blackColor];
    }
}

}

%end
*/
@interface UINavigationButton : UIButton
@property(assign, nonatomic) int style;
@property(assign, nonatomic) int barStyle;
@property(retain, nonatomic) UIColor* tintColor;
@property(assign, nonatomic) int controlSize;
@property(retain, nonatomic) UIImage* image;
@property(retain, nonatomic) NSString* title;
@end

%hook UINavigationButton

-(id)_backgroundForState:(unsigned)state usesBackgroundForNormalState:(BOOL*)normalState{
    if(self.title){
        return nil;
    }
    return %orig;
}

-(id)_imageForState:(unsigned)state usesImageForNormalState:(BOOL*)normalState{
    if(self.title){
        return nil;
    }
    return %orig;
}

/*
-(id)initWithImage:(UIImage*)image{
self = %orig;
if(self){
if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
else{
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
}

return self;
}

-(id)initWithImage:(UIImage*)image width:(float)width style:(int)style{
self = %orig;
if(self){
if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
else{
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
}

return self;
}

-(id)initWithImage:(UIImage*)image style:(int)style{
self = %orig;
if(self){
if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
else{
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
}

return self;
}
*/

-(id)initWithTitle:(id)title{
self = %orig;
if(self){
    if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
        [self setTitleColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    else{
  [self setTitleColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    [self setImage:NULL forState:UIControlStateNormal];
    [self setImage:NULL forState:UIControlStateHighlighted];
    [self setBackgroundImage:NULL forState:UIControlStateNormal];
    [self setBackgroundImage:NULL forState:UIControlStateHighlighted];
    [[self valueForKey:@"backgroundView"] setHidden:TRUE];
    [[self valueForKey:@"imageView"] setHidden:TRUE];
    [self setTitleColor:[UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [[self titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
    [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
    CGRect buttonFrame = [self frame];
    buttonFrame.size.width = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].width + 24.0;
    buttonFrame.size.height = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].height + 10;
}
return self;
}

-(id)initWithTitle:(id)title style:(int)style{
self = %orig;
if(self){
    if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
        [self setTitleColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    else{
  [self setTitleColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    [self setImage:NULL forState:UIControlStateNormal];
    [self setImage:NULL forState:UIControlStateHighlighted];
    [self setBackgroundImage:NULL forState:UIControlStateNormal];
    [self setBackgroundImage:NULL forState:UIControlStateHighlighted];
    [[self valueForKey:@"backgroundView"] setHidden:TRUE];
    [[self valueForKey:@"imageView"] setHidden:TRUE];
    [self setTitleColor:[UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [[self titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
    [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
    CGRect buttonFrame = [self frame];
    buttonFrame.size.width = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].width + 24.0;
    buttonFrame.size.height = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].height + 10;
}
return self;
}

-(id)initWithTitle:(id)title possibleTitles:(id)titles style:(int)style{
self = %orig;
if(self){
    if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
        [self setTitleColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    else{
  [self setTitleColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    [self setImage:NULL forState:UIControlStateNormal];
    [self setImage:NULL forState:UIControlStateHighlighted];
    [self setBackgroundImage:NULL forState:UIControlStateNormal];
    [self setBackgroundImage:NULL forState:UIControlStateHighlighted];
    [[self valueForKey:@"backgroundView"] setHidden:TRUE];
    [[self valueForKey:@"imageView"] setHidden:TRUE];
    [self setTitleColor:[UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [[self titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
    [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
    CGRect buttonFrame = [self frame];
    buttonFrame.size.width = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].width + 24.0;
    buttonFrame.size.height = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].height + 10;
}
return self;   
}

-(id)initWithValue:(id)value width:(float)width style:(int)style barStyle:(int)style4 possibleTitles:(id)titles tintColor:(id)color{
self = %orig;
if(self){
    if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
        [self setTitleColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    else{
  [self setTitleColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }



    [self setTitleColor:[UIColor colorWithRed:100/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [[self titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
    [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
    CGRect buttonFrame = [self frame];
    buttonFrame.size.width = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].width + 24.0;
    buttonFrame.size.height = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]].height + 10;
    [self setFrame:buttonFrame];

}
return self; 
}
%end

//UISegment stuff (Calendar app, and more)
@interface UISegment : UIView
BOOL shouldRemoveBackground;
@property(assign) int controlSize;
@property(assign, getter=isHighlighted) BOOL highlighted;
@property(assign, getter=isSelected) BOOL selected;
-(void)setRemoveBackground:(BOOL)removeIt;
@end

%hook UISegmentedControl

-(void)setTransparentBackground:(BOOL)background{
    %orig(TRUE);
}

-(void)layoutSubviews{

    if(self.selectedSegmentIndex == -1){
        for(UISegment *segment in [self valueForKey:@"segments"]){
            
            [segment setRemoveBackground:TRUE];

        }
    }
    else{
        for(UISegment *segment in [self valueForKey:@"segments"]){
            
            [segment setRemoveBackground:FALSE];
            //[segment layoutSubviews];
         
        }
    }
  %orig;  
}
%end




%hook UISegment
-(void)setShowDivider:(BOOL)divider{
    if(shouldRemoveBackground){
    %orig(FALSE);
}
else{
%orig;
}
}

-(void)setTintColor:(UIColor*)color{
if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    color = [UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0];
}
else{
   color = [UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0];
}
%orig;
}

/*
-(void)_tileImage:(UIImage*)image inRect:(CGRect)rect{
if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    image = [image tintedImageUsingColor:[UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0]];
}
else{
    image = [image tintedImageUsingColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0]];
}
%orig;
}
*/

-(void)_updateTextColors{
   %orig;
   
  for (UIView *subview in [self subviews]) {
    if ([subview isKindOfClass:[UILabel class]] || [subview isMemberOfClass:[UILabel class]] || [subview isMemberOfClass:[objc_getClass("UISegmentLabel") class]]) {
        UILabel *label=(UILabel *)subview;
        label.shadowColor = [UIColor clearColor];
        if(!self.selected){
        if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
            label.textColor = [UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0];
        }
        else{
            label.textColor = [UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0];
        }
    }
    else{
       label.textColor = [UIColor colorWithRed:240/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    }
    }
}  

}


-(id)initWithInfo:(id)info style:(int)style size:(int)size barStyle:(int)style4 tintColor:(UIColor*)color position:(unsigned)position isDisclosure:(BOOL)disclosure autosizeText:(BOOL)text{
self = %orig;
if(self){
if([[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobiletimer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-MediaPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod-AudioPlayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"Music"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobileipod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilemusicplayer"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"iPod"] || [[[UIApplication sharedApplication] displayIdentifier] isEqualToString:@"com.apple.mobilecal"]){
    color = [UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:83.0/255.0 alpha:1.0];
}
else{
   color = [UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0];
}

}
return self;
}

-(void)_updateTexturedBackgroundImage{
    if([self infoName] && !shouldRemoveBackground){
       // NSLog(@"SET REMOVEBACKGROUND to 'FALSE' in updateTexturedBackgroundImage for title: %@", [self infoName]);
        %orig;
    }
}

-(void)_updateBackgroundImage{
    if([self infoName] && !shouldRemoveBackground){
   // NSLog(@"SET REMOVEBACKGROUND to 'FALSE' in updateBackgroundImage for title: %@", [self infoName]);
        %orig;
    }
}

%new(v@:)
-(void)setRemoveBackground:(BOOL)removeIt{
 
    shouldRemoveBackground = removeIt;
}

-(void)_tileImage:(id)image inRect:(CGRect)rect{
    if([self infoName] && !shouldRemoveBackground){
       // NSLog(@"SET REMOVEBACKGROUND to 'FALSE' in tileImage for title: %@", [self infoName]);
        %orig;
    }
}
%end


//---------------------------Spotlight controling, mainly to hide it when not needed.-----------------------\\
%hook SBSearchView
-(BOOL)_initializeKeyboardIfNotBricked{
    if(!spotlightEnabled){
        return FALSE;
    }
    else{
        return %orig;
    }
}

%end

%hook SBIconController

-(BOOL)isShowingSearch{
    if(!spotlightEnabled){
        return FALSE;
    }
    else{
        return %orig;
    }
}


-(void)scrollLeft{
    if(!spotlightEnabled && [self valueForKey:@"currentIconListIndex"] == 0){
return;
    }
    else{
        %orig;
    }
}
%end

%hook SBIconScrollView

-(void)setContentOffset:(CGPoint)offset{

if(!spotlightEnabled){
if(offset.x >= 320){
%orig;
}
else{
    offset.x = 320;
    %orig;
}

}
else{
    %orig;
}
}

%end