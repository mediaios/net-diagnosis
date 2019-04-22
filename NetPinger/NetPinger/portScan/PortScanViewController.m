//
//  PortScanViewController.m
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PortScanViewController.h"
#import <PhoneNetSDK/PhoneNetSDK.h>
#import "NetPingerConst.h"

#define  kPortScanIp   @"PortScanIP"
#define  kStartPort    @"StartPort"
#define  kEndPort      @"EndPort"
#define  kPortScanBtnTag_Ready  1003
#define  kPortScanBtnTag_Doing    1004

@interface PortScanViewController ()
@property (weak, nonatomic) IBOutlet UITextField *ipTF;
@property (weak, nonatomic) IBOutlet UIButton *portScanBtn;
@property (weak, nonatomic) IBOutlet UITextView *portScaResTV;
@property (weak, nonatomic) IBOutlet UITextField *beginPort;
@property (weak, nonatomic) IBOutlet UITextField *endPort;
@property (weak, nonatomic) IBOutlet UILabel *scaningPortTL;

@property (nonatomic,strong) NSTimer *uiTimer;


@property (nonatomic,strong) NSMutableString *portScanRes;
@end

@implementation PortScanViewController

- (NSMutableString *)portScanRes
{
    if (!_portScanRes) {
        _portScanRes = [NSMutableString string];
    }
    return _portScanRes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
     self.title = @"Port Scan";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:kPortScanIp];
    if (host != NULL) {
        self.ipTF.text = host;
    }
    NSString *startPort = [[NSUserDefaults standardUserDefaults] objectForKey:kStartPort];
    if (startPort) {
        self.beginPort.text = startPort;
    }
    NSString *endPort = [[NSUserDefaults standardUserDefaults] objectForKey:kEndPort];
    if (endPort) {
        self.endPort.text = endPort;
    }
    
    if (_uiTimer == NULL) {
        _uiTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([[PhoneNetManager shareInstance] isDoingPortScan]) {
        [[PhoneNetManager shareInstance] netStopPortScan];
        self.portScanBtn.backgroundColor = QiColor(49, 170, 22);
        [self.portScanBtn setTitle:@"Start" forState:UIControlStateNormal];
    }
    
    if (_uiTimer) {
        [_uiTimer invalidate];
        _uiTimer = nil;
    }
    
}

- (void)updateUI
{
    if ([[PhoneNetManager shareInstance] isDoingPortScan]) {
        self.portScanBtn.backgroundColor = [UIColor redColor];
        [self.portScanBtn setTitle:@"Stop" forState:UIControlStateNormal];
    }else{
        self.portScanBtn.backgroundColor = QiColor(49, 170, 22);
        [self.portScanBtn setTitle:@"Start" forState:UIControlStateNormal];
        self.portScanBtn.tag = kPortScanBtnTag_Ready;
    }
}

- (IBAction)onPressedBtnPortScan:(id)sender {
    [self hideKeyboard];
    if (self.ipTF.text == NULL || self.ipTF.text.length == 0 || [self.ipTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [self processIpInvalid];
        return;
    }
    
    self.portScanBtn.tag = self.portScanBtn.tag == kPortScanBtnTag_Ready ? kPortScanBtnTag_Doing : kPortScanBtnTag_Ready;
    int tagValue = (int)self.portScanBtn.tag;
    switch (tagValue) {
        case kPortScanBtnTag_Doing:
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.ipTF.text forKey:kPortScanIp];
            if (self.beginPort.text.length > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:self.beginPort.text forKey:kStartPort];
            }
            if (self.endPort.text.length > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:self.endPort.text forKey:kEndPort];
            }
            
            if (self.portScanRes.length != 0) {
                self.portScanRes = NULL;
            }
            NSString *host = self.ipTF.text;
            NSUInteger beginScanPort;
            NSUInteger endScanPort;
            beginScanPort = [self.beginPort.text integerValue];
            endScanPort = [self.endPort.text integerValue];
            if (beginScanPort == 0) {
                beginScanPort = 20;
            }
            if (endScanPort == 0) {
                endScanPort = 10000;
            }
            if (beginScanPort > endScanPort) {
                [self showAlertMessage:@"your input port illegal"];
                return;
            }
            
            [[PhoneNetManager shareInstance] netPortScan:host beginPort:beginScanPort endPort:endScanPort completeHandler:^(NSString * _Nullable port, BOOL isOpen, PNError * _Nullable sdkError) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.scaningPortTL.text = port;
                });
                
                if (sdkError) {
                    self.portScanRes = [NSMutableString stringWithString:sdkError.error.description] ;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.portScaResTV.text = self.portScanRes;
                    });
                    return;
                }else{
                    if (isOpen) {
                        [self.portScanRes appendString:[NSString stringWithFormat:@"Open TCP port:  %@",port]];
                        [self.portScanRes appendString:@"\n"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.portScaResTV.text = self.portScanRes;
                        });
                    }
                    
                }
            }];
            
        }
            break;
        case kPortScanBtnTag_Ready:
        {
            [[PhoneNetManager shareInstance] netStopPortScan];
        }
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if ([self.beginPort isFirstResponder]) {
        [self.beginPort resignFirstResponder];
    }
    if ([self.endPort isFirstResponder]) {
        [self.endPort resignFirstResponder];
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

- (void)showAlertMessage:(NSString *)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
