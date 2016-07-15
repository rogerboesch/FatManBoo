//
//  RBMacros.h
//  RBFramework\BaseKit
//
//  Written by Roger Boesch on 01/01/09. All rights reserved.
//  Art & Bits (www.artandbits.com)
//
//  Information:
//  This is the only RBKit file which must be in the pch file of a project.
//
//  Build settings:
//  -RB_IPHONEOS when target is iPhone/iPod Toch
//  -RB_MACOSX when target is MacOSX
//  -RB_DEBUG to activate debug messages
//  -RB_LOGGING to include logging behavior

#ifndef __IPHONE_3_2
#define __IPHONE_3_2 30200
#endif

#define IPAD_SDK	(__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2)
#define IPHONE_SDK	(__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_3_2)

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Localization stuff

#define RBAppString(textKey) [[RBLanguageController sharedInstanceOf] textForKey:textKey]
#define RBCheckLanguage(language) [[RBLanguageController sharedInstanceOf] checkLanguage:language]

#define RBLocalizedString(str) NSLocalizedString(str, @"")
#define RBFormatLocalizedString1(fmt, arg1) [NSString stringWithFormat:NSLocalizedString(fmt, @""), arg1]
#define RBFormatLocalizedString2(fmt, arg1, arg2) [NSString stringWithFormat:NSLocalizedString(fmt, @""), arg1, arg2]
#define RBFormatLocalizedString3(fmt, arg1, arg2, arg3) [NSString stringWithFormat:NSLocalizedString(fmt, @""), arg1, arg2, arg3]

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Helper methods

#define RBAlert(msg) { UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:RBLocalizedString(@"ButtonOK") otherButtonTitles:nil]; [alertView show]; [alertView autorelease];}
#define RBAlertWithTitle(msg, title) { UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:RBLocalizedString(@"ButtonOK") otherButtonTitles:nil]; [alertView show]; [alertView autorelease];}
#define RBLocalizedAlert(msg) { UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(msg, @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alertView show]; [alertView autorelease];}
#define RBLocalizedAlertWithTitle(title, msg) { UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, @"") message:NSLocalizedString(msg, @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alertView show]; [alertView autorelease];}
#define RBUID [[NSProcessInfo processInfo] globallyUniqueString]
#define RBHexToColor(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0];
#define RBSyncBlock(obj) ;

#define RBDeviceID [[UIDevice currentDevice] uniqueIdentifier]
#define RBOSNumber [[[UIDevice currentDevice] systemVersion] intValue]
#define RBDeviceName [UIDevice currentDevice].name

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Error handling

#define RBError(str) NSLog(@"ERROR: %@", str);
#define RBError1(fmt, arg) NSLog(fmt, arg);
#define RBError2(fmt, arg1, arg2) NSLog(fmt, arg1, arg2);
#define RBError3(fmt, arg1, arg2, arg3) NSLog(fmt, arg1, arg2, arg3);
#define RBLogException(ex) NSLog(@"EXC> %@", [ex name]);
#define RBException(ex) NSLog(@"EXC> %@", [ex name]);

// -----------------------------------------------------------------------------
// To use it RB_DEBUG hast to be set in Build Settings: GCC_PREPROCESSOR_DEFINITIONS
// The other macro is RB_DUMP, which allows to enable/disable object dumping

#pragma mark -
#pragma mark Debug and dump handling

#ifdef RB_DEBUG
#define RBDump(item) [item dump:YES];
#else
#define RBDump(item) ;
#endif

#ifdef RB_DEBUG
#define RBDebug(str) NSLog(@"(%@)> %@", [NSThread currentThread].name, str);
#define RBDebug1(fmt, arg) NSLog(@"(%@)> %@", [NSThread currentThread].name, [NSString stringWithFormat:fmt, arg]);
#define RBDebug2(fmt, arg1, arg2) NSLog(@"(%@)> %@", [NSThread currentThread].name, [NSString stringWithFormat:fmt, arg1, arg2]);
#define RBDebug3(fmt, arg1, arg2, arg3) NSLog(@"(%@)> %@", [NSThread currentThread].name, [NSString stringWithFormat:fmt, arg1, arg2, arg3]);
#define RBDebug4(fmt, arg1, arg2, arg3, arg4) NSLog(@"(%@)> %@", [NSThread currentThread].name, [NSString stringWithFormat:fmt, arg1, arg2, arg3, arg4]);

