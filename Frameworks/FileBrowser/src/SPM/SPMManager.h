#import "SPMObserver.h"
#import <scm/status.h>

NSImage * spmTestsPassImage;
NSImage * spmTestsFailImage;
NSImage * spmTestsUnknownImage;

@interface NSURL (QueryLookup)
- (id)queryForKey:(id)aKey;
- (NSURL *)urlForKey:(id)aKey;
@end

@interface SPMManager : NSObject
@property (class, readonly) SPMManager* sharedInstance;

- (SPMObserver*)observerAtURL:(NSURL*)url
						 usingBlock:(HandlerBlock) handler;

- (SPMObserver*)existingObserverAtURL:(NSURL*)url;
- (SPMTestClass*)existingTestClassAtURL:(NSURL*)url;
- (SPMTest*)existingTestAtURL:(NSURL*)url;
- (NSArray*)existingTestsAtURL:(NSURL*)url;

@end
