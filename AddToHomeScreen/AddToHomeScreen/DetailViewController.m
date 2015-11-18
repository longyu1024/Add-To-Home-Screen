//
//  DetailViewController.m
//  ShortcutsApp
//
//  Created by WangBin on 15/11/16.
//  Copyright © 2015年 WangBin. All rights reserved.
//

#import "DetailViewController.h"
#import "HomeScreen.h"

@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *btn;

@end
@implementation DetailViewController

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btn];
}

- (IBAction)shortcuts:(UIButton *)sender {
    
    HtmlItem *htmlItem = [[HtmlItem alloc] init];
    htmlItem.title = self.title;
    htmlItem.image = self.image;
    htmlItem.host = self.identify;
    
    [[HomeScreen getInstance] addToHomeScreen:htmlItem];
}

@end
