//
//  ViewController.m
//  AddToHomeScreen
//
//  Created by WangBin on 15/11/18.
//  Copyright © 2015年 WangBin. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *destVc = segue.destinationViewController;
    NSString *identifier = segue.identifier;
    NSUInteger index = [identifier integerValue]-1;
    
    UITableViewCell*cell = [self.tableView.visibleCells objectAtIndex:index];
    
    destVc.title = cell.textLabel.text;
    destVc.image = cell.imageView.image;
    destVc.identify = identifier;
}

@end
