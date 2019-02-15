//
//  UNetAnalysisConst.h
//  UNetAnalysisSDK
//
//  Created by ethan on 26/07/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#ifndef UNetAnalysisConst_h
#define UNetAnalysisConst_h


/**********   For log4cplus    *************/
#ifndef PhoneNetSDK_IOS
#define PhoneNetSDK_IOS
#endif

/***********  About http Interface   ***********/
#define     U_Get_Public_Ip_Url   @"http://ipinfo.io/json"   //get public ip info interface


/***********      Global define       ***********/
#define      PhoneNotification       [NSNotificationCenter defaultCenter]
#define      UCUserDefaults       [NSUserDefaults standardUserDefaults]

/***********      Ping model       ***********/
#define   KPingIcmpIdBeginNum     8000


typedef enum  Enum_Tracert_UC_Hosts_State
{
    Enum_Tracert_UC_Hosts_State_Doing = 0,
    Enum_Tracert_UC_Hosts_State_Complete
}Enum_Tracert_UC_Hosts_State;

#endif /* NetAnalysisConst_h */
