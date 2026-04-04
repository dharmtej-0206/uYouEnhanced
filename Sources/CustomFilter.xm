#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTVideoWithContextNode : UIView
@end

@interface YTCompactVideoNode : UIView
@end

@interface YTBrowseViewController : UIViewController
- (NSString *)browseIdentifier;
@end

// 1. The Filtering Engine (Now only needed for Search Results)
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

// 2. NUKE THE ENTIRE HOME FEED
%hook YTBrowseViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    // YouTube identifies the Home tab as "FEwhat_to_watch"
    if ([self respondsToSelector:@selector(browseIdentifier)]) {
        if ([[self browseIdentifier] isEqualToString:@"FEwhat_to_watch"]) {
            // Turn the Home Feed into a completely blank, dead screen
            self.view.hidden = YES;
            self.view.alpha = 0.0;
            self.view.userInteractionEnabled = NO;
        }
    }
}
%end

// 3. Hooking Search Results (YTVideoWithContextNode)
%hook YTVideoWithContextNode
- (void)setAccessibilityLabel:(NSString *)label {
    %orig;
    
    // If it's a blocked video in Search, nuke it
    if (isBlockedContent(label)) {
        self.hidden = YES;
        self.alpha = 0.0;
        self.userInteractionEnabled = NO;
        self.frame = CGRectZero; 
    } else {
        self.hidden = NO;
        self.alpha = 1.0;
        self.userInteractionEnabled = YES;
    }
}

- (void)layoutSubviews {
    %orig;
    if (isBlockedContent([self accessibilityLabel])) {
        self.hidden = YES;
        self.alpha = 0.0;
        self.frame = CGRectZero;
    }
}
%end

// 4. NUKE ALL RELATED VIDEOS (Unconditional Hiding)
%hook YTCompactVideoNode
- (void)setAccessibilityLabel:(NSString *)label {
    %orig;
    
    // Since you want NO related videos at all, we bypass the filter 
    // and instantly execute every single small video node.
    self.hidden = YES;
    self.alpha = 0.0;
    self.userInteractionEnabled = NO;
    self.frame = CGRectZero;
}

- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.alpha = 0.0;
    self.frame = CGRectZero;
}
%end
