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
		if ([scheme isEqualToString: @"spmTestFunction"]) {
			NSLog(@"skipping spm handler for %@", url);
		} else if ([scheme isEqualToString: @"spmTestClass"]) {
			[self updateTestClassHandler: spmHandler];
		} else if ([scheme isEqualToString: @"file"]) {
			[self updateRootHandler: spmHandler];
		} else {
			NSLog(@"skipping spm handler for %@", url);
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
	[fileUrls addObject: [NSURL URLWithString: @"separator://separator"]];
	 
	// [{"className":"testTests","tests":[{"fileOffset":104,"filePath":"\/Users\/rjbowli\/Development\/textmate\/test\/Tests\/testTests\/testTests.swift","functionName":"testExample()"}]}]
	if (_tests != NULL) {
		 for (SPMTest * test in _tests) {
			  NSURLComponents *components = [[NSURLComponents alloc] init];
			  components.scheme = @"spmTestClass";
			  components.path = @"/";
			  components.queryItems = @[
					[NSURLQueryItem queryItemWithName:@"spmPath" value:_projectPath],
					[NSURLQueryItem queryItemWithName:@"targetName" value:test.targetName],
					[NSURLQueryItem queryItemWithName:@"className" value:test.className]
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
 			for (SPMTest * testClass in _tests) {
 				if ([urlClassName isEqualToString: testClass.className]) {
 					NSLog(@"%@", testClass);
 					NSURLComponents *components = [[NSURLComponents alloc] init];
 					components.scheme = @"spmTestFunction";
 					components.path = @"/";
 					components.queryItems = @[
 							[NSURLQueryItem queryItemWithName:@"spmPath" value:_projectPath],
 							[NSURLQueryItem queryItemWithName:@"targetName" value:testClass.targetName],
 							[NSURLQueryItem queryItemWithName:@"className" value:testClass.className],
 							[NSURLQueryItem queryItemWithName:@"functionName" value:testClass.functionName]
 					];
							
 					NSURL * itemURL = components.URL;
 					if (itemURL != NULL) {
 							[fileUrls addObject: itemURL];
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
			id testInfoArray = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:NULL];
			_tests = [NSMutableArray array];
			for (NSDictionary * testInfo in testInfoArray) {
				[_tests addObject:[[SPMTest alloc] initWithDictionary:testInfo]];
			}
			[self updateHandlers];
		});
	});
}

- (void) runAllTests {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString * spmatePath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"spmate"];
		std::string res = io::exec([spmatePath UTF8String], "test", "run", [_projectPath UTF8String], NULL);
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString * json = [NSString stringWithCxxString:res];
			[self handleTestResults: json];
		});
	});
}


- (void) runTests:(NSArray*) filters {
	if ([filters count] == 0) {
		return [self runAllTests];
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString * spmatePath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"spmate"];
		std::string res = io::exec([spmatePath UTF8String], "test", "run", [_projectPath UTF8String], "--filter", [filters componentsJoinedByString:@","], NULL);
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString * json = [NSString stringWithCxxString:res];
			[self handleTestResults: json];
		});
	});
}

- (void) handleTestResults: (NSString *) json {
	NSArray * results = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:NULL];
	// {"className":"ExampleTestsA","functionName":"testExample0","result":"passed","targetName":"testTests"}
	for (NSDictionary * result in results) {
		// For all test classes
		for (SPMTest * testClass in _tests) {
			if ([result[@"className"] isEqualToString: testClass.className] &&
				[result[@"functionName"] isEqualToString: testClass.functionName]) {
					 
			 	[testClass willChangeValueForKey:@"runIcon"];
			 	testClass.result = result[@"result"];
			 	[testClass didChangeValueForKey:@"runIcon"];
					 
				NSLog(@"update test: %@ for %@", result[@"result"], testClass.functionName);
			 }
		}
	}
	//NSLog(@"%@", json);
}

@end
