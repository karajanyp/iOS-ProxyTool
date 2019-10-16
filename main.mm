#import <Foundation/Foundation.h>
#import "WiFiProxy.h"

int main(int argc, char **argv, char **envp) {
	WiFiProxy *proxy = [WiFiProxy sharedInstance]; 

	int proxyMode = 0;	//0: no proxy;1: https proxy
	if (argc >= 2) {
		proxyMode = atoi(argv[1]);
	}
	NSString *host = @"192.168.1.111";
	int port = 1111;
	if (argc >= 4) {
		host = [NSString stringWithUTF8String:argv[2]];
		port = atoi(argv[3]);
	}
	
	[proxy setProxy:host port:port mode:proxyMode];

	return 0;
}

