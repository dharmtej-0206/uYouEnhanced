#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// ==========================================
// 1. INTERFACES (Texture, ELM, and YouTube)
// ==========================================

@interface ASLayoutElementStyle : NSObject
@property (nonatomic, assign) CGSize preferredSize;
@end

@interface ASDisplayNode : NSObject
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) ASLayoutElementStyle *style;
@property (nonatomic, weak) ASDisplayNode *supernode; 
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

@interface ELMElement : NSObject
@end

@interface ELMCellNode : ASDisplayNode
- (void)setElement:(ELMElement *)element;
@end

@interface YTVideoElementCellController : NSObject
- (id)initWithEntry:(id)entry parentResponder:(id)parentResponder creationDate:(id)creationDate;
@end

@interface YTInnerTubeCellController : NSObject
- (void)setEntry:(id)entry;
@end

@interface YTVideoWithContextNode : ASDisplayNode
- (void)setVideo:(id)video; 
@end


// ==========================================
// 2. THE FILTERING ENGINE
// ==========================================

static BOOL isBlockedContent(NSString *text) {
    if (!text) return NO;
    NSString *lowercaseText = [text lowercaseString];
    
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


// ==========================================
// 3. THE DATA MODEL ASSASSINS 
// (Intercepts data when cells are first built or recycled)
// ==========================================

// Hook 1: Blocks NEW standard video cells
%hook YTVideoElementCellController
- (id)initWithEntry:(id)entry parentResponder:(id)parentResponder creationDate:(id)creationDate {
    if (entry) {
        NSString *entryData = [entry description];
        if (isBlockedContent(entryData)) {
            return nil; // Prevents the cell from being created
        }
    }
    return %orig(entry, parentResponder, creationDate);
}
%end

// Hook 2: Blocks RECYCLED video cells (Crucial for search results & scrolling)
%hook YTInnerTubeCellController
- (void)setEntry:(id)entry {
    if (entry) {
        NSString *entryData = [entry description];
        if (isBlockedContent(entryData)) {
            %orig(nil); // Feed it nil so it renders blank
            return;
        }
    }
    %orig;
}
%end

// Hook 3: Blocks NEW Elements cells (Live Streams, Shorts, Promos)
%hook ELMCellNode
- (void)setElement:(ELMElement *)element {
    if (element) {
        NSString *elementData = [element description];
        if (isBlockedContent(elementData)) {
            self.hidden = YES;
            self.style.preferredSize = CGSizeMake(0, 0);
            return; // Starve the cell of data
        }
    }
    %orig;
}
%end

// Hook 4: Blocks RECYCLED standard video nodes in search UI
%hook YTVideoWithContextNode
- (void)setVideo:(id)video {
    if (video) {
        NSString *videoData = [video description];
        if (isBlockedContent(videoData)) {
            self.hidden = YES;
            self.style.preferredSize = CGSizeMake(0, 0);
            return; 
        }
    }
    %orig;
}
%end


// ==========================================
// 4. THE TEXTURE FALLBACK (Secondary Defense)
// ==========================================

%hook ASTextNode
- (void)setAttributedText:(NSAttributedString *)attributedText {
    %orig; 
    if (!attributedText) return;
    
    if (isBlockedContent(attributedText.string)) {
        ASDisplayNode *parentNode = self.supernode;
        while (parentNode != nil) {
            NSString *className = NSStringFromClass([parentNode class]);
            if ([className containsString:@"CellNode"] || 
                [className containsString:@"VideoNode"]) {
                
                parentNode.hidden = YES;
                parentNode.style.preferredSize = CGSizeMake(0, 0);
                
                if ([parentNode respondsToSelector:@selector(setFrame:)]) {
                    parentNode.frame = CGRectZero;
                }
                break; 
            }
            parentNode = parentNode.supernode;
        }
    }
}
%end


// ==========================================
// 5. HARDCODED UI CLEANUP
// ==========================================

// Nuke the Home Feed entirely
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

// Kill Legacy Related Videos & Popups
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
