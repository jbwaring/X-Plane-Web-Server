//
//  XPlaneConnectMain.m
//  XPlane-Avionics-Connect
//
//  Created by Jean-Baptiste Waring on 2021-10-13.
//
#ifndef XPlaneConnectMain_m
#define XPlaneConnectMain_m

#import <Foundation/Foundation.h>
#import "XPlaneConnectMain.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "xplaneConnect.h"

@implementation XPlaneConnectMain:NSObject

- (id) initwithIP:(const char*)IP {
    printf("XPlaneConnectMain will try to communicate with XPlane Now.");
    XPlaneConnectMain* myInstance = [[XPlaneConnectMain alloc] init];
    myInstance->sock = openUDP(IP);
    float tVal[1];
    int tSize = 1;
    if (getDREF(myInstance->sock, "sim/test/test_float", tVal, &tSize) < 0)
    {
        printf("Error establishing connecting. Unable to read data from X-Plane.");
        return myInstance;
    }else {
        printf("\nSuccessfuly Talked to XPLANE\n");
    }
    
    return myInstance;
    
}

-(BOOL) isConnectedToXPlane {
    float tVal[1];
    int tSize = 1;
    if (getDREF(sock, "sim/test/test_float", tVal, &tSize) < 0)
    {
//        printf("Error establishing connecting. Unable to read data from X-Plane.");
        return false;
    }
    
    return true;
}

-(float)getDataRefScalarFloat:(NSString *)dataRefIdentifier andSize:(int)sizeOfData andElement:(int)elementNo {
    const char * dataRef = [dataRefIdentifier UTF8String]; //"sim/test/test_float" , "sim/flightmodel/engine/ENGN_tacrad"
    float tVal[sizeOfData]; //sim/flightmodel/engine/ENGN_N1_
    int tSize = sizeOfData;
    getDREF(sock, dataRef , tVal, &tSize);
    float myFloat = tVal[elementNo];
    return myFloat;
}

-(void)sendThrottleCommand:(float)withCommandedThrottle {
    float CTRL[5] = { 0.0 };
    CTRL[3] = withCommandedThrottle/100; // Throttle
    sendCTRL(sock, CTRL, 5, 0);
//    printf("sent trottle command"); 
}


@end


#endif /* XPlaneConnectMain_m */
