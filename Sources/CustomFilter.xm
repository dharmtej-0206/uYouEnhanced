#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// ==========================================
// 1. INTERFACES
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
// 3. THE RAW DATA ASSASSINS 
// ==========================================

// 1. The ELM Network Payload Interceptor (Live Streams, Shorts, Ads)
%hook YTIElementRenderer
- (NSData *)elementData {
    NSString *description = [self description];
    
    if (description != nil) {
        if (isBlockedContent(description)) {
            return nil; // Deletes the data before the UI knows it exists
        }
    }
    
    return %orig;
}
%end

// 2. The Standard Controller Interceptor (Recycled Cells & Standard Search)
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

// 3. The Controller Initialization Interceptor (First load standard videos)
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
