//
//  TracertViewController.m
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "TracertViewController.h"
#import <PhoneNetSDK/PhoneNetSDK.h>
#import "NetPingerConst.h"

#define  kTracertIp   @"TracertIP"

#define  kTracertBtnTag_NoTrace   1001
#define  kTracertBtnTag_DoTrace    1002

@interface TracertViewController ()
@property (weak, nonatomic) IBOutlet UITextField *ipTF;
@property (weak, nonatomic) IBOutlet UITextView *traceResTV;
@property (weak, nonatomic) IBOutlet UIButton *traceBtn;
@property (nonatomic,strong) NSTimer *uiTimer;

@property (nonatomic,strong) NSMutableString *traceDetails;

@property (nonatomic,assign) BOOL isEnableICMPTrace;
@property (nonatomic,strong) PNUdpTraceroute *udpTraceroute;

@end

@implementation TracertViewController

- (NSMutableString *)traceDetails
{
    if (!_traceDetails) {
        _traceDetails = [NSMutableString string];
    }
    return _traceDetails;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isEnableICMPTrace = [[NSUserDefaults standardUserDefaults] boolForKey:kISEnableICMPTrace];
    self.title = self.isEnableICMPTrace ? @"ICMP traceroute" : @"UDP traceroute";
    
    NSString *ipaddress = [[NSUserDefaults standardUserDefaults] objectForKey:kTracertIp];
    if (ipaddress != NULL) {
        self.ipTF.text = ipaddress;
    }
    if (_uiTimer == NULL) {
        _uiTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    if (self.isEnableICMPTrace&& [[PhoneNetManager shareInstance] isDoingTraceroute]) {
        [[PhoneNetManager shareInstance] netStopTraceroute];
        self.traceBtn.backgroundColor = QiColor(49, 170, 22);
        [self.traceBtn setTitle:@"Trace" forState:UIControlStateNormal];
    }else if(self.udpTraceroute && self.udpTraceroute.isDoingUdpTraceroute){
        [[PhoneNetManager shareInstance] netStopTraceroute];
        self.traceBtn.backgroundColor = QiColor(49, 170, 22);
        [self.traceBtn setTitle:@"Trace" forState:UIControlStateNormal];
    }
    
    if (_uiTimer) {
        [_uiTimer invalidate];
        _uiTimer = nil;
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    if ([self.ipTF isFirstResponder]) {
        [self.ipTF resignFirstResponder];
    }
}

- (void)updateUI
{
    if (!self.isEnableICMPTrace && self.udpTraceroute) {
        if ([self.udpTraceroute isDoingUdpTraceroute]) {
            self.traceBtn.backgroundColor = [UIColor redColor];
            [self.traceBtn setTitle:@"Stop" forState:UIControlStateNormal];
        }else{
            self.traceBtn.backgroundColor = QiColor(49, 170, 22);
            [self.traceBtn setTitle:@"Trace" forState:UIControlStateNormal];
            self.traceBtn.tag = kTracertBtnTag_NoTrace;
        }
        
        return;
    }
    
    if ([[PhoneNetManager shareInstance] isDoingTraceroute]) {
        self.traceBtn.backgroundColor = [UIColor redColor];
        [self.traceBtn setTitle:@"Stop" forState:UIControlStateNormal];
    }else{
        self.traceBtn.backgroundColor = QiColor(49, 170, 22);
        [self.traceBtn setTitle:@"Trace" forState:UIControlStateNormal];
        self.traceBtn.tag = kTracertBtnTag_NoTrace;
    }
}


- (IBAction)onpressedButtonTrace:(id)sender {
    
    [self hideKeyboard];
    if (self.ipTF.text == NULL || self.ipTF.text.length == 0 || [self.ipTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [self processIpInvalid];
        return;
    }
    
    self.traceBtn.tag = self.traceBtn.tag == kTracertBtnTag_NoTrace ? kTracertBtnTag_DoTrace : kTracertBtnTag_NoTrace;
    int tagValue = (int)self.traceBtn.tag;
    switch (tagValue) {
        case kTracertBtnTag_DoTrace:
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.ipTF.text forKey:kTracertIp];
            
            if (self.traceDetails.length != 0) {
                self.traceDetails = NULL;
            }
            
            NSString *ip = self.ipTF.text;
            __block BOOL isAddBeginDes = NO;
            if (!self.isEnableICMPTrace) {
                _udpTraceroute = [PNUdpTraceroute start:ip complete:^(NSMutableString *res) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.traceResTV.text = res;
                    });
                }];
                return;
            }
            
            
            [[PhoneNetManager shareInstance] netStartTraceroute:ip tracerouteResultHandler:^(NSString * _Nullable tracertRes, NSString * _Nullable destIp) {
                if (!isAddBeginDes) {
                    [self.traceDetails appendString:[NSString stringWithFormat:@"traceroute to %@ \n",destIp]];
                    isAddBeginDes = YES;
                }
                
                [self.traceDetails appendString:tracertRes];
                [self.traceDetails appendString:@"\n"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.traceResTV.text = self.traceDetails;
                });
                
            }];
        }
            break;
        case kTracertBtnTag_NoTrace:
        {
            if (!self.isEnableICMPTrace && self.udpTraceroute) {
                [self.udpTraceroute stopUdpTraceroute];
                return;
            }
            [[PhoneNetManager shareInstance] netStopTraceroute];
        }
            break;
            
        default:
            break;
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
