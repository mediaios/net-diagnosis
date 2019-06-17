//
//  UNetAnalysisConst.h
//  UNetAnalysisSDK
//
//  Created by mediaios on 26/07/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#ifndef PhoneNetSDKConst_h
#define PhoneNetSDKConst_h


/**********   For log4cplus    *************/
#ifndef PhoneNetSDK_IOS
#define PhoneNetSDK_IOS
#endif

/***********  About http Interface   ***********/
#define     PhoneNet_Get_Public_Ip_Url   @"http://ipinfo.io/json"   //get public ip info interface


/***********      Global define       ***********/
#define      PhoneNotification       [NSNotificationCenter defaultCenter]
#define      PhoneNetSDKVersion      @"1.0.8"

/***********      Ping model       ***********/
#define   KPingIcmpIdBeginNum     8000

#endif /* NetAnalysisConst_h */