#define RBRelease(obj)   NSLog(@"REL> Retain count:%d (%@)", [obj retainCount], [obj class]); [obj release]; obj = nil;
#define RBReleaseSubview(obj) [obj removeFromSuperview]; NSLog(@"REL> Retain count:%d (%@)", [obj retainCount], [obj class]); [obj release]; obj = nil;
#define RBLogRetain(obj) NSLog(@"LOG> Retain count:%d (%@)", [obj retainCount], [obj class]);

#define RBLogRect(str, rect) NSLog(@"LOG> %@: %.02f, %.02f, %.02f, %.02f", str, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define RBLogPoint(str, point) NSLog(@"LOG> %@: %.02f, %.02f", str, point.x, point.y)
#define RBLogLocation(str, location) NSLog(@"LOG> %@: Lat=%f, Long:%f, Acc:%f", str, location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy)
#else
#define RBDebug(str) ;
#define RBDebug1(fmt, arg) ;
#define RBDebug2(fmt, arg1, arg2) ;
#define RBDebug3(fmt, arg1, arg2, arg3) ;
#define RBDebug4(fmt, arg1, arg2, arg3, arg4) ;
#define RBRelease(obj) [obj release]; obj = nil;
#define RBReleaseSubview(obj) [obj removeFromSuperview]; [obj release]; obj = nil;
#define RBLogRetain(obj) ;
#define RBLogRect(str, rect) ;
#define RBLogPoint(str, point) ;
#define RBLogLocation(str, location) ;
#endif

#define RANDOM(minNumber, maxNumber) random() % (maxNumber-minNumber+1) + minNumber
#define DEGREES_TO_RADIANS(x) (3.14159265358979323846 * x / 180.0)

// -----------------------------------------------------------------------------
// Localization helper

CG_INLINE NSArray*
RBLocalizedList(NSString *key) {
	NSString *str = RBLocalizedString(key);
	return [str componentsSeparatedByString:@","];
}


// -----------------------------------------------------------------------------
// Device utilities

#ifdef MAC_VERSION

CG_INLINE BOOL
RBDeviceHasSmallScreen() {
	return NO;
}

// Most be different, so on mac the comparison of this two result always in NO
#define UI_USER_INTERFACE_IDIOM() YES
#define UIUserInterfaceIdiomPad NO

#else

CG_INLINE BOOL
RBDeviceHasSmallScreen() {
	if ([UIScreen mainScreen].bounds.size.width == 320)
		return YES;
	else
		return NO;
}

#endif

// -----------------------------------------------------------------------------
// Color utilities

#pragma mark -
#pragma mark Color utilities

typedef struct {
	float red;
	float green;
	float blue;
	float alpha;
} RBColor;

CG_INLINE RBColor
RBColorMake(float red, float green, float blue, float alpha) {
	RBColor color;
	color.red = red;
	color.green = green;
	color.blue = blue;
	color.alpha = alpha;
	
	return color;
}

CG_INLINE RBColor
RBColorMakeWithRGB(int r, int g, int b) {
	RBColor color;
	color.red = r/255.0;
	color.green = g/255.0;
	color.blue = b/255.0;
	color.alpha = 1.0;
	
	return color;
}

CG_INLINE RBColor
RBColorMakeWithRGBA(int r, int g, int b, float a) {
	RBColor color;
	color.red = r/255.0;
	color.green = g/255.0;
	color.blue = b/255.0;
	color.alpha = a;
	
	return color;
}

#define RBContextSetRGBFillColor(context, color) CGContextSetRGBFillColor(context, color.red, color.green, color.blue, color.alpha)
#define RBUIColor(color) [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:color.alpha];

#define RBColorAlpha0 RBColorMake(1.0, 1.0, 1.0, 0.0)
#define RBColorAlpha25 RBColorMake(1.0, 1.0, 1.0, 0.25)
#define RBColorAlpha50 RBColorMake(1.0, 1.0, 1.0, 0.50)
#define RBColorAlpha75 RBColorMake(1.0, 1.0, 1.0, 0.75)
#define RBColorAlpha100 RBColorMake(1.0, 1.0, 1.0, 1.0)
#define RBColorRed RBColorMake(1.0, 0.0, 0.0, 1.0)
#define RBColorGreen RBColorMake(0.0, 1.0, 0.0, 1.0)
#define RBColorBlue RBColorMake(0.0, 0.0, 1.0, 1.0)
#define RBColorBlack RBColorMake(0.0, 0.0, 0.0, 1.0)
#define RBColorWhite RBColorMake(1.0, 1.0, 1.0, 1.0)
