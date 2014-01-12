//
//  ScenarioTests.m
//  NyaruDB
//
//  Created by Kelp on 2014/01/12.
//
//

#import <XCTest/XCTest.h>
#import "NyaruDB.h"

@interface ScenarioTests : XCTestCase {
    NyaruDB *_db;
}

@end



@implementation ScenarioTests

- (void)setUp
{
    [super setUp];
    _db = [NyaruDB instance];
}

- (void)tearDown
{
    [NyaruDB reset];
    [super tearDown];
}

- (void)testCreateCollection
{
    NyaruDB *db = [NyaruDB instance];
    
    NyaruCollection *collection = [db collection:@"test01"];
    XCTAssertNotNil(collection, @"nil!!");
    [db removeCollection:@"test01"];
}

- (void)testInsertAndRemoveDocument
{
    NyaruCollection *collection = [_db collection:@"nya"];
    [collection removeAll];
    XCTAssertEqual(collection.count, 0U, @"");
    
    // insert with key
    NSString *key = [[collection put:@{@"data": @"value", @"key": @"aa" }] objectForKey:@"key"];
    XCTAssertEqual(collection.count, 1U, @"");
    XCTAssertEqualObjects([[[[collection where:@"key" equal:key] fetch] lastObject] objectForKey:@"data"], @"value", @"");
    
    // insert without key
    key = [[collection put:@{@"name": @"Kelp"}] objectForKey:@"key"];
    XCTAssertEqualObjects([[[[collection where:@"key" equal:key] fetch] lastObject] objectForKey:@"name"], @"Kelp", @"");
    // then remove it
    [[collection where:@"key" equal:key] remove];
    XCTAssertEqual(collection.count, 1U, @"");
    
    // remove key == @"aa"
    [[collection where:@"key" equal:@"aa"] remove];
    XCTAssertEqual(collection.count, 0U, @"");
}

- (void)testCreateAndRemoveIndex
{
    NyaruCollection *collection = [_db collection:@"nya"];
    [collection removeAllindexes];
    XCTAssertEqual(collection.allIndexes.count, 1U, @"");
    [collection createIndex:@"updateTime"];
    XCTAssertEqual([[NSSet setWithArray:collection.allIndexes] intersectsSet:[NSSet setWithObject:@"updateTime"]], YES, @"");
    
    [collection createIndex:@"updateTime"];
    [collection createIndex:@"indexA"];
    [collection createIndex:@"indexB"];
    XCTAssertEqual([[NSSet setWithArray:collection.allIndexes] intersectsSet:[NSSet setWithObject:@"indexA"]], YES, @"");
    XCTAssertEqual([[NSSet setWithArray:collection.allIndexes] intersectsSet:[NSSet setWithObject:@"indexB"]], YES, @"");
    XCTAssertEqual(collection.allIndexes.count, 4U, @"");
    [collection removeIndex:@"indexA"];
    [collection removeIndex:@"indexB"];
    XCTAssertEqual(collection.allIndexes.count, 2U, @"");
    
    // insert document into collection which has other indexes
    NSDate *time = [NSDate date];
    [collection put:@{@"name": @"Kelp"}];
    [collection put:@{@"name": @"Kelp X", @"updateTime": time}];
    [collection put:@{@"name": @"Kelp"}];
    XCTAssertEqualObjects([[collection where:@"updateTime" equal:time].fetch.lastObject objectForKey:@"name"], @"Kelp X", @"");
}

