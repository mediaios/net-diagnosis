//
//  LookupViewController.m
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "LookupViewController.h"
#import <PhoneNetSDK/PhoneNetSDK.h>

#define kLookupHost   @"lookupHost"
@interface LookupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *hostTF;
@property (weak, nonatomic) IBOutlet UITextView *lookupResTV;

@end

@implementation LookupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Lookup";
    
    NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:kLookupHost];
    if (host) {
        self.hostTF.text = host;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hideKeyBoard];
}

- (IBAction)onpressedBtnLookup:(id)sender {
    [self hideKeyBoard];
    if (self.lookupResTV.text.length != 0) {
        self.lookupResTV.text = @"";
    }
    if (self.hostTF.text == NULL || self.hostTF.text.length == 0 ||
        [self.hostTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [self processIpInvalid];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.hostTF.text forKey:kLookupHost];
    
    
    [[PhoneNetManager shareInstance] netLookupDomain:self.hostTF.text completeHandler:^(NSMutableArray<DomainLookUpRes *> * _Nullable lookupRes, PNError * _Nullable sdkError) {
        if (sdkError) {
            self.lookupResTV.text = sdkError.error.description;
            return;
        }
        NSMutableString *res  = [NSMutableString string];
        for (DomainLookUpRes *lookup in lookupRes) {
            [res appendString:[NSString stringWithFormat:@"%@ -> %@",lookup.name,lookup.ip]];
            [res appendString:@"\n"];
        }
        self.lookupResTV.text = res;
    }];
}

- (void)hideKeyBoard
{
    if ([self.hostTF isFirstResponder]) {
        [self.hostTF resignFirstResponder];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
