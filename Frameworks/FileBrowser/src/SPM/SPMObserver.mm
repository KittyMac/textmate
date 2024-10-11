#import "SPMObserver.h"
#include <io/path.h>
#include <io/exec.h>
#import <OakFoundation/NSString Additions.h>
#import <OakAppKit/NSAlert Additions.h>

@implementation SPMObserver

- (instancetype) initWithURL:(NSURL*)url
                  usingBlock:(HandlerBlock) handler
{
    if(self = [super init]) {
        _projectPath = url.path;
		  _handlers = [[NSMutableArray alloc] init];
		  [_handlers addObject: handler];
        [self refreshAll];
    }
    return self;
}

- (void) addHandler:(HandlerBlock) handler {
  [_handlers addObject: handler];
}

- (void) removeHandler:(HandlerBlock) handler {
  [_handlers removeObject: handler];
}

- (void) updateHandler {
    NSURL* fileURL = [NSURL fileURLWithPath:_projectPath
                                isDirectory:YES];
    
    // file path...
    NSMutableArray * fileUrls = [NSMutableArray array];
    
    for(NSURL* otherURL in [NSFileManager.defaultManager contentsOfDirectoryAtURL:fileURL includingPropertiesForKeys:nil options:0 error:nil]) {
        [fileUrls addObject: otherURL];
    }
    [fileUrls addObject: [NSURL URLWithString: @"special://separator"]];
    
    // TODO: add tests
    // [{"className":"testTests","tests":[{"fileOffset":104,"filePath":"\/Users\/rjbowli\/Development\/textmate\/test\/Tests\/testTests\/testTests.swift","functionName":"testExample()"}]}]
    if (_tests != NULL) {
        for (NSDictionary * testClass in _tests) {
            NSString * className = testClass[@"className"];
            NSURLComponents *components = [[NSURLComponents alloc] init];
            components.scheme = @"special";
            components.host = @"testClass";
            components.path = @"/";
            components.queryItems = @[
                [NSURLQueryItem queryItemWithName:@"displayName" value:className]
            ];
            NSURL * itemURL = components.URL;
            if (itemURL != NULL) {
                [fileUrls addObject: itemURL];
            }
        }
     }
    
	  for (HandlerBlock handler in _handlers) {
	  		handler(fileUrls);
	  }
}

- (void) refreshAll {
    [self refreshTests];
     [self updateHandler];
}

- (void) refreshTests {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * spmatePath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"spmate"]; 
        std::string res = io::exec([spmatePath UTF8String], "test", "list", [_projectPath UTF8String], NULL);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * json = [NSString stringWithCxxString:res];
                NSLog(@"%@", json);
            _tests = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
                NSLog(@"%@", _tests);
            [self updateHandler];
        });
    });
    
}

@end
