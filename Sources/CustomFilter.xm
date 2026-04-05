#import <Foundation/Foundation.h>

// ==========================================
// 1. INTERFACES (For the Channel/Keyword Blocker)
// ==========================================

@interface YTIElementRenderer : NSObject
- (NSData *)elementData;
@end

@interface YTInnerTubeCellController : NSObject
- (void)setEntry:(id)entry;
@end

@interface YTVideoElementCellController : NSObject
- (id)initWithEntry:(id)entry parentResponder:(id)parentResponder creationDate:(id)creationDate;
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
// 3. THE RAW DATA ASSASSINS (Keyword/Channel Blocking)
// ==========================================

%hook YTIElementRenderer
- (NSData *)elementData {
    NSString *description = [self description];
    if (description != nil) {
        if (isBlockedContent(description)) {
            return nil; 
        }
    }
    return %orig;
}
%end

%hook YTInnerTubeCellController
- (void)setEntry:(id)entry {
    if (entry) {
        NSString *entryData = [entry description];
        if (isBlockedContent(entryData)) {
            %orig(nil); 
            return;
        }
    }
    %orig;
}
%end

%hook YTVideoElementCellController
- (id)initWithEntry:(id)entry parentResponder:(id)parentResponder creationDate:(id)creationDate {
    if (entry) {
        NSString *entryData = [entry description];
        if (isBlockedContent(entryData)) {
            return nil; 
        }
    }
    return %orig(entry, parentResponder, creationDate);
}
%end


// ==========================================
// 4. THE SETTINGS HACKER (Permanently force uYou features)
// ==========================================

%hook NSUserDefaults

// This intercepts every time the app checks a true/false setting
- (BOOL)boolForKey:(NSString *)defaultName {
    
    // We check if the app is asking about the 4 specific toggles you want on.
    // Using containsString protects us just in case they added "_enabled" to the end of their keys.
    if ([defaultName containsString:@"hideRelatedWatchNexts"] || // a) Hide all videos under player
        [defaultName containsString:@"hideVideosInFullscreen"] || // b) Hide suggested videos in fullscreen
        [defaultName containsString:@"hideSuggestedVideo"] || // c) Hide suggested video
        [defaultName containsString:@"hideHoverCards"] || // d) YT no hoverCards (uYou's setting)
        [defaultName containsString:@"endScreenCards"]) { // d) YT no hoverCards (YTLite's setting backup)
        
        // Force the app to believe the toggle is turned ON
        return YES;
    }
    
    // For every other setting (like Dark Mode, Autoplay, etc.), behave normally
    return %orig;
}

%end
