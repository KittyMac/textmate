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
- (NSURL *)urlForKey:(id)aKey {
	NSString * value = [self queryForKey: aKey];
	if (value) {
		return [NSURL fileURLWithPath: value];
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
	NSURL * projectURL = [url urlForKey:@"spmPath"] ?: url;	
	
	if (SPMObserver* observer = [_observers objectForKey:projectURL]) {
		NSLog(@"SPMManager assigned handler for: %@", url);
		[observer addHandler: handler forURL: url];
		return observer;
	}
	
	// Does this directory contain a Package.swift?
	for(NSURL* otherURL in [NSFileManager.defaultManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:0 error:nil]) {
		if ([otherURL.lastPathComponent isEqualToString: @"Package.swift"]) {
			NSLog(@"SPMManager created new observer for: %@", url);
			
			SPMObserver * observer = [[SPMObserver alloc] initWithURL:url];
			[observer addHandler: handler forURL: url];
			[_observers setObject:observer forKey:projectURL];
			return observer;
		}
	}
	
	NSLog(@"SPMManager failed to find project for: %@", url);	
	return nil;
}

- (SPMObserver*)existingObserverAtURL:(NSURL*)url
{
	NSURL * projectURL = [url urlForKey:@"spmPath"] ?: url;	
	return [_observers objectForKey:projectURL];
}

- (SPMTest*)existingTestAtURL:(NSURL*)url
{
	if (SPMObserver * observer = [self existingObserverAtURL: url]) {
		NSString * targetName = [url queryForKey:@"targetName"];
		NSString * className = [url queryForKey:@"className"];
		NSString * functionName = [url queryForKey:@"functionName"];
		for (SPMTest * test in observer.tests) {
			if ([test.targetName isEqualToString: targetName] &&
				[test.className isEqualToString: className] &&
				[test.functionName isEqualToString: functionName]) {
					return test;
			}
		}
	}

	return nil;
}

- (NSArray*)existingTestsAtURL:(NSURL*)url
{
	NSMutableArray * allTests = [NSMutableArray array];
	if (SPMObserver * observer = [self existingObserverAtURL: url]) {
		NSString * targetName = [url queryForKey:@"targetName"];
		NSString * className = [url queryForKey:@"className"];
		for (SPMTest * test in observer.tests) {
			if ([test.targetName isEqualToString: targetName] &&
				[test.className isEqualToString: className]) {
				[allTests addObject: test];
			}
		}
	}

	return allTests;
}

@end
