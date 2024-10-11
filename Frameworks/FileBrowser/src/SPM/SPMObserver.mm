#import "SPMObserver.h"
#import "SPMManager.h"
#include <io/path.h>
#include <io/exec.h>
#import <OakFoundation/NSString Additions.h>
#import <OakAppKit/NSAlert Additions.h>

@implementation SPMHandler
- (instancetype) initWithURL:(NSURL*)url
                        usingBlock:(HandlerBlock) handler
{
    if(self = [super init]) {
        _url = url;
        _handler = handler;
    }
    return self;
}
@end


@implementation SPMObserver

- (instancetype) initWithURL:(NSURL*)url
{
    if(self = [super init]) {
        _projectPath = url.path;
        _handlers = [[NSMutableArray alloc] init];
        [self refreshAll];
    }
    return self;
}

- (void) addHandler:(HandlerBlock) handler
             forURL: (NSURL*) url {
    SPMHandler * spmHandler = [[SPMHandler alloc] initWithURL: url usingBlock: handler];
    [_handlers addObject: spmHandler];
    [self updateHandlers];
}

- (void) removeHandler:(HandlerBlock) handler {
    for (SPMHandler * spmHandler in [NSArray arrayWithArray: _handlers]) {
        if (spmHandler.handler == handler) {
            [_handlers removeObject: spmHandler];
        }
    }
}

- (void) updateHandlers {
    for (SPMHandler * spmHandler in [NSArray arrayWithArray: _handlers]) {
        NSURL * url = [spmHandler url];
        NSString * scheme = [url scheme];
        NSString * host = [url host];
        if ([scheme isEqualToString: @"special"]) {
            if ([host isEqualToString: @"testClass"]) {
                [self updateTestClassHandler: spmHandler];
            } else {
            	NSLog(@"skipping spm handler for %@", url);
            }
        } else {
            [self updateRootHandler: spmHandler];
        }
   }
}

- (void) updateRootHandler: (SPMHandler*) spmHandler {
   NSURL* fileURL = [NSURL fileURLWithPath:_projectPath
                               isDirectory:YES];
   
   // file path...
   NSMutableArray * fileUrls = [NSMutableArray array];
   
   for(NSURL* otherURL in [NSFileManager.defaultManager contentsOfDirectoryAtURL:fileURL includingPropertiesForKeys:nil options:0 error:nil]) {
       [fileUrls addObject: otherURL];
   }
   [fileUrls addObject: [NSURL URLWithString: @"special://separator"]];
    
   // [{"className":"testTests","tests":[{"fileOffset":104,"filePath":"\/Users\/rjbowli\/Development\/textmate\/test\/Tests\/testTests\/testTests.swift","functionName":"testExample()"}]}]
   if (_tests != NULL) {
       for (NSDictionary * testClass in _tests) {
           NSString * className = testClass[@"className"];
           NSURLComponents *components = [[NSURLComponents alloc] init];
           components.scheme = @"special";
           components.host = @"testClass";
           components.path = @"/";
           components.queryItems = @[
               [NSURLQueryItem queryItemWithName:@"spmPath" value:_projectPath],
               [NSURLQueryItem queryItemWithName:@"hasChildren" value:@"true"],
               [NSURLQueryItem queryItemWithName:@"displayName" value:className],
               [NSURLQueryItem queryItemWithName:@"className" value:className]
           ];
           NSURL * itemURL = components.URL;
           if (itemURL != NULL) {
               [fileUrls addObject: itemURL];
           }
       }
    }
     
     spmHandler.handler(fileUrls);
}

- (void) updateTestClassHandler: (SPMHandler*) spmHandler {
    NSMutableArray * fileUrls = [NSMutableArray array];
    NSString * urlClassName = [spmHandler.url queryForKey: @"className"];

    if (_tests != NULL) {
        for (NSDictionary * testClass in _tests) {
         NSString * className = testClass[@"className"];
            if ([urlClassName isEqualToString: className]) {
                
                for (NSDictionary * test in testClass[@"tests"]) {
                    NSString * functionName = test[@"functionName"];
                    NSString * filePath = test[@"filePath"];
                    NSNumber * fileOffset = test[@"fileOffset"];
                    
                    NSURLComponents *components = [[NSURLComponents alloc] init];
                    components.scheme = @"special";
                    components.host = @"testFunction";
                    components.path = @"/";
                    components.queryItems = @[
                        [NSURLQueryItem queryItemWithName:@"spmPath" value:_projectPath],
                        [NSURLQueryItem queryItemWithName:@"hasChildren" value:@"false"],
                        [NSURLQueryItem queryItemWithName:@"displayName" value:functionName],
                        [NSURLQueryItem queryItemWithName:@"functionName" value:functionName],
                        [NSURLQueryItem queryItemWithName:@"filePath" value:filePath],
                        [NSURLQueryItem queryItemWithName:@"fileOffset" value:[fileOffset description]]
                    ];
                    NSURL * itemURL = components.URL;
                    if (itemURL != NULL) {
                        NSLog(@"%@", itemURL);
                        [fileUrls addObject: itemURL];
                    }
                }
            }
        }
    }
    
    spmHandler.handler(fileUrls);
}

- (void) refreshAll {
    [self refreshTests];
    [self updateHandlers];
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
            [self updateHandlers];
        });
    });
    
}

@end
