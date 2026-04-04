#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>

// ============================================
// 1. INTERFACE DECLARATIONS (Texture / YouTube)
// ============================================
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

@interface YTBrowseViewController : UIViewController
- (NSString *)browseIdentifier;
@end

// New classes for better compatibility
@interface YTMainAppVideoPlayerOverlayViewController : UIViewController
- (BOOL)shouldShowHovercard;
@end

@interface YTPlayerView : UIView
@end

@interface YTPlayerViewController : UIViewController
@property (nonatomic, retain) YTPlayerView *playerView;
@end

@interface YTEndscreenHovercardView : UIView
@end

@interface YTRelatedVideosView : UIView
@end

@interface YTISearchSuggestionsSectionController : NSObject
- (NSArray *)suggestions;
@end

// ============================================
// 2. FILTERING ENGINE (Channels, Titles, Videos)
// ============================================
static BOOL isBlockedContent(NSString *text) {
    if (!text || text.length == 0) return NO;
    NSString *lowercaseText = [text lowercaseString];
    
    // --- BLOCKED CHANNELS (from your list) ---
    NSArray *blockedChannels = @[
        @"mrbeast", @"career247", @"studyiq ias", @"neon man", @"purav jha",
        @"neon man sports", @"lakshay chaudhary", @"abhi and niyu", @"t-series",
        @"neuzboy", @"ashish chanchlani vines", @"tanmay bhat", @"hindi rush",
        @"india's got latent clips", @"samay raina", @"carryminati", @"ishowspeed",
        @"varun mayya", @"aevy tv", @"finance with sharan", @"breakdown",
        @"ryan george extra plus!", @"ryan george", @"mohak mangal", @"cinedesi",
        @"rapid info", @"techlinked", @"linus tech tips", @"shortcircuit",
        @"memapur", @"memapur 2.0", @"sourav joshi vlogs", @"risen ai",
        @"mr. indian hacker", @"thugesh", @"thugesh unfiltered", @"open letter",
        @"dhruv rathee", @"suotes aesthetics", @"techwiser", @"sillycorns",
        @"think school", @"mr techpedia", @"nitish rajput", @"gyan therapy",
        @"aye jude", @"prasadtechintelugu", @"beebom", @"trakin tech",
        @"the deshbhakt", @"mrwhosetheboss", @"hamza", @"thegoodvibe",
        @"andromeda - topic", @"mxzi", @"zombr3x", @"sma$her", @"flame runner - topic",
        @"jmilton - topic", @"repsaj - topic", @"mgd - topic", @"khaos - topic",
        @"cape - topic", @"torbahed - topic", @"ogryzek - topic", @"trxshbxy - topic",
        @"ncts - topic", @"fennexx - topic", @"sayfalse - topic", @"h6itam - topic",
        @"eternxlkz", @"dj fku - topic", @"dj asul - topic", @"kendrick lamar",
        @"sabrina carpenter", @"camila cabello", @"shawn mendes", @"one direction",
        @"wham!", @"sia", @"stephen sanchez", @"publictheband", @"powfu",
        @"passenger", @"charlie puth", @"onedirectionvevo", @"wiz khalifa music",
        @"publicvevo", @"alan walker", @"stephensanchezvevo", @"onerepublicvevo",
        @"green planet lyrics", @"coldplay", @"netflix india", @"dog story",
        @"zaynvevo", @"neon lyrics", @"glassanimalsvevo", @"aviciiofficialvevo",
        @"billieeilishvevo", @"thescriptvevo", @"selina lyrics", @"lanadelreyvevo",
        @"khalidvevo", @"justinbiebervevo", @"bluenight audio", @"pop mage",
        @"ragnbonemanvevo", @"jonas blue", @"5sos", @"panic! at the disco",
        @"the score", @"republic records", @"riot games music", @"2wei", @"suka.",
        @"phant x", @"alpha phonk", @"unstoppable music", @"demon", @"mafia",
        @"mtheo 785 (1)", @"youssey music", @"mrl", @"ashreveal", @"ro ransom - topic",
        @"trillyrap", @"7clouds", @"urban paradise", @"pizza music", @"vibe music",
        @"syrebralvibes", @"dan music", @"solitude songs", @"mikomikei",
        @"alone candy music", @"7clouds rock", @"latinhype", @"arcade music",
        @"billion stars", @"tried&refused productions.", @"lynling lyrics",
        @"pop artist", @"lost panda", @"ignite", @"unique sound", @"music and song 3",
        @"7clouds chill", @"cakes & eclairs", @"escape lyrics", @"musical muse",
        @"theweekndvevo", @"high vibes", @"the vibe guide", @"latinnow",
        @"popular music", @"the weeknd", @"light raider", @"mocha amv", @"tiff.",
        @"unclonable", @"sabrinacarpentervevo", @"ganda dhanda", @"dj fku",
        @"rxposo99 - topic", @"rival", @"chainsmokersvevo", @"the chainsmokers - topic",
        @"axwell ^ ingrosso - topic", @"major lazer official", @"gen-z way",
        @"k-391", @"egzod", @"the chainsmokers", @"kurzgesagt – in a nutshell",
        @"reallifelore"
    ];
    
    // --- BLOCKED TITLE KEYWORDS ---
    NSArray *blockedTitles = @[
        @"phonk", @"funk", @"slowed", @"music", @"sempero", @"teconci"
    ];
    
    // --- BLOCKED VIDEO URLs (video IDs) ---
    NSArray *blockedVideoIDs = @[
        @"O0CuYUQHoaU", @"fH_Lw-Xq_6Y", @"SPr9OSDWBRA", @"CdnaNh1_jks",
        @"Sfv6OmOB1W4", @"FzVmdT_GkYs", @"-GUcNi1Jmhw"
    ];
    
    // Check channels
    for (NSString *channel in blockedChannels) {
        if ([lowercaseText containsString:channel]) {
            return YES;
        }
    }
    // Check titles
    for (NSString *keyword in blockedTitles) {
        if ([lowercaseText containsString:keyword]) {
            return YES;
        }
    }
    // Check video IDs (if text looks like a URL or contains the ID)
    for (NSString *videoID in blockedVideoIDs) {
        if ([lowercaseText containsString:[videoID lowercaseString]]) {
            return YES;
        }
    }
    return NO;
}

