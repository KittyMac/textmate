#import "SPMManager.h"
#import "SPMObserver.h"
#include <io/path.h>
#include <io/exec.h>
#import <OakFoundation/NSString Additions.h>
#import <OakAppKit/NSAlert Additions.h>

@implementation NSURL (QueryLookup)
- (id)queryForKey:(id)aKey {
	NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
	for (NSURLQueryItem *item in components.queryItems) {
	    if ([item.name isEqualToString:aKey]) {
	        return item.value;
	    }
	}
	return nil;
}
@end


@interface SPMManager ()
@property (nonatomic, readonly) NSMapTable<NSURL*, SPMObserver*>* observers;
@end

@implementation SPMManager
+ (instancetype)sharedInstance
{
	static SPMManager* sharedInstance = [self new];
	return sharedInstance;
}

- (instancetype)init
{
	if(self = [super init])
	{
		_observers = [NSMapTable strongToWeakObjectsMapTable];
	}
	return self;
}

- (SPMObserver*)observerAtURL:(NSURL*)url
						 usingBlock:(HandlerBlock) handler
{
	NSURL * projectURL = url;
	
	NSLog(@"SPMManager check url: %@", url);
	
	// Is this a URL for a portion of an existing SPM project?
	NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
	for (NSURLQueryItem *item in components.queryItems) {
	    if ([item.name isEqualToString:@"spmPath"]) {
			 projectURL = [NSURL fileURLWithPath: item.value];
			 NSLog(@"SPMManager found spmPath: %@", projectURL);
	    }
	}
	
	if(SPMObserver* observer = [_observers objectForKey:projectURL]) {
		NSLog(@"SPMManager assigned hanlder for: %@", url);
		[observer addHandler: handler forURL: url];
		return observer;
	}
	
	// Does this directory contain a Package.swift?
	for(NSURL* otherURL in [NSFileManager.defaultManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:0 error:nil]) {
		if ([otherURL.lastPathComponent isEqualToString: @"Package.swift"]) {
			SPMObserver * observer = [[SPMObserver alloc] initWithURL:url];
			[observer addHandler: handler forURL: url];
			[_observers setObject:observer forKey:projectURL];
			return observer;
		}
	}
	
	return nil;
}

@end
