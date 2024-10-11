#import "SPMObserver.h"
#import <scm/status.h>

@interface SPMManager : NSObject
@property (class, readonly) SPMManager* sharedInstance;

- (SPMObserver*)observerAtURL:(NSURL*)url
						 usingBlock:(HandlerBlock) handler;
@end
