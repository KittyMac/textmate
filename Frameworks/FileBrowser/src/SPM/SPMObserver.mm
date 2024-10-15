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
		  _tests = [[NSMutableArray alloc] init];
		  _testClasses = [[NSMutableArray alloc] init];
		  [self refreshAll];
	 }
	 return self;
}

- (void) addHandler:(HandlerBlock) handler
				 forURL: (NSURL*) url {
	 SPMHandler * spmHandler = [[SPMHandler alloc] initWithURL: url usingBlock: handler];
	 if ([_handlers count] > 2) {
		 [_handlers removeObjectAtIndex: 0];
	 }
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

- (void) updateHandler:(SPMHandler *)spmHandler {
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

- (void) updateHandlers {
	for (SPMHandler * spmHandler in [NSArray arrayWithArray: _handlers]) {
		[self updateHandler: spmHandler];
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
	 
	 for (SPMTestClass * testClass in _testClasses) {
		  NSURLComponents *components = [[NSURLComponents alloc] init];
		  components.scheme = @"spmTestClass";
		  components.path = @"/";
		  components.queryItems = @[
				[NSURLQueryItem queryItemWithName:@"spmPath" value:_projectPath],
				[NSURLQueryItem queryItemWithName:@"targetName" value:testClass.targetName],
				[NSURLQueryItem queryItemWithName:@"className" value:testClass.className]
		  ];
		  NSURL * itemURL = components.URL;
		  if (itemURL != NULL) {
				[fileUrls addObject: itemURL];
		  }
	 }
	  
	  spmHandler.handler(fileUrls);
}

- (void) updateTestClassHandler: (SPMHandler*) spmHandler {
	NSMutableArray * fileUrls = [NSMutableArray array];
	NSString * urlTargetName = [spmHandler.url queryForKey: @"targetName"];
	NSString * urlClassName = [spmHandler.url queryForKey: @"className"];

	for (SPMTest * testClass in _tests) {
		if ([urlTargetName isEqualToString: testClass.targetName] &&
			[urlClassName isEqualToString: testClass.className]) {
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
			
			// TODO: only update existing items if we can
			NSArray * existingTests = _tests;
			_tests = [NSMutableArray array];
			for (NSDictionary * testInfo in testInfoArray) {
				BOOL didUpdate = false;
				for (SPMTest * existingTest in existingTests) {
					if ([existingTest.targetName isEqualToString: testInfo[@"targetName"]] &&
						[existingTest.className isEqualToString: testInfo[@"className"]] &&
						[existingTest.functionName isEqualToString: testInfo[@"functionName"]]) {
						[existingTest updateWithDictionary: testInfo];
						[_tests addObject: existingTest];
						didUpdate = true;
					}
				}
				if (didUpdate == false) {
					[_tests addObject:[[SPMTest alloc] initWithDictionary:testInfo]];
				}
			}
			
			// test classes (testClasses)
			NSArray * existingTestClasses = _testClasses;
			_testClasses = [NSMutableArray array];
			for (NSDictionary * testInfo in testInfoArray) {
				BOOL didExist = false;
				for (SPMTest * existingTestClass in _testClasses) {
					if ([existingTestClass.targetName isEqualToString: testInfo[@"targetName"]] &&
						[existingTestClass.className isEqualToString: testInfo[@"className"]]) {
						didExist = true;
					}
				}
				if (didExist) {
					continue;
				}
				
				BOOL didUpdate = false;
				for (SPMTest * existingTestClass in existingTestClasses) {
					if ([existingTestClass.targetName isEqualToString: testInfo[@"targetName"]] &&
						[existingTestClass.className isEqualToString: testInfo[@"className"]]) {
						[existingTestClass updateWithDictionary: testInfo];
						[_testClasses addObject: existingTestClass];
						NSLog(@"updating test class: %@", testInfo);
						didUpdate = true;
					}
				}
				if (didUpdate == false) {
					NSLog(@"adding test class: %@", testInfo);
					[_testClasses addObject:[[SPMTestClass alloc] initWithDictionary:testInfo]];
				}
			}
			
			[_tests sortUsingComparator: ^NSComparisonResult(SPMTest* obj1, SPMTest* obj2) {
				return [[obj1 className] compare:[obj2 className]];
			}];
			
			[_testClasses sortUsingComparator: ^NSComparisonResult(SPMTestClass* obj1, SPMTestClass* obj2) {
				return [[obj1 className] compare:[obj2 className]];
			}];
						
			NSLog(@"_tests.count: %lu", _tests.count);
			NSLog(@"_testClasses.count: %lu", _testClasses.count);
			
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
	
	NSLog(@"%@", json);
	
	for (NSDictionary * result in results) {
		// For all test classes
		for (SPMTest * test in _tests) {
			if (//[result[@"targetName"] isEqualToString: test.targetName] &&
				[result[@"className"] isEqualToString: test.className] &&
				[result[@"functionName"] isEqualToString: test.functionName]) {
					 
			 	[test willChangeValueForKey:@"runIcon"];
			 	test.result = result[@"result"];
			 	[test didChangeValueForKey:@"runIcon"];
					 
				NSLog(@"update test: %@ for %@", result[@"result"], test.functionName);
			 }
		}
	}
	
	for (SPMTestClass * testClass in _testClasses) {
		int numPass = 0;
		int numFail = 0;
		
		for (SPMTest * test in _tests) {
			if ([testClass.targetName isEqualToString: test.targetName] &&
				[testClass.className isEqualToString: test.className]) {
				if ([test.result isEqualToString: @"passed"]) {
					numPass += 1;
				} else if ([test.result isEqualToString: @"failed"]) {
					numFail += 1;
				}
			}
		}
		
		[testClass willChangeValueForKey:@"runIcon"];
		if (numFail > 0) {
		 	testClass.result = @"failed";
		} else if (numPass > 0) {
		 	testClass.result = @"passed";
		} else {
			testClass.result = NULL;
		}
		[testClass didChangeValueForKey:@"runIcon"];
		
		NSLog(@"update test class: %@ for %@", testClass.result, testClass.className);
	}
	//NSLog(@"%@", json);
}

@end
