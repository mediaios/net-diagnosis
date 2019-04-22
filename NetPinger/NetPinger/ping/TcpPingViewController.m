//
//  TcpPingViewController.m
//  NetPinger
//
//  Created by mediaios on 2019/3/15.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "TcpPingViewController.h"
#import <PhoneNetSDK/PhoneNetSDK.h>
#import "NetPingerConst.h"


#define  kTcpPingIp   @"TcpPingIP"
#define  kTcpPingPort   @"TcpPingPort"
#define  kTcpPingBtnTag_NoPing    1999
#define  kTcpPingBtnTag_DoPing    2000
@interface TcpPingViewController ()
@property (weak, nonatomic) IBOutlet UITextField *hostTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UIButton *pingBtn;
@property (weak, nonatomic) IBOutlet UITextView *pingResTV;

@property (nonatomic,strong) PNTcpPing *tcpPing;
@property (nonatomic,strong) NSTimer *uiTimer;


@end

@implementation TcpPingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Tcp Ping";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *ipaddress = [[NSUserDefaults standardUserDefaults] objectForKey:kTcpPingIp];
    if (ipaddress != NULL) {
        self.hostTF.text = ipaddress;
    }
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:kTcpPingPort];
    if (port) {
        self.portTF.text = port;
    }
    
    if (_uiTimer == NULL) {
        _uiTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(doupdata) userInfo:nil repeats:YES];
    }
}

- (void)doupdata
{
    if(_tcpPing && [_tcpPing isTcpPing])
    {
        self.pingBtn.backgroundColor = [UIColor redColor];
        [self.pingBtn setTitle:@"Stop" forState:UIControlStateNormal];
    }else{
        self.pingBtn.backgroundColor = QiColor(49,170,22);
        [self.pingBtn setTitle:@"Ping" forState:UIControlStateNormal];
        self.pingBtn.tag = kTcpPingBtnTag_NoPing;
    }
}


- (IBAction)onPressedBtnTcpPing:(id)sender {
    [self hideKeyboard];
    if ([self checkInvalidTextField:self.hostTF]) {
        [self processIpInvalid];
        return;
    }
    
    self.pingBtn.tag = self.pingBtn.tag == kTcpPingBtnTag_NoPing ? kTcpPingBtnTag_DoPing : kTcpPingBtnTag_NoPing;
    int tagValue = (int)self.pingBtn.tag;
    switch (tagValue) {
        case kTcpPingBtnTag_DoPing:
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.hostTF.text forKey:kTcpPingIp];
            [[NSUserDefaults standardUserDefaults] setObject:self.portTF.text forKey:kTcpPingPort];
            self.pingResTV.text = NULL;
            NSString *hostDomain = NULL;
            if (self.hostTF.text.length > 0) {
                hostDomain = self.hostTF.text;
            }
            NSString *portNum = @"80";
            if (self.portTF.text.length > 0) {
                portNum = self.portTF.text;
            }
            
            _tcpPing = [PNTcpPing start:hostDomain port:portNum.integerValue count:3 complete:^(NSMutableString *pingres) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.pingResTV.text = pingres;
                });
                
            }];
        }
            break;
        case kTcpPingBtnTag_NoPing:
        {
            [_tcpPing stopTcpPing];
        }
            break;
            
        default:
            break;
    }
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hideKeyboard];
}

- (BOOL)checkInvalidTextField:(UITextField *)tf
{
    if (tf.text ==  NULL || tf.text.length == 0 || [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        return YES;
    }
    return NO;
}


- (void)hideKeyboard
{
    if ([self.hostTF isFirstResponder]) {
        [self.hostTF resignFirstResponder];
    }else if ([self.portTF isFirstResponder]) {
        [self.portTF resignFirstResponder];
    }
}

- (void)processIpInvalid
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"please input ip or domain" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