- (void)testInsertAndQueryString
{
    NyaruCollection *co = [_db collection:@"04"];
    [co createIndex:@"string"];
    
    for (NSInteger index = 0; index < 10; index++) {
        [co put:@{@"string": [NSString stringWithFormat:@"B%i", index], @"data": @"data00"}];
    }
    [co put:@{@"string": @"B5", @"data": @"data00"}];
    // count
    XCTAssertEqual([co where:@"string" equal:@"B0"].count, 1U, @"");
    XCTAssertEqual([co where:@"string" equal:@"B5"].count, 2U, @"");
    XCTAssertEqual([co where:@"string" equal:@"B9"].count, 1U, @"");
    XCTAssertEqual([co where:@"string" equal:@"B10"].count, 0U, @"");
    XCTAssertEqual([co where:@"string" notEqual:@"B0"].count, 10U, @"");
    XCTAssertEqual([co where:@"string" notEqual:@"B5"].count, 9U, @"");
    XCTAssertEqual([co where:@"string" notEqual:@"B9"].count, 10U, @"");
    XCTAssertEqual([co where:@"string" notEqual:@"B10"].count, 11U, @"");
    
    XCTAssertEqual([co where:@"string" greater:@"B9"].count, 0U, @"");
    XCTAssertEqual([co where:@"string" greater:@"B8"].count, 1U, @"");
    XCTAssertEqual([co where:@"string" greater:@"B0"].count, 10U, @"");
    XCTAssertEqual([co where:@"string" greater:@"A0"].count, 11U, @"");
    XCTAssertEqual([co where:@"string" greaterEqual:@"C0"].count, 0U, @"");
    XCTAssertEqual([co where:@"string" greaterEqual:@"B9"].count, 1U, @"");
    XCTAssertEqual([co where:@"string" greaterEqual:@"B8"].count, 2U, @"");
    XCTAssertEqual([co where:@"string" greaterEqual:@"B0"].count, 11U, @"");
    XCTAssertEqual([co where:@"string" greaterEqual:@"A0"].count, 11U, @"");
    
    XCTAssertEqual([co where:@"string" less:@"A0"].count, 0U, @"");
    XCTAssertEqual([co where:@"string" less:@"B0"].count, 0U, @"");
    XCTAssertEqual([co where:@"string" less:@"B1"].count, 1U, @"");
    XCTAssertEqual([co where:@"string" less:@"B6"].count, 7U, @"");
    XCTAssertEqual([co where:@"string" less:@"B9"].count, 10U, @"");
    XCTAssertEqual([co where:@"string" less:@"C0"].count, 11U, @"");
    XCTAssertEqual([co where:@"string" lessEqual:@"A0"].count, 0U, @"");
    XCTAssertEqual([co where:@"string" lessEqual:@"B0"].count, 1U, @"");
    XCTAssertEqual([co where:@"string" lessEqual:@"B1"].count, 2U, @"");
    XCTAssertEqual([co where:@"string" lessEqual:@"B6"].count, 8U, @"");
    XCTAssertEqual([co where:@"string" lessEqual:@"B9"].count, 11U, @"");
    XCTAssertEqual([co where:@"string" lessEqual:@"C0"].count, 11U, @"");
    
    XCTAssertEqual([co where:@"string" like:@"b"].count, 11U, @"");
    XCTAssertEqual([co where:@"string" like:@"c"].count, 0U, @"");
}

- (void)testInsertAndQueryNumber
{
    NyaruCollection *co = [_db collection:@"05"];
    [co createIndex:@"number"];
    
    for (NSInteger index = 0; index < 10; index++) {
        [co put:@{@"number": [NSNumber numberWithInteger:index], @"data": @"data00"}];
    }
    [co put:@{@"number": @5, @"data": @"data00"}];
    // count
    XCTAssertEqual([co where:@"number" equal:@0].count, 1U, @"");
    XCTAssertEqual([co where:@"number" equal:@5].count, 2U, @"");
    XCTAssertEqual([co where:@"number" equal:@9].count, 1U, @"");
    XCTAssertEqual([co where:@"number" equal:@10].count, 0U, @"");
    XCTAssertEqual([co where:@"number" notEqual:@0].count, 10U, @"");
    XCTAssertEqual([co where:@"number" notEqual:@5].count, 9U, @"");
    XCTAssertEqual([co where:@"number" notEqual:@9].count, 10U, @"");
    XCTAssertEqual([co where:@"number" notEqual:@10].count, 11U, @"");
    
    XCTAssertEqual([co where:@"number" greater:@9].count, 0U, @"");
    XCTAssertEqual([co where:@"number" greater:@8].count, 1U, @"");
    XCTAssertEqual([co where:@"number" greater:@0].count, 10U, @"");
    XCTAssertEqual([co where:@"number" greater:@-1].count, 11U, @"");
    XCTAssertEqual([co where:@"number" greaterEqual:@10].count, 0U, @"");
    XCTAssertEqual([co where:@"number" greaterEqual:@9].count, 1U, @"");
    XCTAssertEqual([co where:@"number" greaterEqual:@8].count, 2U, @"");
    XCTAssertEqual([co where:@"number" greaterEqual:@0].count, 11U, @"");
    XCTAssertEqual([co where:@"number" greaterEqual:@-1].count, 11U, @"");
    
    XCTAssertEqual([co where:@"number" less:@-1].count, 0U, @"");
    XCTAssertEqual([co where:@"number" less:@0].count, 0U, @"");
    XCTAssertEqual([co where:@"number" less:@1].count, 1U, @"");
    XCTAssertEqual([co where:@"number" less:@6].count, 7U, @"");
    XCTAssertEqual([co where:@"number" less:@9].count, 10U, @"");
    XCTAssertEqual([co where:@"number" less:@10].count, 11U, @"");
    XCTAssertEqual([co where:@"number" lessEqual:@-1].count, 0U, @"");
    XCTAssertEqual([co where:@"number" lessEqual:@0].count, 1U, @"");
    XCTAssertEqual([co where:@"number" lessEqual:@1].count, 2U, @"");
    XCTAssertEqual([co where:@"number" lessEqual:@6].count, 8U, @"");
    XCTAssertEqual([co where:@"number" lessEqual:@9].count, 11U, @"");
    XCTAssertEqual([co where:@"number" lessEqual:@10].count, 11U, @"");
}

