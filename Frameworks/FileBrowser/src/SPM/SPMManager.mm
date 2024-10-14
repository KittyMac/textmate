#import "SPMManager.h"
#import "SPMObserver.h"
#include <io/path.h>
#include <io/exec.h>
#import <OakFoundation/NSString Additions.h>
#import <OakAppKit/NSAlert Additions.h>
#import <OakAppKit/NSImage Additions.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>


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
	
	if (spmTestsPassImage == NULL) {
		spmTestsPassImage = [NSImage imageNamed:@"TestsPassTemplate" inSameBundleAsClass:[OakRolloverButton class]];
		[spmTestsPassImage setTemplate: NO];
	}
	if (spmTestsFailImage == NULL) {
		spmTestsFailImage = [NSImage imageNamed:@"TestsFailTemplate" inSameBundleAsClass:[OakRolloverButton class]];
		[spmTestsFailImage setTemplate: NO];
	}
	if (spmTestsUnknownImage == NULL) {
		spmTestsUnknownImage = [NSImage imageNamed:@"TestsUnknownTemplate" inSameBundleAsClass:[OakRolloverButton class]];
		[spmTestsUnknownImage setTemplate: NO];
	}
	
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

- (SPMTestClass*)existingTestClassAtURL:(NSURL*)url
{
	if (SPMObserver * observer = [self existingObserverAtURL: url]) {
		NSString * targetName = [url queryForKey:@"targetName"];
		NSString * className = [url queryForKey:@"className"];
		for (SPMTestClass * testClass in observer.testClasses) {
			if ([testClass.targetName isEqualToString: targetName] &&
				[testClass.className isEqualToString: className]) {
				return testClass;
			}
		}
	}
	return nil;
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
