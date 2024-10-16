#import "SPMObserver.h"
#import "SPMManager.h"
#import "SPMTest.h"
#import "SPMTestClass.h"
#import "SPMTestTarget.h"
#include <io/path.h>
#include <io/exec.h>
#import <OakFoundation/NSString Additions.h>
#import <OakAppKit/NSAlert Additions.h>

#import <sys/sysctl.h>

int getPhysicalCoreCount() {
    int cores = 0;
    size_t len = sizeof(cores);
    sysctlbyname("hw.physicalcpu", &cores, &len, NULL, 0);
    return cores;
}

NSOperationQueue * spmateQueue = [[NSOperationQueue alloc] init];

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
		  _testTargets = [[NSMutableArray alloc] init];
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
		} else if ([scheme isEqualToString: @"spmTestTarget"]) {
			[self updateTestTargetHandler: spmHandler];
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
	 
	 for (SPMTestTarget * testTarget in _testTargets) {
		  NSURLComponents *components = [[NSURLComponents alloc] init];
		  components.scheme = @"spmTestTarget";
		  components.path = @"/";
		  components.queryItems = @[
				[NSURLQueryItem queryItemWithName:@"spmPath" value:_projectPath],
				[NSURLQueryItem queryItemWithName:@"targetName" value:testTarget.targetName]
		  ];
		  NSURL * itemURL = components.URL;
		  if (itemURL != NULL) {
				[fileUrls addObject: itemURL];
		  }
	 }
	  
	  spmHandler.handler(fileUrls);
}

- (void) updateTestTargetHandler: (SPMHandler*) spmHandler {
	NSMutableArray * fileUrls = [NSMutableArray array];
	NSString * urlTargetName = [spmHandler.url queryForKey: @"targetName"];

	for (SPMTestClass * testClass in _testClasses) {
		if ([urlTargetName isEqualToString: testClass.targetName]) {
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
	}
	 
	 spmHandler.handler(fileUrls);
}

- (void) updateTestClassHandler: (SPMHandler*) spmHandler {
	NSMutableArray * fileUrls = [NSMutableArray array];
	NSString * urlTargetName = [spmHandler.url queryForKey: @"targetName"];
	NSString * urlClassName = [spmHandler.url queryForKey: @"className"];

	for (SPMTest * test in _tests) {
		if ([urlTargetName isEqualToString: test.targetName] &&
			[urlClassName isEqualToString: test.className]) {
			NSURLComponents *components = [[NSURLComponents alloc] init];
			components.scheme = @"spmTestFunction";
			components.path = @"/";
			components.queryItems = @[
					[NSURLQueryItem queryItemWithName:@"spmPath" value:_projectPath],
					[NSURLQueryItem queryItemWithName:@"targetName" value:test.targetName],
					[NSURLQueryItem queryItemWithName:@"className" value:test.className],
					[NSURLQueryItem queryItemWithName:@"functionName" value:test.functionName]
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
			
			// only update existing items if we can
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
			
			// test targets (testTargets)
			NSArray * existingTestTargets = _testTargets;
			_testTargets = [NSMutableArray array];
			for (NSDictionary * testInfo in testInfoArray) {
				BOOL didExist = false;
				for (SPMTest * existingTestTarget in _testTargets) {
					if ([existingTestTarget.targetName isEqualToString: testInfo[@"targetName"]]) {
						didExist = true;
					}
				}
				if (didExist) {
					continue;
				}
				
				BOOL didUpdate = false;
				for (SPMTest * existingTestTarget in existingTestTargets) {
					if ([existingTestTarget.targetName isEqualToString: testInfo[@"targetName"]]) {
						[existingTestTarget updateWithDictionary: testInfo];
						[_testTargets addObject: existingTestTarget];
						NSLog(@"updating test class: %@", testInfo);
						didUpdate = true;
					}
				}
				if (didUpdate == false) {
					NSLog(@"adding test target: %@", testInfo);
					[_testTargets addObject:[[SPMTestTarget alloc] initWithDictionary:testInfo]];
				}
			}
			
			[_tests sortUsingComparator: ^NSComparisonResult(SPMTest* obj1, SPMTest* obj2) {
				return [[obj1 className] compare:[obj2 className]];
			}];
			
			[_testClasses sortUsingComparator: ^NSComparisonResult(SPMTestClass* obj1, SPMTestClass* obj2) {
				return [[obj1 className] compare:[obj2 className]];
			}];
			
			[_testTargets sortUsingComparator: ^NSComparisonResult(SPMTestTarget* obj1, SPMTestTarget* obj2) {
				return [[obj1 className] compare:[obj2 className]];
			}];
			
			NSLog(@"_tests.count: %lu", _tests.count);
			NSLog(@"_testClasses.count: %lu", _testClasses.count);
			NSLog(@"_testTargets.count: %lu", _testTargets.count);
			
			[self updateHandlers];
		});
	});
}

- (void) runTargetTests:(SPMTestTarget *)testTarget {
	for(SPMTestClass * test in _testClasses) {
		if ([test.targetName isEqualToString: testTarget.targetName]) {
			[self runTests: @[test] withTestTarget: testTarget];
		}
	}
}

