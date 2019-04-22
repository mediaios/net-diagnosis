//
//  DeviceNetInfoViewController.m
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "DeviceNetInfoViewController.h"
#import "NetPingerConst.h"

@interface DeviceNetInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *netInfo_table;

@end

@implementation DeviceNetInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
     self.title = @"Network Info";
    
    [self setNavigationBarRightItemW];
}

- (void)setNavigationBarRightItemW
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Refresh" forState:UIControlStateNormal];
    [button setTitleColor:QiColor(26, 134, 223) forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)refreshData
{
    self.netInfo = [[PhoneNetManager shareInstance] netGetNetworkInfo];
    [self.netInfo_table reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.netInfo = [[PhoneNetManager shareInstance] netGetNetworkInfo];
    [self.netInfo_table reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.netInfo.deviceNetInfo.netType isEqualToString:@"WIFI"]) {
        return 3;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int res = 0;
    if ([self.netInfo.deviceNetInfo.netType isEqualToString:@"WIFI"]) {
      res = section == 0 ? (6) : ( section == 1 ? 1 : 6);
    }else{
      res = section == 0 ? 2 : 6;
    }
    
    return res;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"Cell_identifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];

    cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifer];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    if ([self.netInfo.deviceNetInfo.netType isEqualToString:@"WIFI"]) {
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"NetType";
                cell.detailTextLabel.text = self.netInfo.deviceNetInfo.netType;
            }
            
            if (indexPath.row == 1) {
                cell.detailTextLabel.text = self.netInfo.deviceNetInfo.wifiSSID;
                cell.textLabel.text = @"Name";
            }
            
            if (indexPath.row == 2) {
                cell.detailTextLabel.text = self.netInfo.deviceNetInfo.wifiBSSID;
                cell.textLabel.text = @"BSSID";
            }
            
            if (indexPath.row == 3) {
                cell.detailTextLabel.text = self.netInfo.deviceNetInfo.wifiIPV4;
                cell.textLabel.text = @"IPV4";
            }
            
            if (indexPath.row == 4) {
                cell.detailTextLabel.text = self.netInfo.deviceNetInfo.wifiIPV6;
                cell.textLabel.text = @"IPV6";
            }
            
            if (indexPath.row == 5) {
                cell.detailTextLabel.text = self.netInfo.deviceNetInfo.wifiNetmask;
                cell.textLabel.text = @"Subnet Mask";
            }
            
        }
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"IPV4";
                cell.detailTextLabel.text = self.netInfo.deviceNetInfo.cellIPV4;
            }
        }
        
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.ip;
                cell.textLabel.text = @"Public IP";
            }
            
            if (indexPath.row == 1) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.city;
                cell.textLabel.text = @"City";
            }
            
            if (indexPath.row == 2) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.region;
                cell.textLabel.text = @"Region";
            }
            
            if (indexPath.row == 3) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.country;
                cell.textLabel.text = @"Country";
            }
            
            if (indexPath.row == 4) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.location;
                cell.textLabel.text = @"loc";
            }
            
            if (indexPath.row == 5) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.org;
                cell.textLabel.text = @"org";
            }
        }
        
        
    }else{
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"NetType";
                cell.detailTextLabel.text = self.netInfo.deviceNetInfo.netType;
            }
            
            if (indexPath.row == 1) {
                cell.detailTextLabel.text = self.netInfo.deviceNetInfo.cellIPV4;
                cell.textLabel.text = @"IPV4";
            }
            
        }
        
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.ip;
                cell.textLabel.text = @"Public IP";
            }
            
            if (indexPath.row == 1) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.city;
                cell.textLabel.text = @"City";
            }
            
            if (indexPath.row == 2) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.region;
                cell.textLabel.text = @"Region";
            }
            
            if (indexPath.row == 3) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.country;
                cell.textLabel.text = @"Country";
            }
            
            if (indexPath.row == 4) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.location;
                cell.textLabel.text = @"loc";
            }
            
            if (indexPath.row == 5) {
                cell.detailTextLabel.text = self.netInfo.ipInfoModel.org;
                cell.textLabel.text = @"org";
            }
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
    if ([self.netInfo.deviceNetInfo.netType isEqualToString:@"WIFI"]) {
        
        if (section == 0) {
             return [self createHeadViewWithImageName:@"net" title:@"本机网络"];
        }
        if (section == 1) {
            return [self createHeadViewWithImageName:@"cell" title:@"蜂窝网络"];
        }
        if (section == 2) {
            return [self createHeadViewWithImageName:@"info" title:@"公网信息"];
        }
        
        return NULL;
    }else{
        
        if (section == 0) {
            return [self createHeadViewWithImageName:@"net" title:@"本机网络"];
        }
        if (section == 1) {
            return [self createHeadViewWithImageName:@"info" title:@"公网信息"];
        }
        
    }
    
    return NULL;
    
}


- (UIView *)createHeadViewWithImageName:(NSString *)imgName title:(NSString *)title
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.netInfo_table.frame.size.width, 50.0)];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