- (void)testInsertAndQueryDate
{
    NyaruCollection *co = [_db collection:@"06"];
    [co createIndex:@"date"];
    
    for (NSInteger index = 1; index <= 10; index++) {
        [co put:@{@"date": [NSDate dateWithTimeIntervalSince1970:index * 100]}];
    }
    for (NSUInteger index = 1; index <= 10; index++) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:index * 100];
        XCTAssertEqual([[co where:@"date" equal:date] count], 1U, @"");
        
        date = [NSDate dateWithTimeIntervalSince1970:(index + 1) * 100];
        XCTAssertEqual([[co where:@"date" less:date] count], index, @"");
    }
    
    XCTAssertEqual([[co where:@"date" greaterEqual:[NSDate dateWithTimeIntervalSince1970:0]] count], 10U, @"");
    XCTAssertEqual([[co where:@"date" greaterEqual:[NSDate date]] count], 0U, @"");
    XCTAssertEqual([[co where:@"date" less:[NSDate date]] count], 10U, @"");
}

- (void)testReadWrite
{
    NyaruCollection *co = [_db collection:@"07"];
    
    NSDictionary *subDict = @{@"sub": @"data", @"empty": @""};
    NSArray *array = @[@"A", @-1, [NSNull null], @""];
    NSDictionary *doc = @{@"key": @"a",
                          @"number": @100,
                          @"double": @1000.00002,
                          @"date": [NSDate dateWithTimeIntervalSince1970:100],
                          @"null": [NSNull null],
                          @"sub": subDict,
                          @"array": array};
    [co put:doc];
    [co waitForWriting];
    [co clearCache];
    NSDictionary *check = co.all.fetch.lastObject;
    XCTAssertEqualObjects([check objectForKey:@"key"], [doc objectForKey:@"key"], @"");
    XCTAssertEqualObjects([check objectForKey:@"number"], [doc objectForKey:@"number"], @"");
    XCTAssertEqualObjects([check objectForKey:@"double"], [doc objectForKey:@"double"], @"");
    XCTAssertEqualObjects([check objectForKey:@"date"], [doc objectForKey:@"date"], @"");
    XCTAssertEqualObjects([check objectForKey:@"null"], [doc objectForKey:@"null"], @"");
    XCTAssertEqualObjects([[check objectForKey:@"sub"] objectForKey:@"sub"], [subDict objectForKey:@"sub"], @"");
    XCTAssertEqualObjects([[check objectForKey:@"sub"] objectForKey:@"empty"], [subDict objectForKey:@"empty"], @"");
    XCTAssertTrue([[check objectForKey:@"array"] containsObject:[array objectAtIndex:0]], @"");
    XCTAssertTrue([[check objectForKey:@"array"] containsObject:[array objectAtIndex:1]], @"");
    XCTAssertTrue([[check objectForKey:@"array"] containsObject:[array objectAtIndex:2]], @"");
    XCTAssertTrue([[check objectForKey:@"array"] containsObject:[array objectAtIndex:3]], @"");
}

- (void)testOrder
{
    NyaruCollection *co = [_db collection:@"08"];
    [co createIndex:@"number"];
    
    for (NSInteger index = 0; index < 32; index++) {
        [co put:@{@"number": [NSNumber numberWithInt:arc4random() % 10]}];
        [co put:@{}];
    }
    NSNumber *previous = nil;
    for (NSMutableDictionary *doc in [[co.all orderBy:@"number"] fetch]) {
        if (![doc objectForKey:@"number"] || [[doc objectForKey:@"number"] isKindOfClass:NSNull.class]) { continue; }
        
        if (previous) {
            if ([previous compare:[doc objectForKey:@"number"]] == NSOrderedDescending) {
                XCTFail(@"%@ --> %@", previous, [doc objectForKey:@"number"]);
            }
        }
        previous = [doc objectForKey:@"number"];
    }
    
    previous = nil;
    for (NSMutableDictionary *doc in [[co.all orderByDESC:@"number"] fetch]) {
        if (![doc objectForKey:@"number"] || [[doc objectForKey:@"number"] isKindOfClass:NSNull.class]) { continue; }
        
        if (previous) {
            if ([previous compare:[doc objectForKey:@"number"]] == NSOrderedAscending) {
                XCTFail(@"%@ --> %@", previous, [doc objectForKey:@"number"]);
            }
        }
        previous = [doc objectForKey:@"number"];
    }
}

