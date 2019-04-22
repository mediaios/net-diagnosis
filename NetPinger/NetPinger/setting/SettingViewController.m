//
//  SettingViewController.m
//  NetPinger
//
//  Created by mediaios on 2019/3/15.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "SettingViewController.h"
#import "NetPingerConst.h"



@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UISwitch *icmpTraceSwitch;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _icmpTraceSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
//    [_icmpTraceSwitch addTarget:self action:@selector(switchTracerouteMethod) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL isEnableICMPTrace = [[NSUserDefaults standardUserDefaults] boolForKey:kISEnableICMPTrace];
    [self.icmpTraceSwitch setOn:isEnableICMPTrace];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:self.icmpTraceSwitch.isOn forKey:kISEnableICMPTrace];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//- (void)switchTracerouteMethod
//{
//    [[NSUserDefaults standardUserDefaults] setBool:self.icmpTraceSwitch.isOn forKey:kISEnableICMPTrace];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"Cell_identifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifer];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            cell.textLabel.text = @"Enable ICMP traceroute";
            cell.accessoryView= self.icmpTraceSwitch;
        }
    }
    
   
    
    
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 50.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [self createHeadViewWithImageName:@"ping" title:@"ping"];
    }
    if (section == 1) {
        return [self createHeadViewWithImageName:@"traceroute" title:@"traceroute"];
    }
    return NULL;
}


- (UIView *)createHeadViewWithImageName:(NSString *)imgName title:(NSString *)title
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50.0)];
    headView.backgroundColor =  QiColor(237, 237, 237);
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (50-20)/2, 20, 20)];
    imgView.image = [UIImage imageNamed:imgName];
    [headView addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 100, 30)];
    label.text = title;
    [label setTextColor:QiColor(21, 37, 120)];
    [headView addSubview:label];
    
    return headView;
}

@end
