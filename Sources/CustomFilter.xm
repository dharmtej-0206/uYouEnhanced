#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTVideoWithContextNode : UIView
@end

@interface YTCompactVideoNode : UIView
@end

// 1. The Filtering Engine
static BOOL isBlockedContent(NSString *text) {
    if (!text) return NO;
    NSString *lowercaseText = [text lowercaseString];
    
    // ADD YOUR BLOCKED KEYWORDS OR CHANNEL NAMES HERE
    // Keep everything lowercase!
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

// 2. Hooking the Home Feed Videos (YTVideoWithContextNode)
%hook YTVideoWithContextNode
- (void)layoutSubviews {
    %orig; // Let the original code run first
    
    NSString *accessibilityLabel = [self accessibilityLabel]; 
    
    if (isBlockedContent(accessibilityLabel)) {
        // Aggressive hiding for the Texture engine
        self.hidden = YES;
        self.alpha = 0.0;
        self.userInteractionEnabled = NO;
        
        // Crush the frame so it doesn't leave a massive blank hole
        CGRect frame = self.frame;
        frame.size.height = 0;
        self.frame = frame;
    } else {
        // CRITICAL: Restore the cell if iOS recycles it for a good video!
        self.hidden = NO;
        self.alpha = 1.0;
        self.userInteractionEnabled = YES;
    }
}
%end

// 3. Hooking the Search Results and "Up Next" sidebar (YTCompactVideoNode)
%hook YTCompactVideoNode
- (void)layoutSubviews {
    %orig;
    
    NSString *accessibilityLabel = [self accessibilityLabel]; 
    
    if (isBlockedContent(accessibilityLabel)) {
        self.hidden = YES;
        self.alpha = 0.0;
        self.userInteractionEnabled = NO;
        
        CGRect frame = self.frame;
        frame.size.height = 0;
        self.frame = frame;
    } else {
        // Restore recycled cells
        self.hidden = NO;
        self.alpha = 1.0;
        self.userInteractionEnabled = YES;
    }
}
%end