- (void) runTests:(NSArray*) tests {
	[self runTests: tests withTestTarget: NULL];
}

- (void) runTests:(NSArray*) tests
	withTestTarget:(SPMTestTarget *)testTarget {
	NSMutableArray * filters = [NSMutableArray array];
	
	for (SPMTest * test in tests) {
		[filters addObject: test.filter];
	}
	
	NSMutableArray * runningTests = [NSMutableArray array];
	
	if (testTarget != NULL) {
		[testTarget beginTest];
		[runningTests addObject: testTarget];
	}
	
	for (id maybeTest in tests) {
		if ([maybeTest isKindOfClass: [SPMTest class]]) {
			[maybeTest beginTest];
			[runningTests addObject: maybeTest];
		}
		if ([maybeTest isKindOfClass: [SPMTestClass class]]) {
			NSString * targetName = [(SPMTestClass *)maybeTest targetName];
			NSString * className = [(SPMTestClass *)maybeTest className];
			[maybeTest beginTest];
			[runningTests addObject: maybeTest];
			
			for(SPMTest * test in _tests) {
				if ([test.targetName isEqualToString: targetName] &&
					[test.className isEqualToString: className]) {
					[test beginTest];
					[runningTests addObject: test];
				}
			}
		}
		if ([maybeTest isKindOfClass: [SPMTestTarget class]]) {
			NSString * targetName = [(SPMTestTarget *)maybeTest targetName];
			[maybeTest beginTest];
			[runningTests addObject: maybeTest];
			
			for(SPMTest * test in _tests) {
				if ([test.targetName isEqualToString: targetName]) {
					[test beginTest];
					[runningTests addObject: test];
				}
			}
			for(SPMTestClass * test in _testClasses) {
				if ([test.targetName isEqualToString: targetName]) {
					[test beginTest];
					[runningTests addObject: test];
				}
			}
		}
	}
	
	spmateQueue.maxConcurrentOperationCount = getPhysicalCoreCount();
	[spmateQueue addOperationWithBlock: ^{
		NSString * spmatePath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"spmate"];
		NSLog(@"%@ %@ %@ %@ %@ %@", spmatePath, @"test", @"run", _projectPath, @"--filter", [filters componentsJoinedByString:@","]);
		std::string res = io::exec([spmatePath UTF8String], "test", "run", [_projectPath UTF8String], "--filter", [[filters componentsJoinedByString:@","] UTF8String], NULL);
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString * json = [NSString stringWithCxxString:res];
			[self handleTestResults: json
								forTests: runningTests];
		});
	}];
}

- (void) handleTestResults: (NSString *) json
						forTests: (NSArray*) runningTests {
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
	
	// sanity: all the tests we started should be done now, so reset any which are in progress
	for(SPMTest * test in runningTests) {
		if ([test.result isEqualToString: @"progress"]) {
			[test willChangeValueForKey:@"runIcon"];
			test.result = @"warn";
			[test didChangeValueForKey:@"runIcon"];
		}
	}
	
	for (SPMTestTarget * testTarget in _testTargets) {
		int numPass = 0;
		int numFail = 0;
		int numWaiting = 0;
		
		for (SPMTest * test in _tests) {
			if ([testTarget.targetName isEqualToString: test.targetName]) {
				if ([test.result isEqualToString: @"passed"]) {
					numPass += 1;
				} else if ([test.result isEqualToString: @"failed"]) {
					numFail += 1;
				} else if ([test.result isEqualToString: @"progress"]) {
					numWaiting += 1;
				}
			}
		}
		
		[testTarget willChangeValueForKey:@"runIcon"];
		if (numWaiting > 0) {
			testTarget.result = @"progress";
		} else if (numFail > 0) {
		 	testTarget.result = @"failed";
		} else if (numPass > 0) {
		 	testTarget.result = @"passed";
		}
		[testTarget didChangeValueForKey:@"runIcon"];
	}
	
	for (SPMTestClass * testClass in _testClasses) {
		int numPass = 0;
		int numFail = 0;
		int numWaiting = 0;
		
		for (SPMTest * test in _tests) {
			if ([testClass.targetName isEqualToString: test.targetName] &&
				[testClass.className isEqualToString: test.className]) {
				if ([test.result isEqualToString: @"passed"]) {
					numPass += 1;
				} else if ([test.result isEqualToString: @"failed"]) {
					numFail += 1;
				} else if ([test.result isEqualToString: @"progress"]) {
					numWaiting += 1;
				}
			}
		}
		
		[testClass willChangeValueForKey:@"runIcon"];
		if (numWaiting > 0) {
			testClass.result = @"progress";
		} else if (numFail > 0) {
		 	testClass.result = @"failed";
		} else if (numPass > 0) {
		 	testClass.result = @"passed";
		}
		[testClass didChangeValueForKey:@"runIcon"];
	}
	
	
	//NSLog(@"%@", json);
}

@end
