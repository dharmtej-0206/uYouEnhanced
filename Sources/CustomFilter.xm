#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 1. TEXTURE (ASYNCDISPLAYKIT) INTERFACES
// This tells the compiler how to talk to Google's custom layout engine
@interface ASLayoutElementStyle : NSObject
@property (nonatomic, assign) CGSize preferredSize;
@end

@interface ASDisplayNode : NSObject
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, strong) ASLayoutElementStyle *style;
@end

@interface YTVideoWithContextNode : ASDisplayNode
@end

@interface YTCompactVideoNode : ASDisplayNode
@end

@interface YTCreatorEndscreenNode : ASDisplayNode
@end

@interface YTBrowseViewController : UIViewController
- (NSString *)browseIdentifier;
@end

@interface YTFullscreenEngagementOverlayView : UIView
@end


// 2. THE FILTERING ENGINE
static BOOL isBlockedContent(NSString *text) {
    if (!text) return NO;
    NSString *lowercaseText = [text lowercaseString];
    
    // KEEP EVERYTHING LOWERCASE
    NSArray *blockedKeywords = @[
        @"phonk",
        @"mrbeast", 
        @"t-series",
        @"specific channel name"
    ];
    
    for (NSString *keyword in blockedKeywords) {
        if ([lowercaseText containsString:keyword]) {
            return YES;
        }
    }
    return NO;
}

// 3. NUKE THE HOME FEED (Confirmed Working)
%hook YTBrowseViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    if ([self respondsToSelector:@selector(browseIdentifier)]) {
        if ([[self browseIdentifier] isEqualToString:@"FEwhat_to_watch"]) {
            self.view.hidden = YES;
            self.view.alpha = 0.0;
            self.view.userInteractionEnabled = NO;
        }
    }
}
%end

// 4. KEYWORD BLOCKING (Texture/ASDisplayNode Fix)
%hook YTVideoWithContextNode
- (void)setAccessibilityLabel:(NSString *)label {
    %orig;
    if (isBlockedContent(label)) {
        self.hidden = YES;
        self.alpha = 0.0;
        // This is the secret command to crush a Texture Flexbox
        self.style.preferredSize = CGSizeMake(0, 0); 
    } else {
        self.hidden = NO;
        self.alpha = 1.0;
    }
}
%end

// 5. HARDCODED uYou SETTINGS (Permanently Enabled)

// A. "Hide all videos under player" & "Hide suggested video"
// This completely kills YTCompactVideoNode so NO small related videos ever render.
%hook YTCompactVideoNode
- (void)didLoad {
    %orig;
    self.hidden = YES;
    self.alpha = 0.0;
    self.style.preferredSize = CGSizeMake(0, 0);
}
- (void)setAccessibilityLabel:(NSString *)label {
    %orig;
    self.hidden = YES;
    self.style.preferredSize = CGSizeMake(0, 0);
}
%end

// B. "YT no hoverCards"
// Kills the annoying channel popups at the end of videos
%hook YTCreatorEndscreenNode
- (void)didLoad {
    %orig;
    self.hidden = YES;
    self.style.preferredSize = CGSizeMake(0, 0);
}
%end

// C. "Hide suggested videos in fullscreen"
// Kills the grid of videos that blocks the screen when a video ends
%hook YTFullscreenEngagementOverlayView
- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.alpha = 0.0;
    self.frame = CGRectZero;
}
%end
