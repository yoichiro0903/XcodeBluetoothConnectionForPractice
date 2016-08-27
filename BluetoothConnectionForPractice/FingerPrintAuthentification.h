//
//  FingerPrintAuthentification.h
//  BluetoothConnectionForPractice
//
//  Created by WatanabeYoichiro on 2015/10/04.
//  Copyright © 2015年 YoichiroWatanabe. All rights reserved.
//

#import <Foundation/Foundation.h>
@import LocalAuthentication;

@protocol fingerAuthentificationDelegate <NSObject>
-(void)sampleDelegate1:(BOOL)success;
@end

@interface FingerPrintAuthentification : NSObject

@property(nonatomic)LAContext *context;
@property(nonatomic,assign) id<fingerAuthentificationDelegate>fingerNotification;

-(id)init;
-(BOOL)checkFPAuthentificationAvailable;
-(BOOL)executeAuthentification;

-(void)callFingerDelegate:(BOOL)success;

@end
