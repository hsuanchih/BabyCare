//
//  RemindViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/17/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "RemindViewController.h"
#import "Theme.h"

@interface RemindViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation RemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = NO;
    self.title = NSLocalizedString(@"Remind", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}



#pragma mark - UITableView datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RemindTableViewCellID"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RemindTableViewCellID"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [Theme fontOfSize:14.0];
    cell.textLabel.text = NSLocalizedString(@"The Baby's temperature is 42 degrees", nil);
    
    cell.detailTextLabel.font = [Theme boldFontOfSize:12.0];
    cell.detailTextLabel.textColor = [UIColor redColor];
    cell.detailTextLabel.text = NSLocalizedString(@"three hours ago, hh:mm:ss", nil);
    
    cell.backgroundColor = [Theme backgroundColorWithAlpha:1];
    return cell;
}

@end
