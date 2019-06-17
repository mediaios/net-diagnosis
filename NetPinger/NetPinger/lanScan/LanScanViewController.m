//
//  LanScanViewController.m
//  NetPinger
//
//  Created by mediaiios on 2019/6/17.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import "LanScanViewController.h"
#import <PhoneNetSDK/PhoneNetSDK.h>
#import "NetPingerConst.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LanScanViewController ()<UITableViewDataSource,UITableViewDelegate,PNetMLanScannerDelegate>
@property (nonatomic,strong) NSMutableArray *activeIps;
@property (weak, nonatomic) IBOutlet UIProgressView *progressV;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


/*** head views ***/
@property (nonatomic,strong) UIView *headView;
@property (nonatomic,strong) UIView *wifiInfoView;
@property (nonatomic,strong) UIView *summaryView;
@property (nonatomic,strong) UILabel *summaryLabel;
@property (nonatomic,strong) UIView *commentView;

/*** tip view ***/
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation LanScanViewController
- (NSMutableArray *)activeIps
{
    if (!_activeIps) {
        _activeIps = [NSMutableArray array];
    }
    return _activeIps;
}

- (UIView *)wifiInfoView
{
    if (!_wifiInfoView) {
        _wifiInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _wifiInfoView.backgroundColor = [UIColor yellowColor];
        
        NetWorkInfo *netInfo = [[PhoneNetManager shareInstance] netGetNetworkInfo];
        NSString *wifiName = nil;
        NSString *ipv4 = nil;
        if (netInfo) {
            PDeviceNetInfo *deviceNet = netInfo.deviceNetInfo;
            wifiName = deviceNet.wifiSSID;
            ipv4 = deviceNet.wifiIPV4;
        }
        
        UILabel *wifiNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.bounds.size.width, 20)];
        wifiNameLabel.text = [NSString stringWithFormat:@"BSSID: %@",wifiName];
        wifiNameLabel.font = [UIFont systemFontOfSize:20];
        wifiNameLabel.textAlignment = NSTextAlignmentCenter;
        [_wifiInfoView addSubview:wifiNameLabel];
        
        UILabel *ipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 15)];
        ipLabel.text = [NSString stringWithFormat:@"local ip: %@",ipv4];
        ipLabel.font = [UIFont systemFontOfSize:10];
        ipLabel.textAlignment = NSTextAlignmentCenter;
        [_wifiInfoView addSubview:ipLabel];
    }
    return _wifiInfoView;
}

- (UILabel *)summaryLabel
{
    if (!_summaryLabel) {
        _summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 200)/2, 0, 200, 40)];
        _summaryLabel.textAlignment = NSTextAlignmentCenter;
        _summaryLabel.font = [UIFont systemFontOfSize:15];
        _summaryLabel.text = @"ALL Devices(0)";
    }
    return _summaryLabel;
}

- (UIView *)summaryView
{
    if (!_summaryView) {
        _summaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 40)];
        _summaryView.backgroundColor = [UIColor greenColor];
        [_summaryView addSubview:self.summaryLabel];
    }
    return _summaryView;
}

- (UIView *)headView
{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
        [_headView addSubview:self.wifiInfoView];
        [_headView addSubview:self.summaryView];
        [_headView addSubview:self.commentView];
    }
    return _headView;
}

- (UIView *)commentView
{
    if (!_commentView) {
        _commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, 60)];
        _commentView.backgroundColor = QiColor(237, 237, 237);
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width-30, 60)];
        commentLabel.backgroundColor = QiColor(237, 237, 237);
        commentLabel.text = @"This is an informational list of all the device found on the network. These can include cameras or normal devices like computers,phones,printers,rotes and etc.";
        commentLabel.numberOfLines = -1;
        commentLabel.font = [UIFont systemFontOfSize:12.6];
        [_commentView addSubview:commentLabel];
    }
    return _commentView;
}

- (void)updateSummaryInfo:(NSUInteger)activeIps
{
    self.summaryLabel.text = [NSString stringWithFormat:@"ALL Devices(%lu)",(unsigned long)activeIps];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [[PhoneNetManager shareInstance] settingSDKLogLevel:PhoneNetSDKLogLevel_DEBUG];
    [PNetMLanScanner shareInstance].delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PNetMLanScanner shareInstance] scan];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.label.text = @"Scanning";
    _hud.dimBackground = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    PNetMLanScanner *lanScan = [PNetMLanScanner shareInstance];
    if ([lanScan isScanning]) {
        [[PNetMLanScanner shareInstance] stop];
        [self.hud removeFromSuperview];
    }
    _activeIps = [NSMutableArray array];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 140.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [self updateSummaryInfo:self.activeIps.count];
    return self.headView;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.activeIps.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_active_ip"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    
    NSString *ip = [self.activeIps objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", ip];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - PNetMLanScannerDelegate
- (void) scanMLan:(PNetMLanScanner *)scanner activeIp:(NSString *)ip
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activeIps addObject:ip];
        [self.tableView reloadData];
    });
    
}


- (void) scanMlan:(PNetMLanScanner *)scanner percent:(float)percent
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressV.progress = percent;
    });
    
    
}


- (void) finishedScanMlan:(PNetMLanScanner *)scanner
{
    dispatch_async(dispatch_get_main_queue(), ^{
         [self.hud removeFromSuperview];
    });
   
}



@end