// ============================================
// 3. FORCE UYOUENHANCED SETTINGS ON EVERY LAUNCH
// ============================================
%ctor {
    @autoreleasepool {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // Permanently enable the required uYouEnhanced features
        [defaults setBool:YES forKey:@"hide_related_videos"];      // Hide all videos under player
        [defaults setBool:YES forKey:@"hide_suggested_video"];     // Hide suggested video
        [defaults setBool:NO forKey:@"hover_cards_enabled"];       // YT no hoverCards
        [defaults setBool:YES forKey:@"hide_fullscreen_suggestions"]; // Hide suggested in fullscreen (workaround below)
        [defaults synchronize];
        NSLog(@"CustomFocus: uYouEnhanced preferences forced.");
    }
}

// ============================================
// 4. HIDE HOME FEED (Confirmed Working)
// ============================================
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

// ============================================
// 5. BLOCKING CHANNELS / TITLES / VIDEOS
//    (Hooks the nodes that appear in feed and search)
// ============================================
%hook YTVideoWithContextNode
- (void)setAccessibilityLabel:(NSString *)label {
    %orig;
    if (isBlockedContent(label)) {
        self.hidden = YES;
        self.alpha = 0.0;
        self.style.preferredSize = CGSizeMake(0, 0);
    } else {
        self.hidden = NO;
        self.alpha = 1.0;
    }
}
%end

// Also block compact video nodes (used in related/suggested sections)
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

// ============================================
// 6. HIDE "ALL VIDEOS UNDER PLAYER" & "SUGGESTED VIDEOS"
//    (Using YTRelatedVideosView which is the container)
// ============================================
%hook YTRelatedVideosView
- (void)didMoveToSuperview {
    %orig;
    self.hidden = YES;
    self.alpha = 0.0;
    self.userInteractionEnabled = NO;
}
%end

// ============================================
// 7. HIDE SUGGESTED VIDEOS IN FULLSCREEN (Workaround for uYouEnhanced bug #373)
// ============================================
%hook YTEndscreenHovercardView
- (void)didMoveToWindow {
    %orig;
    self.hidden = YES;
    self.alpha = 0.0;
    [self removeFromSuperview];
}
%end

// ============================================
// 8. DISABLE HOVER CARDS (YT no hoverCards)
// ============================================
%hook YTMainAppVideoPlayerOverlayViewController
- (BOOL)shouldShowHovercard {
    return NO;
}
%end

// ============================================
// 9. EXTRA: BLOCK VIDEOS FROM SEARCH RESULTS (if needed)
// ============================================
%hook YTISearchSuggestionsSectionController
- (NSArray *)suggestions {
    NSArray *original = %orig;
    NSMutableArray *filtered = [NSMutableArray array];
    for (id suggestion in original) {
        NSString *title = [suggestion valueForKey:@"title"];
        NSString *channel = [suggestion valueForKey:@"channelName"];
        NSString *videoId = [suggestion valueForKey:@"videoId"];
        if (!isBlockedContent(title) && !isBlockedContent(channel) && !isBlockedContent(videoId)) {
            [filtered addObject:suggestion];
        }
    }
    return filtered;
}
%end
