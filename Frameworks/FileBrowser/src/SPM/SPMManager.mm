#import "SPMManager.h"
#import "SPMObserver.h"
#include <io/path.h>
#include <io/exec.h>
#import <OakFoundation/NSString Additions.h>
#import <OakAppKit/NSAlert Additions.h>

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
	while(url) {
		if(SPMObserver* observer = [_observers objectForKey:url]) {
			[observer addHandler: handler];
			return observer;
		}
		
		// Does this directory contain a Package.swift?
		for(NSURL* otherURL in [NSFileManager.defaultManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:0 error:nil]) {
			if ([otherURL.lastPathComponent isEqualToString: @"Package.swift"]) {
				SPMObserver * observer = [[SPMObserver alloc] initWithURL:url usingBlock:handler];
				[_observers setObject:observer forKey:url];
				return observer;
			}
		}
		
		NSURL* parentURL;
		if(![url getResourceValue:&parentURL forKey:NSURLParentDirectoryURLKey error:nil] || [url isEqual:parentURL]) {
			break;
		}

		url = parentURL;
	}
	return nil;
}

@end
