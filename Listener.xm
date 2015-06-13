#import "libactivator.h"
#import <substrate.h>

@interface SBIconList : NSObject
-(NSArray*)icons;
@end
@interface SBIconController : NSObject
+(instancetype)sharedInstance;
-(SBIconList*)currentRootIconList;
@end
@interface SBIcon : NSObject
@end
@interface SBIconView : UIView
@property (nonatomic, retain) SBIcon* icon;
@end
@interface SBIconViewMap : NSObject
+(instancetype)homescreenMap;
-(SBIconView*)mappedIconViewForIcon:(SBIcon*)icon;
@end

@interface NiceMemeController : NSObject {
	BOOL _isActive;
	UIView* _iconContainerView;
}
+(instancetype)sharedInstance;
-(BOOL)isAlreadyShreked;
-(void)getShreked;
-(void)turntTooHard;
@end

@interface NiceMemeListener : NSObject<LAListener> 
{} 
@end

NiceMemeListener* meme;

@implementation NiceMemeListener
-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if ([[NiceMemeController sharedInstance] isAlreadyShreked]) [[NiceMemeController sharedInstance] turntTooHard];
	else [[NiceMemeController sharedInstance] getShreked];
}
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
	// Called when event is escalated to a higher event
	// (short-hold sleep button becomes long-hold shutdown menu, etc)
	[[NiceMemeController sharedInstance] turntTooHard];
}
- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
	// Called when some other listener received an event; we should cleanup
	[[NiceMemeController sharedInstance] turntTooHard];
}
- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
	// Called when the home button is pressed.
	// If (and only if) we are showing UI, we should dismiss it and call setHandled:
	[[NiceMemeController sharedInstance] turntTooHard];
}
+(void)load {
	if (!meme) meme = [[NiceMemeListener alloc] init];
	if ([LAActivator sharedInstance].isRunningInsideSpringBoard) [[LAActivator sharedInstance] registerListener:meme forName:@"com.phillipt.nicememe"];
}
@end

@implementation NiceMemeController
+ (id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}
-(SBIconView*)_sampleIconView {
	SBIconController* ic = (SBIconController *)[%c(SBIconController) sharedInstance];
	SBIcon* icon = [[[ic currentRootIconList] icons] objectAtIndex:0];
	return  [[%c(SBIconViewMap) homescreenMap] mappedIconViewForIcon:icon];
}
-(id)init {
	if ((self = [super init])) {
		_iconContainerView = [[self _sampleIconView] superview];
	}
	return self;
}
-(void)_adjustIconViewsToAlpha:(CGFloat)alpha {
	SBIconController* ic = (SBIconController *)[%c(SBIconController) sharedInstance];
	NSArray *icons = [[ic currentRootIconList] icons];
	for (SBIcon* icon in icons) {
		SBIconView* iconView = [[%c(SBIconViewMap) homescreenMap] mappedIconViewForIcon:icon];
		[UIView animateWithDuration:0.5 animations:^{
			[iconView setAlpha:alpha];
		}];
	}
}
-(BOOL)isAlreadyShreked {
	return _isActive;
}
-(void)getShreked {
	if (_isActive) return;
	_isActive = YES;

	[self _adjustIconViewsToAlpha:0.0];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		UILabel* wowLabel = [[UILabel alloc] initWithFrame:_iconContainerView.frame];
		wowLabel.center = _iconContainerView.center;
	    wowLabel.textAlignment = NSTextAlignmentCenter;
	    wowLabel.textColor = [UIColor greenColor];
	    wowLabel.font = [UIFont boldSystemFontOfSize:72];
	    wowLabel.transform = CGAffineTransformScale(wowLabel.transform, 0.25, 0.25);
	    wowLabel.numberOfLines = 1;
	    wowLabel.text = @"WOW!";
	    wowLabel.alpha = 0.0;
	    [_iconContainerView addSubview:wowLabel];

	    [UIView animateWithDuration:2.0 animations:^{
	    	wowLabel.alpha = 1.0;
	    	wowLabel.transform = CGAffineTransformScale(wowLabel.transform, 4, 4);
	    } completion:^(BOOL finished){
	    	if (finished) {
	    		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	    			UILabel* memeLabel = [[UILabel alloc] initWithFrame:_iconContainerView.frame];
					memeLabel.center = CGPointMake(_iconContainerView.center.x, _iconContainerView.center.y*3);
				    memeLabel.textAlignment = NSTextAlignmentCenter;
				    memeLabel.textColor = [UIColor purpleColor];
				    memeLabel.font = [UIFont boldSystemFontOfSize:72];
				    memeLabel.adjustsFontSizeToFitWidth = YES;
				    memeLabel.numberOfLines = 1;
				    memeLabel.text = @"Nice meme, friend!";
				    [_iconContainerView addSubview:memeLabel];

	    			[UIView animateWithDuration:2.0 animations:^{
	    				wowLabel.center = CGPointMake(wowLabel.center.x, -_iconContainerView.center.y);
	    				memeLabel.center = _iconContainerView.center;

	    				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	    					[UIView animateWithDuration:2.0 animations:^{
	    						memeLabel.alpha = 0.0;
	    						memeLabel.transform = CGAffineTransformScale(memeLabel.transform, 0.25, 0.25);
	    					} completion:^(BOOL finished){
	    						if (finished) {
	    							[self turntTooHard];
	    						}
	    					}];
	    				});
	    			}];
	    		});
	    	}
	    }];
	});
}
-(void)turntTooHard {
	if (!_isActive) return;
	_isActive = NO;

	[self _adjustIconViewsToAlpha:1.0];
}
@end
