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
        self.hidden = YES;
        
        // Crush the frame so it doesn't leave a massive blank hole in your feed
        CGRect frame = self.frame;
        frame.size.height = 0;
        self.frame = frame;
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
        
        CGRect frame = self.frame;
        frame.size.height = 0;
        self.frame = frame;
    }
}
%end
