//
//  HomeScreen.m
//  ShortcutsApp
//
//  Created by WangBin on 15/11/17.
//  Copyright © 2015年 WangBin. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPAD_RETINA (IS_IPAD && IS_RETINA)
#define IS_IPAD_PRO (IS_IPAD && IS_RETINA && SCREEN_MAX_LENGTH>1024)

#import "HomeScreen.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "UIImage+Scale.h"

@interface HomeScreen ()
@property (strong, nonatomic, readonly) HTTPServer *server;
@end
@implementation HomeScreen
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#pragma mark - life circle
+ (id)getInstance
{
    static id instance = nil;
    if (instance == nil) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];

        _server = [[HTTPServer alloc] init];

        [_server setType:@"_http._tcp."];
        
        NSString *webPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Web"];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL exist = [fm fileExistsAtPath:webPath];
        
        if (!exist) {
            BOOL success = [fm createDirectoryAtPath:webPath withIntermediateDirectories:YES attributes:nil error:nil];
            if (success) {
                NSLog(@"web dir create success!!!");
            }
        }else{
            NSLog(@"web dir already exist!!!");
        }
        DDLogInfo(@"Setting document root: %@", webPath);
        [_server setDocumentRoot:webPath];
        
        [self startServer];
    }
    
    return self;
}

#pragma mark - add
- (BOOL)addToHomeScreen:(HtmlItem *)htmlItem
{
    BOOL success = [self startServer];
    
    if (!success) {
        return NO;
    }
    
    NSString *documentRoot = _server.documentRoot;
    
    NSURL *docRoot = [NSURL fileURLWithPath:documentRoot isDirectory:YES];
    
    NSString *relativePath = [[NSURL URLWithString:@"index.html" relativeToURL:docRoot] relativePath];
    
    NSString *fullPath = [[documentRoot stringByAppendingPathComponent:relativePath] stringByStandardizingPath];
    
    NSString *hostHtml = [self homeScreenHtmlStringForItem:htmlItem];
    NSData *data = [hostHtml dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    
    NSString *str= [NSString stringWithFormat:@"data:text/html;charset=utf-8;base64,%@",base64];
    
    NSMutableString *html = [NSMutableString string];
    [html appendString:@"<html>"];
    [html appendString:@"<head>"];
    [html appendString:@"<meta content=\"text/html charset= UTF-8\" http-equiv=\"Content-Type\">"];
    [html appendFormat:@"<meta http-equiv=\"refresh\" content=\"0;URL=%@\">",str];
    [html appendString:@"<body>"];
    [html appendString:@"</body>"];
    [html appendString:@"</head>"];
    [html appendString:@"</html>"];
    
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    success = [htmlData writeToFile:fullPath atomically:YES];
    
    if (success) {
        NSString *urlStrWithPort = [NSString stringWithFormat:@"http://localhost:%d",[_server listeningPort]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStrWithPort]];
    }else{
        NSLog(@"IO Error!!!");
    }
    
    return success;
}


- (NSMutableString *)homeScreenHtmlStringForItem:(HtmlItem *)htmlItem
{
    NSMutableString *html = [NSMutableString string];
    [html appendString:@"<html>"];
    [html appendString:@"<head>"];
    [html appendString:@"<meta name=\"apple-mobile-web-app-capable\" content=\"yes\">"];
    [html appendString:@"<meta name=\"apple-mobile-web-status-bar-style\" content=\"black\">"];
    [html appendString:@"<meta content=\"text/html charset= UTF-8\" http-equiv=\"Content-Type\" />"];
    [html appendString:@"<meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0,user-scalable=no\" />"];
    
    CGSize size = [self specificalImageSize];
    UIImage *image = [htmlItem.image imageByScalingAndCroppingForTargetSize:size];
    NSString *base64 = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:0];
    NSString *str= [NSString stringWithFormat:@"data:image/png;base64,%@",base64];
    
    [html appendFormat:@"<link rel=\"apple-touch-icon\" href= \"%@\">",str];
    
    [html appendFormat:@"<title>%@</title>",htmlItem.title];
    [html appendString:@"</head>"];
    [html appendFormat:@"<body bgcolor=\"#ffffff\"><a href=\"%@://%@\" id=\"qbt\" style=\"dispaly:none\"></a><span id=\"msg\"></span></body>",self.appScheme,htmlItem.host];
    [html appendFormat:@"<script>if (window.navigator.standalone == true) {var lnk = document.getElementById(\"qbt\");var evt = document.createEvent('MouseEvent');evt.initMouseEvent('click');lnk.dispatchEvent(evt);}else{document.getElementById(\"msg\").innerHTML = '<div style=\"text-align:center\"><h1>%@<h1><img src=\"%@\"></img><h3>温馨提示：在Safari导航栏或菜单栏中打开 ↑ 选择 ＋ 添加到主屏幕</h3></div>';}</script>",htmlItem.title,str];
    
    [html appendString:@"</html>"];
    
    return html;
}

- (BOOL)startServer
{
    @synchronized(self) {
        if (_server.isRunning) {
            return YES;
        }
        return [_server start:nil];
    }
}

#pragma mark - utils

- (CGSize )specificalImageSize
{
    if (IS_IPHONE) {
        if (IS_IPHONE_6P){
            return CGSizeMake(180, 180);
        }else{
            return CGSizeMake(120, 120);
        }
    }
    else{
        if (IS_IPAD_PRO) {
            return CGSizeMake(167, 167);
        }else if(IS_IPAD_RETINA){
            return CGSizeMake(152, 152);
        }else{
            return CGSizeMake(76, 76);
        }
    }
    return CGSizeZero;
}

#pragma mark - application
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self startServer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    @synchronized(self) {
        if (_server.isRunning) {
            [_server stop];
        }
    }
}

@end
