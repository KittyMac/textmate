#ifndef __SPM_OBSERVER__
#define __SPM_OBSERVER__

#import "SPMTest.h"

typedef void(^HandlerBlock)(NSArray<NSURL*>*); 

@interface SPMHandler : NSObject
@property (nonatomic) NSURL* url;
@property (nonatomic) HandlerBlock handler;
@end

@interface SPMObserver : NSObject
@property (nonatomic) NSString* projectPath;
@property (nonatomic) NSMutableArray* tests;

@property (nonatomic) NSMutableArray* handlers;
// 
// - (id)addObserverToFileAtURL:(NSURL*)url usingBlock:(void(^)(scm::status::type))handler;
// - (id)addObserverToRepositoryAtURL:(NSURL*)url usingBlock:(void(^)(SCMRepository*))handler;
// - (void)removeObserver:(id)someObserver;
// 
// - (SCMRepository*)repositoryAtURL:(NSURL*)url;

- (instancetype) initWithURL:(NSURL*)url;
- (void) addHandler:(HandlerBlock) handler forURL:(NSURL *) url;
- (void) removeHandler:(HandlerBlock) handler;

- (void) refreshAll;
- (void) refreshTests;

- (void) runAllTests;
- (void) runTests:(NSArray*) filters;

@end

#endif