#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 1. INTERFACES
@interface _ASDisplayView : UIView
@end

@interface YTBrowseViewController : UIViewController
- (NSString *)browseIdentifier;
@end

@interface ASDisplayNode : NSObject
@property (nonatomic, assign) BOOL hidden;
@end

@interface YTCompactVideoNode : ASDisplayNode
@end

@interface YTCreatorEndscreenNode : ASDisplayNode
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
        @"career247", // (Added from your screenshot as an example!)
        @"specific channel name"
    ];
    
    for (NSString *keyword in blockedKeywords) {
        if ([lowercaseText containsString:keyword]) {
            return YES;
        }
    }
    return NO;
}

// 3. THE MASTER ASSASSIN (Tree-Climbing Keyword Blocker)
%hook _ASDisplayView
- (void)setAccessibilityLabel:(NSString *)label {
    %orig; // Let YouTube set the text
    
    if (isBlockedContent(label)) {
        // We caught a bad video! Climb the view hierarchy to find the master container.
        UIView *parent = self.superview;
        while (parent != nil) {
            // Once we hit the master cell, crush it
            if ([NSStringFromClass([parent class]) isEqualToString:@"_ASCollectionViewCell"]) {
                parent.hidden = YES;
                parent.alpha = 0.0;
                
                // Crush the physical space so the list collapses
                CGRect frame = parent.frame;
                frame.size.height = 0;
                parent.frame = frame;
                break;
            }
            parent = parent.superview;
        }
    }
}
%end

// 4. NUKE THE HOME FEED (Confirmed Working)
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

// 5. HARDCODED SETTINGS (Permanently kill legacy related videos & popups)
%hook YTCompactVideoNode
- (void)didLoad {
    %orig;
    self.hidden = YES;
}
%end

%hook YTCreatorEndscreenNode
- (void)didLoad {
    %orig;
    self.hidden = YES;
}
%end

%hook YTFullscreenEngagementOverlayView
- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.frame = CGRectZero;
}
%end
