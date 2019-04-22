//
//  MainViewController.m
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "MainViewController.h"
#import "MainItemCell.h"
#import "DeviceNetInfoViewController.h"
#import "PingViewController.h"
#import "TracertViewController.h"
#import "PortScanViewController.h"
#import "LookupViewController.h"
#import "TcpPingViewController.h"

@interface MainViewController ()
@property (nonatomic,copy) NSArray *itemsLabelArray;
@property (nonatomic,copy) NSArray *itemsImageArray;

@property (nonatomic,strong) DeviceNetInfoViewController *deviceNetInfoVC;
@property (nonatomic,strong) PingViewController *pingVC;
@property (nonatomic,strong) TracertViewController *tracertVC;
@property (nonatomic,strong) PortScanViewController *portScanVC;
@property (nonatomic,strong) LookupViewController *ipDetailsVC;
@property (nonatomic,strong) TcpPingViewController *tcpPingVC;
@end

@implementation MainViewController

static NSString * const reuseIdentifier = @"MainItemCell";

- (NSArray *)itemsImageArray
{
    if (!_itemsImageArray) {
        _itemsImageArray = @[@"networkInfo",@"ping",@"tcp_ping",@"traceroute",@"portScan",@"lookup"];
    }
    return _itemsImageArray;
}

- (NSArray *)itemsLabelArray
{
    if (!_itemsLabelArray) {
        _itemsLabelArray = @[@"Network Info",@"Ping",@"Tcp Ping",@"Traceroute",@"Port Scan",@"Lookup"];
    }
    return _itemsLabelArray;
}

#pragma mark -About view controllers
- (DeviceNetInfoViewController *)deviceNetInfoVC
{
    if (!_deviceNetInfoVC) {
        _deviceNetInfoVC = [[DeviceNetInfoViewController alloc] initWithNibName:@"DeviceNetInfoViewController" bundle:nil];
    }
    return _deviceNetInfoVC;
}

- (PingViewController *)pingVC
{
    if (!_pingVC) {
        _pingVC = [[PingViewController alloc] initWithNibName:@"PingViewController" bundle:nil];
    }
    return _pingVC;
}

- (TracertViewController *)tracertVC
{
    if (!_tracertVC) {
        _tracertVC = [[TracertViewController alloc] initWithNibName:@"TracertViewController" bundle:nil];
    }
    return _tracertVC;
}

- (PortScanViewController *)portScanVC
{
    if (!_portScanVC) {
        _portScanVC = [[PortScanViewController alloc] initWithNibName:@"PortScanViewController" bundle:nil];
    }
    return _portScanVC;
}

- (LookupViewController *)ipDetailsVC
{
    if (!_ipDetailsVC) {
        _ipDetailsVC = [[LookupViewController alloc] initWithNibName:@"LookupViewController" bundle:nil];
    }
    return _ipDetailsVC;
}

- (TcpPingViewController *)tcpPingVC
{
    if (!_tcpPingVC) {
        _tcpPingVC = [[TcpPingViewController alloc] initWithNibName:@"TcpPingViewController" bundle:nil];
    }
    return _tcpPingVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[MainItemCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemsLabelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MainItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    MainItemInfo *mainItemInfo = [MainItemInfo  mainItempInfoWithDict:@{@"icon":self.itemsImageArray[indexPath.row],@"funcName":self.itemsLabelArray[indexPath.row]}];
    cell.mainItemInfo = mainItemInfo;
    // Configure the cell
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            {
                [self.navigationController pushViewController:self.deviceNetInfoVC animated:YES];
            }
            break;
        case 1:
            {
                [self.navigationController pushViewController:self.pingVC animated:YES];
            }
            break;
        case 2:
        {
            [self.navigationController pushViewController:self.tcpPingVC animated:YES];
        }
            break;
        case 3:
        {
            [self.navigationController pushViewController:self.tracertVC animated:YES];
        }
            break;
        case 4:
        {
            [self.navigationController pushViewController:self.portScanVC animated:YES];
        }
            break;
        case 5:
        {
            [self.navigationController pushViewController:self.ipDetailsVC animated:YES];
        }
            break;
          
        default:
            break;
    }
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(collectionView.frame.size.width/3 - 8, collectionView.frame.size.width/3);
}

@end
