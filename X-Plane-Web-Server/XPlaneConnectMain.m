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

-(NSDictionary*)getMultipleDREFS:(id)jsonObject {
    
    NSMutableDictionary *bodyAsNSDictionnary = (NSMutableDictionary*)jsonObject;
    NSLog(@"GETTING MULTIPLE DREFS (%ld)", [bodyAsNSDictionnary count]);
    NSLog(@"%@", [jsonObject debugDescription]);
    int numberOfDrefs = (int) [bodyAsNSDictionnary count];
    int index[numberOfDrefs];
    char **dRefs = (char**)malloc((numberOfDrefs + 1) * sizeof(char*));
    char **parentID = (char**)malloc((numberOfDrefs + 1) * sizeof(char*));
    int dRefIterator = 0;
    
    for(id parentKey in bodyAsNSDictionnary){
        id value = [bodyAsNSDictionnary objectForKey:parentKey];
        parentID[dRefIterator] = strdup([parentKey UTF8String]);;
        NSDictionary* dRef = (NSDictionary*)value;
        for(NSString* key in dRef){
            id value = [dRef objectForKey:key];
            NSLog(@"%@ %@", key, value);
            dRefs[dRefIterator] = strdup([key UTF8String]);;
            index[dRefIterator] = [value intValue];
            dRefIterator++;
        }
        dRefs[numberOfDrefs] = NULL;
        
    }

    
    
    float* values[numberOfDrefs];
    
    //number of datarefs being requested.  NOTE: since unsigned char, must be in range [0,255],
    unsigned char count = numberOfDrefs;
    int sizes[numberOfDrefs];
    for( int i = 0; i< numberOfDrefs; i++){
        values[i] = (float*)malloc(32*sizeof(float));
        sizes[i] = 32;
    }
    NSMutableDictionary *dictResponse = [[NSMutableDictionary alloc] init];
     //allocated size of each item in "values"
    if (getDREFs(sock, (const char**)dRefs, values, count, sizes) < 0)
    {
        printf("An error occured."); //negative return value indicates an error
    }
    else
    {

        for(int i = 0; i< numberOfDrefs; i++){
            printf("%s = %f\n", dRefs[i], values[i][index[i]]);//Note the use of a 2D-array notation.
            NSMutableDictionary *childObject = [[NSMutableDictionary alloc] init];
            [childObject setValue:[NSNumber numberWithFloat:values[i][index[i]]] forKey:[[NSString alloc]initWithUTF8String:dRefs[i]]];
            [dictResponse setValue:childObject forKey:[[NSString alloc]initWithUTF8String:parentID[i]]];

        }
      
    }

    
    
    return (NSDictionary*)dictResponse;
}
@end


#endif /* XPlaneConnectMain_m */
