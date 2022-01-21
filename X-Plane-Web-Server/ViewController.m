//
//  ViewController.m
//  X-Plane-Web-Server
//
//  Created by Jean-Baptiste Waring on 2022-01-20.
//

#import "ViewController.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "XPlaneConnectMain.h"
@implementation ViewController
XPlaneConnectMain *xplaneSocket;

- (IBAction)tryToConnectToXPlaneAction:(NSButton *)sender {
    NSLog(@"User Request Connecting to XPlane...");
    const char* IP = "127.0.0.1";
    xplaneSocket = [[XPlaneConnectMain alloc] initwithIP:IP];
    
    if([xplaneSocket isConnectedToXPlane]){
        NSString* xplaneConnectStatusString = @"Success";
        [_xplaneStatusTextField setStringValue:xplaneConnectStatusString];
    }else{
        NSString* xplaneConnectStatusString = @"Failed";
        [_xplaneStatusTextField setStringValue:xplaneConnectStatusString];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    GCDWebServer* webServer = [[GCDWebServer alloc] init];
    
    // Add a handler to respond to GET requests on any URL
    [webServer addDefaultHandlerForMethod:@"GET"
                                   requestClass:[GCDWebServerRequest class]
                                   processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {

               GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithHTML:@"true"];
               [response setValue:@"*" forAdditionalHeader:@"Access-Control-Allow-Origin"];
               [response setValue:@"X-Requested-With, Content-Type" forAdditionalHeader:@"Access-Control-Allow-Headers"];
               [response setValue:@"GET, POST, OPTIONS" forAdditionalHeader:@"Access-Control-Allow-Methods"];
               response.statusCode = 200;
               return response;
           }];
    
    [webServer addHandlerForMethod:@"GET" path:@"/test" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        
        
        
        
        
        
        float xplaneScalarResult = [xplaneSocket getDataRefScalarFloat:@"sim/flightmodel/engine/ENGN_N1_" andSize:8 andElement:0];
        NSLog(@"ENGN N1=%f", xplaneScalarResult);
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setValue:@"sim/flightmodel/engine/ENGN_N1_" forKey:@"dref"];
        [response setValue:[NSNumber numberWithFloat:xplaneScalarResult] forKey:@"value"];
        GCDWebServerDataResponse *responseFromXplane = [GCDWebServerDataResponse responseWithJSONObject: response];
        [responseFromXplane setValue:@"*" forAdditionalHeader:@"Access-Control-Allow-Origin"];
        [responseFromXplane setValue:@"X-Requested-With, Content-Type" forAdditionalHeader:@"Access-Control-Allow-Headers"];
        [responseFromXplane setValue:@"GET, POST, OPTIONS" forAdditionalHeader:@"Access-Control-Allow-Methods"];
        responseFromXplane.statusCode = 200;
        
        return responseFromXplane;
      
    }];

    

    [webServer addDefaultHandlerForMethod:@"OPTIONS"
        requestClass:[GCDWebServerRequest class]
        processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {

            GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithHTML:@"true"];
            [response setValue:@"*" forAdditionalHeader:@"Access-Control-Allow-Origin"];
            [response setValue:@"X-Requested-With, Content-Type" forAdditionalHeader:@"Access-Control-Allow-Headers"];
            [response setValue:@"GET, POST, OPTIONS" forAdditionalHeader:@"Access-Control-Allow-Methods"];
            response.statusCode = 200;
            return response;
        }];
    
    
    
    
    [webServer start];
    NSString *serverStatusTextFieldNSString = [[NSString alloc] initWithFormat:@"Active at: %@", webServer.serverURL];
    [_serverStatusTextField setStringValue:serverStatusTextFieldNSString];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
