//
//  PingViewController.m
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PingViewController.h"
#import <PhoneNetSDK/PhoneNetSDK.h>
#import "NetPingerConst.h"

#define  kPingIp   @"PingIP"
#define  kPingBtnTag_NoPing    999
#define  kPingBtnTag_DoPing    1000

@interface PingViewController ()
@property (weak, nonatomic) IBOutlet UITextField *pingTF;
@property (weak, nonatomic) IBOutlet UITextView *pingResTV;
@property (weak, nonatomic) IBOutlet UIButton *pingBtn;
@property (nonatomic,strong) NSTimer *uiTimer;

@property (nonatomic,strong) NSMutableString *pingDetails;

@end

@implementation PingViewController

- (NSMutableString *)pingDetails
{
    if (!_pingDetails) {
        _pingDetails = [NSMutableString string];
    }
    return _pingDetails;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
     self.title = @"Ping";
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *ipaddress = [[NSUserDefaults standardUserDefaults] objectForKey:kPingIp];
    if (ipaddress != NULL) {
        self.pingTF.text = ipaddress;
    }
    
    if (_uiTimer == NULL) {
        _uiTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(doupdata) userInfo:nil repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([[PhoneNetManager shareInstance] isDoingPing]) {
        [[PhoneNetManager shareInstance] netStopPing];
        self.pingBtn.backgroundColor = QiColor(49,170,22);
        [self.pingBtn setTitle:@"Ping" forState:UIControlStateNormal];
    }
    if (_uiTimer) {
        [_uiTimer invalidate];
        _uiTimer = nil;
    }
}

- (void)doupdata
{
   if( [[PhoneNetManager shareInstance] isDoingPing])
   {
       self.pingBtn.backgroundColor = [UIColor redColor];
       [self.pingBtn setTitle:@"Stop" forState:UIControlStateNormal];
   }else{
       self.pingBtn.backgroundColor = QiColor(49,170,22);
       [self.pingBtn setTitle:@"Ping" forState:UIControlStateNormal];
       self.pingBtn.tag = kPingBtnTag_NoPing;
   }
}

- (IBAction)onpressedButtonPing:(id)sender {
    [self hideKeyboard];
    
    if (self.pingTF.text == NULL || self.pingTF.text.length == 0 || [self.pingTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [self processIpInvalid];
        return;
    }
    
    self.pingBtn.tag = self.pingBtn.tag == kPingBtnTag_NoPing ? kPingBtnTag_DoPing : kPingBtnTag_NoPing;
    int tagValue = (int)self.pingBtn.tag;
    switch (tagValue) {
        case kPingBtnTag_DoPing:
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.pingTF.text forKey:kPingIp];
            
            if (self.pingDetails.length != 0) {
                self.pingDetails = NULL;
            }
            
            NSString *ip = self.pingTF.text;
            [[PhoneNetManager shareInstance] netStartPing:ip packetCount:10 pingResultHandler:^(NSString * _Nullable pingres) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pingDetails appendString:pingres];
                    [self.pingDetails appendString:@"\n"];
                    self.pingResTV.text = self.pingDetails;
                });
            }];
        }
            break;
        case kPingBtnTag_NoPing:
        {
            [[PhoneNetManager shareInstance] netStopPing];
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

- (void)hideKeyboard
{
    if ([self.pingTF isFirstResponder]) {
        [self.pingTF resignFirstResponder];
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

@end
