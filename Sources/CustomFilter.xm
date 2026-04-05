#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 1. TEXTURE (ASYNCDISPLAYKIT) INTERFACES
@interface ASLayoutElementStyle : NSObject
@property (nonatomic, assign) CGSize preferredSize;
@end

@interface ASDisplayNode : NSObject
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) ASLayoutElementStyle *style;
@property (nonatomic, weak) ASDisplayNode *supernode; // Texture's internal family tree
@end

@interface ASTextNode : ASDisplayNode
@property (copy) NSAttributedString *attributedText;
@end

@interface YTBrowseViewController : UIViewController
- (NSString *)browseIdentifier;
@end

@interface YTCompactVideoNode : ASDisplayNode
@end
@interface YTCreatorEndscreenNode : ASDisplayNode
@end
@interface YTFullscreenEngagementOverlayView : UIView
@end

// 2. THE FILTERING ENGINE (Built from your JSON)
static BOOL isBlockedContent(NSString *text) {
    if (!text) return NO;
    NSString *lowercaseText = [text lowercaseString];
    
    // YOUR COMPLETE BLOCKTUBE EXPORT
    NSArray *blockedKeywords = @[
        // --- TITLES & KEYWORDS ---
        @"phonk", @"funk", @"slowed", @"music", @"sempero", @"teconci",
        
        // --- CHANNELS ---
        @"mrbeast", @"career247", @"studyiq ias", @"neon man", @"purav jha", 
        @"neon man sports", @"lakshay chaudhary", @"abhi and niyu", @"t-series", 
        @"neuzboy", @"ashish chanchlani vines", @"tanmay bhat", @"hindi rush", 
        @"india's got latent clips", @"samay raina", @"carryminati", @"ishowspeed", 
        @"varun mayya", @"aevy tv", @"finance with sharan", @"breakdown", 
        @"ryan george extra plus!", @"ryan george", @"mohak mangal", @"cinedesi", 
        @"rapid info", @"techlinked", @"linus tech tips", @"shortcircuit", 
        @"memapur", @"memapur 2.0", @"sourav joshi vlogs", @"risen ai", 
        @"mr. indian hacker", @"thugesh", @"thugesh unfiltered", @"open letter", 
        @"dhruv rathee", @"𝘀𝘂𝗼𝘁𝗲𝘀 𝗮𝗲𝘀𝘁𝗵𝗲𝘁𝗶𝗰𝘀", @"techwiser", @"sillycorns", 
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
        @"phant x", @"alpha phonk", @"unstoppable music", @"𝖉𝖊𝖒𝖔𝖓", @"mafia", 
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
        @"axwell λ ingrosso - topic", @"major lazer official", @"gen-z way", @"k-391", 
        @"egzod", @"the chainsmokers", @"kurzgesagt – in a nutshell", @"reallifelore"
    ];
    
    for (NSString *keyword in blockedKeywords) {
        if ([lowercaseText containsString:keyword]) {
            return YES;
        }
    }
    return NO;
}

// 3. THE TEXTURE ASSASSIN (Hooks the exact text-drawing engine)
%hook ASTextNode
- (void)setAttributedText:(NSAttributedString *)attributedText {
    %orig; // Let the engine set the text
    
    if (!attributedText) return;
    
    if (isBlockedContent(attributedText.string)) {
        // We caught a blocked keyword! 
        // Climb Texture's internal Node Tree (NOT the UIView tree)
        ASDisplayNode *parentNode = self.supernode;
        
        while (parentNode != nil) {
            NSString *className = NSStringFromClass([parentNode class]);
            
            // If the parent is ANY type of Master Video Card, crush it
            if ([className containsString:@"CellNode"] || 
                [className containsString:@"VideoNode"]) {
                
                // Hide it
                parentNode.hidden = YES;
                
                // Force Texture Flexbox engine to calculate this card as 0x0 pixels
                parentNode.style.preferredSize = CGSizeMake(0, 0);
                
                // Nuke the physical frame
                if ([parentNode respondsToSelector:@selector(setFrame:)]) {
                    parentNode.frame = CGRectZero;
                }
                
                break; // Stop climbing once we kill the master wrapper
            }
            parentNode = parentNode.supernode;
        }
    }
}
%end

// 4. NUKE THE HOME FEED
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

// 5. HARDCODED uYou SETTINGS (Permanently kill legacy related videos & popups)
%hook YTCompactVideoNode
- (void)didLoad {
    %orig;
    self.hidden = YES;
    self.style.preferredSize = CGSizeMake(0,0);
}
%end

%hook YTCreatorEndscreenNode
- (void)didLoad {
    %orig;
    self.hidden = YES;
    self.style.preferredSize = CGSizeMake(0,0);
}
%end

%hook YTFullscreenEngagementOverlayView
- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.frame = CGRectZero;
}
%end
