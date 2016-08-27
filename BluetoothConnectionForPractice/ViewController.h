//
//  ViewController.h
//  BluetoothConnectionForPractice
//
//  Created by WatanabeYoichiro on 2015/09/25.
//  Copyright (c) 2015年 YoichiroWatanabe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluetoothConnection.h"
#import "FingerPrintAuthentification.h"

@interface ViewController : UIViewController <bluetoothNotificationDelegate,fingerAuthentificationDelegate>

@property(nonatomic) BluetoothConnection *btIns;
@property(nonatomic) FingerPrintAuthentification *finger;
@property(nonatomic) IBOutlet UISegmentedControl *ledControl;
@property(nonatomic) IBOutlet UISwitch *bluetoothScanSwitch;
@property(nonatomic) IBOutlet UILabel *bltStateLabel;


@end

