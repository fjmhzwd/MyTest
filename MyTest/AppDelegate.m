//
//  AppDelegate.m
//  MyTest
//
//  Created by wayne on 14-11-7.
//  Copyright (c) 2014年 wayne. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <objc/runtime.h>

@interface AppDelegate ()
{
    CTTelephonyNetworkInfo *networkInfo;
}

@end

@implementation AppDelegate

- (NSString*)getLessonString:(NSArray*)lesson
{
    if ([lesson count] <= 2)
        return [lesson componentsJoinedByString:@","];
    NSString *result = [lesson firstObject];
    BOOL isSerial = NO;
    for (NSInteger i = 2; i < [lesson count]; i++) {
        NSString *pre = [lesson objectAtIndex:i - 1];
        NSString *cur = [lesson objectAtIndex:i];
        if (isSerial)
        {
            if ((cur.integerValue - pre.integerValue) == 1)
            {
                
            }
            else
            {
                result = [NSString stringWithFormat:@"%@%@", result, pre];
                isSerial = NO;
            }
        }
        else
        {
            NSString *start = [lesson objectAtIndex:i - 2];
            if (((pre.integerValue - start.integerValue) == 1) &&
                ((cur.integerValue - pre.integerValue) == 1))
            {
                result = [NSString stringWithFormat:@"%@~", result];
                isSerial = YES;
            }
            else
            {
                result = [NSString stringWithFormat:@"%@,%@", result, pre];
            }
        }
        if (i == ([lesson count] - 1))
        {
            if (isSerial)
                result = [NSString stringWithFormat:@"%@%@", result, cur];
            else
                result = [NSString stringWithFormat:@"%@,%@", result, cur];
        }
    }
    return result;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」、[]{}#%-*+=_\\|~＜＞$€^•’@#$%^&*()_+’"];
    NSString *dd = @"sdf+sdf[<sdfsdf^sdfsdf+";
    dd = [dd stringByTrimmingCharactersInSet:set];
    NSLog(@"%@", dd);
    
    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    NSLog(@"[familyNames count]===%d",[familyNames count]);
    for(indFamily=0;indFamily<[familyNames count];++indFamily)
        
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
        
        for(indFont=0; indFont<[fontNames count]; ++indFont)
            
        {
            NSLog(@"Font name: %@",[fontNames objectAtIndex:indFont]);
            
        }
    }
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit
                                         fromDate:now];
    
    // 得到星期几
    // 1(星期天) 2(星期二) 3(星期三) 4(星期四) 5(星期五) 6(星期六) 7(星期天)
    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    
    NSLog(@"weekDay:%ld   day:%ld",weekDay,day);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"e"];
    int result =  [[dateFormatter stringFromDate:now]intValue];
    NSLog(@"weekDay:%ld   day:%ld",result,day);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate date];
    
    //正规化的格式设定
    [formatter setDateFormat:@"M月d日' 'EEE"];
    
    //正规化取得的系统时间并显示
    NSLog( [formatter stringFromDate:date]);
    NSLog([self getLessonString:@[@"1",@"3",@"4",@"6", @"7",@"9",@"10",@"12"]]);

    [self testNetwork];
    return YES;
}

//添加关联对象
- (void)addAssociatedObject:(id)object{
    objc_setAssociatedObject(self, @selector(getAssociatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
//获取关联对象 注意：这里面我们把getAssociatedObject方法的地址作为唯一的key，_cmd代表当前调用方法的地址。
- (id)getAssociatedObject{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)testNetwork
{
    networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSLog(@"Initial cell connection: %@", networkInfo.currentRadioAccessTechnology);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioAccessChanged:) name:
     CTRadioAccessTechnologyDidChangeNotification object:networkInfo];
}

- (void)radioAccessChanged:(NSNotification*)notify {

    NSLog(@"Now you’re connected via %@", networkInfo.currentRadioAccessTechnology);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
/*
 常用的正则表达式
 
 pattern的用法都一样，这里不再啰嗦各种详细写法了，只是列出来一些常用的正则就好了：
 
 信用卡  [0-9]{13,16}
 
 银联卡  ^62[0-5]\d{13,16}$
 
 Visa: ^4[0-9]{12}(?:[0-9]{3})?$
 
 万事达：^5[1-5][0-9]{14}$
 
 QQ号码： [1-9][0-9]{4,14}
 
 手机号码：^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$
 
 身份证：^([0-9]){7,18}(x|X)?$
 
 密码：^[a-zA-Z]\w{5,17}$ 字母开头，长度在6~18之间，只能包含字母、数字和下划线
 
 强密码：^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,10}$ 包含大小写字母和数字的组合，不能使用特殊字符，长度在8-10之间
 
 7个汉字或14个字符：^[\u4e00-\u9fa5]{1,7}$|^[\dA-Za-z_]{1,14}$
 */

@end
