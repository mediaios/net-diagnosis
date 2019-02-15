#ifndef _LOG4CPLUS_H_
#define _LOG4CPLUS_H_

#endif //  WIN32

#if (defined (_MSC_VER) && _MSC_VER >= 1900) || (defined(__cplusplus) && __cplusplus>= 201103L)
#define __STDC_FORMAT_MACROS
#include <cinttypes>
#endif

#define LOG4CPLUS_DISABLE_DLL_RUNTIME_WARNING
#define LOG4CPLUS_STATIC

#ifdef PhoneNetSDK_IOS
    #include <syslog.h>

    extern int PhoneNetSDK_IOS_LOG_LEVEL;
    extern int PhoneNetSDK_IOS_FLAG_FATAL;
    extern int PhoneNetSDK_IOS_FLAG_ERROR;
    extern int PhoneNetSDK_IOS_FLAG_WARN;
    extern int PhoneNetSDK_IOS_FLAG_INFO;
    extern int PhoneNetSDK_IOS_FLAG_DEBUG;
class PhoneNetSDKLog{
public:
        static void Init(void * configuration = NULL){}
	static void Destroy(){}
};

#define log4cplus_fatal(category, logFmt, ...) \
do { \
    if(PhoneNetSDK_IOS_LOG_LEVEL & PhoneNetSDK_IOS_FLAG_FATAL) \
        syslog(LOG_CRIT, "%s:" logFmt, #category,##__VA_ARGS__); \
}while(0)

#define log4cplus_error(category, logFmt, ...) \
do { \
    if(PhoneNetSDK_IOS_LOG_LEVEL & PhoneNetSDK_IOS_FLAG_ERROR) \
        syslog(LOG_ERR, "%s:" logFmt, #category,##__VA_ARGS__); \
}while(0)

#define log4cplus_warn(category, logFmt, ...) \
do { \
    if(PhoneNetSDK_IOS_LOG_LEVEL & PhoneNetSDK_IOS_FLAG_WARN) \
        syslog(LOG_WARNING, "%s:" logFmt, #category,##__VA_ARGS__); \
}while(0)

#define log4cplus_info(category, logFmt, ...) \
do { \
    if(PhoneNetSDK_IOS_LOG_LEVEL & PhoneNetSDK_IOS_FLAG_INFO) \
        syslog(LOG_WARNING, "%s:" logFmt, #category,##__VA_ARGS__); \
}while(0)

#define log4cplus_debug(category, logFmt, ...) \
do { \
    if(PhoneNetSDK_IOS_LOG_LEVEL & PhoneNetSDK_IOS_FLAG_DEBUG) \
        syslog(LOG_WARNING, "%s:" logFmt, #category,##__VA_ARGS__); \
}while(0)

inline void log4cplus_init(const char* configuration = NULL){
    openlog("TVUTransporterT", LOG_NDELAY|LOG_PID|LOG_CONS, LOG_USER);
}

inline void log4cplus_destroy(){
    closelog();
}


#endif

