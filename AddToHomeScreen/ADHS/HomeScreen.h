//
//  HomeScreen.h
//  ShortcutsApp
//
//  Created by WangBin on 15/11/17.
//  Copyright © 2015年 WangBin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "HtmlItem.h"

@interface HomeScreen : NSObject
@property (copy, nonatomic) NSString *appScheme;

+ (id)getInstance;

- (BOOL)addToHomeScreen:(HtmlItem *)htmlItem;

- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
@end
