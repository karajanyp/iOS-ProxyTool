
#import <Foundation/Foundation.h>

#import "WiFiProxy.h"
#import "SCNetworkHeader.h"

@implementation WiFiProxy

+ (instancetype)sharedInstance {
	static id _instance;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		_instance = [[WiFiProxy alloc]init];
	});
	return _instance;
}

- (void)setProxy:(NSString *)ipaddr port:(NSUInteger)port mode:(int)mode {
	SCPreferencesRef prefRef = SCPreferencesCreate(NULL, CFSTR("set_proxy"), NULL);

	SCPreferencesLock(prefRef, true);

    CFStringRef currentSetPath = SCPreferencesGetValue(prefRef, kSCPrefCurrentSet);

    NSDictionary *currentSet = (__bridge NSDictionary *)SCPreferencesPathGetValue(prefRef, currentSetPath);
   	if (currentSet) {
   		NSDictionary *currentSetServices = currentSet[cfs2nss(kSCCompNetwork)][cfs2nss(kSCCompService)];

	    NSDictionary *services = (__bridge NSDictionary *)SCPreferencesGetValue(prefRef, kSCPrefNetworkServices);

		NSData *data = [NSPropertyListSerialization dataWithPropertyList:services
	                                             format:NSPropertyListBinaryFormat_v1_0
	                                             options:0
	                                        	   error:nil];
	 	NSMutableDictionary *nservices = [NSPropertyListSerialization propertyListWithData:data
	                                  		   options:NSPropertyListMutableContainersAndLeaves
	                                            format:NULL
	                                  			 error:nil];
	    
	    NSString *wifiServiceKey = nil;
	    for (NSString *key in currentSetServices) {
	   		NSDictionary *service = services[key];
	   		NSString *name = service[cfs2nss(kSCPropUserDefinedName)];
	   		if (service && [@"Wi-Fi" isEqualToString: name]) {
	   			wifiServiceKey = key;
		 	
			    NSMutableDictionary *proxies = nservices[wifiServiceKey][(__bridge NSString *)kSCEntNetProxies];
			    
			    [self setProxyInner:ipaddr port:port proxyDict:proxies mode:mode];
	   		}
	    }

	    SCPreferencesSetValue(prefRef, kSCPrefNetworkServices, (__bridge CFPropertyListRef)nservices);
		SCPreferencesCommitChanges(prefRef);
		SCPreferencesApplyChanges(prefRef);
   	} else {
   		NSLog(@"Does not find set for set key:%@", currentSetPath);
   	}
	SCPreferencesUnlock(prefRef);
	CFRelease(prefRef);
}

- (void)setProxyInner:(NSString *)ipaddr port:(NSUInteger)port proxyDict:(NSMutableDictionary *)proxies mode:(int)mode {
	if (mode == 1) {
   		[proxies setObject:@(1) forKey:cfs2nss(kSCPropNetProxiesHTTPEnable)];
        [proxies setObject:ipaddr forKey:cfs2nss(kSCPropNetProxiesHTTPProxy)];
        [proxies setObject:@(port) forKey:cfs2nss(kSCPropNetProxiesHTTPPort)];
        [proxies setObject:@(1) forKey:cfs2nss(kSCPropNetProxiesHTTPSEnable)];
        [proxies setObject:ipaddr forKey:cfs2nss(kSCPropNetProxiesHTTPSProxy)];
        [proxies setObject:@(port) forKey:cfs2nss(kSCPropNetProxiesHTTPSPort)];

        [proxies setObject:@(0) forKey:cfs2nss(kSCPropNetProxiesSOCKSEnable)];
   } else {
   	    [proxies removeAllObjects];
   }
}

@end