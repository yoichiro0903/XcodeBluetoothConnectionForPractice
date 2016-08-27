//
//  FingerPrintAuthentification.m
//  BluetoothConnectionForPractice
//
//  Created by WatanabeYoichiro on 2015/10/04.
//  Copyright © 2015年 YoichiroWatanabe. All rights reserved.
//

#import "FingerPrintAuthentification.h"
@import LocalAuthentication;


@implementation FingerPrintAuthentification

-(id)init{
    self = [super init];
    if (self) {
        _context = [[LAContext alloc] init];
    }
    NSLog(@"%s", "FingerPrintAuthentification initialize");
    return self;
}

-(BOOL)checkFPAuthentificationAvailable{
    //LAContext *context = [[LAContext alloc] init];
    NSError *error;
    BOOL success;
    
    //whether device is supported by touchID or not, this return BOOL
    //"LAPolicyDeviceOwnerAuthenticationWithBiometrics" means fingerprints authentication
    success = [_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (success) {
        NSLog(@"FPAuthentificaion is Supported");
        return YES;
    } else {
        NSLog(@"FPAuthentificaion is Not Supported");
        return NO;
    }
}

-(BOOL)executeAuthentification{
//    LAContext *context = [[LAContext alloc] init];
    __block BOOL authentification;
    //Show TouchID dialog
    [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Release Lock" reply:^(BOOL success, NSError *authenticationError)
     {
         if (success) {
             NSLog(@"TouchID OK");
             //Notify with delegate method
             authentification = YES;
             [self callFingerDelegate:success];
         } else {
             switch (authenticationError.code) {
                 case LAErrorAuthenticationFailed:
                     //Notify with delegate method
                     NSLog(@"Authentication Failed");
                     authentification = NO;
                     [self callFingerDelegate:success];
                     break;
                 case LAErrorUserCancel:
                     //Notify with delegate method
                     NSLog(@"User pressed Cancel button");
                     authentification = NO;
                     [self callFingerDelegate:success];
                     break;
                 case LAErrorUserFallback:
                     //Notify with delegate method
                     NSLog(@"User pressed \"Enter Password\"");
                     authentification = NO;
                     [self callFingerDelegate:success];
                     break;
                 default:
                     //Notify with delegate method
                     NSLog(@"Touch ID is not configured");
                     authentification = NO;
                     [self callFingerDelegate:success];
                     break;
             }
         }
     }
     ];
    NSLog(@"authentification : %d", authentification);
    return authentification;
}

-(void)callFingerDelegate:(BOOL)success{
    [self.fingerNotification sampleDelegate1:success];
}

@end
