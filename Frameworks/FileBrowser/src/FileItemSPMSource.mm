#import "FileItem.h"
#import <OakAppKit/NSImage Additions.h>
#import <io/path.h>
#import <ns/ns.h>

// ================
// = SPM Observer =
// ================


@interface SPMObserver : NSObject
{
	id _spmObserver;
}
@end

@implementation SPMObserver
- (instancetype)initWithURL:(NSURL*)url usingBlock:(void(^)(NSArray<NSURL*>*))handler
{
	if(self = [super init])
	{
		NSLog(@"initWithURL: %@", url);
		NSURL* fileURL = [NSURL fileURLWithPath:url.path isDirectory:YES];
		
		// file path...
		NSMutableArray * fileUrls = [NSMutableArray array];
		
		for(NSURL* otherURL in [NSFileManager.defaultManager contentsOfDirectoryAtURL:fileURL includingPropertiesForKeys:nil options:0 error:nil]) {
			[fileUrls addObject: otherURL];
		}
		[fileUrls addObject: [NSURL URLWithString: @"special://separator"]];
		handler(fileUrls);
		
	}
	return self;
}

@end


/*
// ===================
// = SPM Data Source =
// ===================

@interface SPMStatusFileItem : FileItem
{
	NSURL * _packageUrl;
}
@end

@implementation SPMStatusFileItem
+ (void)load
{
	[self registerClass:self forURLScheme:@"spm"];
}

+ (id)makeObserverForURL:(NSURL*)url usingBlock:(void(^)(NSArray<NSURL*>*))handler
{
	return [[SPMObserver alloc] initWithURL:url usingBlock:handler];
}

- (instancetype)initWithURL:(NSURL*)url
{
	if(self = [super initWithURL:url])
	{
		_packageUrl = url;
		// self.disambiguationSuffix = @" (test)";
	}
	return self;
}

- (void)dealloc
{
	// [SCMManager.sharedInstance removeObserver:_observer];
}

- (NSString*)localizedName
{
	if([self.URL.query hasSuffix:@"source"]) {
		return @"Source";
	} else if([self.URL.query hasSuffix:@"tests"]) {
		return @"Tests";
	}
	
	// TODO: get the name out of the package.swift
	
	return [NSFileManager.defaultManager displayNameAtPath:_packageUrl.path];
}

- (NSURL*)parentURL
{
	return [NSURL fileURLWithPath:self.URL.path];
}
@end

*/