- (void)testMixedQuery
{
    NyaruCollection *co = [_db collection:@"09"];
    [co createIndex:@"number"];
    [co createIndex:@"name"];
    
    for (NSInteger index = 0; index < 100; index++) {
        [co put:@{@"number": [NSNumber numberWithInt:arc4random() % 10],
                  @"name": @"Kelp"}];
        [co put:@{@"name": @"cc"}];
    }
    
    NSNumber *previous = nil;
    NSArray *documents = [[[[[co where:@"number" greaterEqual:@6] or:@"number" equal:@5] and:@"name" equal:@"kelp"] orderBy:@"number"] fetch];
    XCTAssertEqual(documents.count > 0, true, @"");
    for (NSMutableDictionary *doc in documents) {
        if (![doc objectForKey:@"number"] || [[doc objectForKey:@"number"] isKindOfClass:NSNull.class]) { continue; }
        
        if (previous) {
            if ([@4 compare:[doc objectForKey:@"number"]] == NSOrderedDescending) {
                XCTFail(@"4 --> %@", [doc objectForKey:@"number"]);
            }
            if ([previous compare:[doc objectForKey:@"number"]] == NSOrderedDescending) {
                XCTFail(@"%@ --> %@", previous, [doc objectForKey:@"number"]);
            }
        }
        previous = [doc objectForKey:@"number"];
    }
}

- (void)testMultithread
{
    NyaruCollection *co = [_db collection:@"10"];
    [co createIndex:@"number"];
    [co createIndex:@"update"];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSUInteger index = 0; index < 500; index++) {
            [co put:@{@"number": [NSNumber numberWithInt:arc4random() % 100], @"update": [NSDate date]}];
        }
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSUInteger index = 0; index < 500; index++) {
            [co put:@{@"number": [NSNumber numberWithInt:arc4random() % 100], @"update": [NSDate date]}];
        }
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSUInteger index = 0; index < 10; index++) {
            if (co.all.fetch) { }
        }
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
#if TARGET_OS_IPHONE
    dispatch_release(group);
#endif
    XCTAssertEqual(co.all.count, 1000U, @"");
}

- (void)testGreaterQuery
{
    NyaruCollection *co = [_db collection:@"s11"];
    [co createIndex:@"n"];
    
    [co put:@{@"n": @0}];
    [co put:@{@"n": @1}];
    [co put:@{@"n": @2}];
    [co put:@{@"n": @4}];
    [co put:@{@"n": @6}];
    
    XCTAssertEqual([co where:@"n" greater:@5].count, 1U, @"");
}

- (void)testSpeed
{
    NyaruCollection *collection = [_db collection:@"speed"];
    [collection createIndex:@"group"];
    
    NSMutableDictionary *doc = [[NSMutableDictionary alloc] initWithDictionary:@{
                          @"name": @"Test",
                          @"url": @"https://github.com/kelp404/NyaruDB",
                          @"phone": @"0123456",
                          @"address": @"1600 Amphitheatre Parkway Mountain View, CA 94043, USA",
                          @"email": @"test@phate.org",
                          @"level": @0,
                          @"updateTime": @""
                          }];
    NSDate *timer = [NSDate date];
    for (NSInteger loop = 0; loop < 1000; loop++) {
        [doc setObject:[NSNumber numberWithInt:arc4random() % 512] forKey:@"group"];
        [collection put:doc];
    }
    NSLog(@"------------------------------------------------");
    NSLog(@"insert 1k data cost : %f ms", [timer timeIntervalSinceNow] * -1000.0);
    NSLog(@"------------------------------------------------");
    [collection waitForWriting];
    
    timer = [NSDate date];
    if (collection.all.fetch) { };
    NSLog(@"------------------------------------------------");
    NSLog(@"fetch 1k data cost : %f ms", [timer timeIntervalSinceNow] * -1000.0);
    NSLog(@"------------------------------------------------");
    
    timer = [NSDate date];
    for (NSInteger index = 0; index < 10; index++) {
        if ([collection where:@"group" equal:[NSNumber numberWithInt:arc4random() % 512]].fetch) { }
    }
    NSLog(@"------------------------------------------------");
    NSLog(@"search documents in 1k data for 10 times cost : %f ms", [timer timeIntervalSinceNow] * -1000.0);
    NSLog(@"------------------------------------------------");
}


@end