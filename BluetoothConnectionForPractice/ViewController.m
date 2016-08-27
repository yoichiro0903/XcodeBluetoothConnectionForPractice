//
//  ViewController.m
//  BluetoothConnectionForPractice
//
//  Created by WatanabeYoichiro on 2015/09/25.
//  Copyright (c) 2015年 YoichiroWatanabe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //FingerPrintAuthentification ivar
    _finger = [[FingerPrintAuthentification alloc] init];
    _finger.fingerNotification = self;
    if ([_finger checkFPAuthentificationAvailable]) {
        if ([_finger executeAuthentification]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FingerPrints authentication" message:@"Successed" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Okey" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            
            NSLog(@"%s", "FPAuthentification successed. Here is Viewcontroller");
            
            //BletoothConnection ivar
            _btIns = [[BluetoothConnection alloc] init];
            _btIns.bltNotification = self;
            //    [_btIns callNotificationDelegateMethod];
            //    NSLog(@"%s", "Called delegate method");

        } else {
            //Unavailable FingerPrintAuthentification
            //Failed 3 times in touchIDs
            NSLog(@"%s", "FPAuthentification failed. Here is Viewcontroller");
//            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"FingerPrints authentication" message:@"failed" preferredStyle:UIAlertControllerStyleAlert];
//            [self presentViewController:errorAlert animated:YES completion:nil];
            
            //BletoothConnection ivar
            _btIns = [[BluetoothConnection alloc] init];
            _btIns.bltNotification = self;
            //    [_btIns callNotificationDelegateMethod];
            //    NSLog(@"%s", "Called delegate method");

        }
    } else {
        //FPAuthentificaion is Not Supported
        NSLog(@"%s", "Not supported. Here is ViewContorller");
    }

    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startScanning:(id)sender {
    if (_bluetoothScanSwitch.on == YES) {
        NSLog(@"%s", "Scanning Switch goes ON");
        [_btIns startScanning];
    } else {
        [_btIns disconnectIntrinsic];
        NSLog(@"%s", "Scanning Switch goes OFF");
    }
}

- (IBAction)LEDControl:(id)sender {
    NSInteger state;
    NSLog(@"Tapped segment index is : %ld",(long)_ledControl.selectedSegmentIndex);
    switch (_ledControl.selectedSegmentIndex) {
        case 0:
            //Turn off LED
            state = _ledControl.selectedSegmentIndex;
            [_btIns changeScratch1Characteristics:&state];
            break;
        case 1:
            //Red
            state = _ledControl.selectedSegmentIndex;
            [_btIns changeScratch1Characteristics:&state];
            break;
        case 2:
            //Green
            state = _ledControl.selectedSegmentIndex;
            [_btIns changeScratch1Characteristics:&state];
            break;
        case 3:
            //Blue
            state = _ledControl.selectedSegmentIndex;
            [_btIns changeScratch1Characteristics:&state];
            break;
    }
}

-(void)sampleMethod1:(NSString*)scanningState{
    //    int btConnectionState = _btIns.getBluetoothConnectionState;
    //    if (btConnectionState == 1) {
    //        _bluetoothScanSwitch.enabled = NO;
    //        NSLog(@"Central is Scanning with connection state: %d", btConnectionState);
    //    } else if (btConnectionState == 2){
    //        NSLog(@"Central is Connected with connection state: %d", btConnectionState);
    //        _bluetoothScanSwitch.enabled = YES;
    //    } else {
    //        NSLog(@"Central bluetooth state is unknown with connection state: %d", btConnectionState);
    //        _bluetoothScanSwitch.enabled = YES;
    //    }
    _bltStateLabel.text = scanningState;
    NSLog(@"%s", "Here is ViewController.m. Executed sampleMethod1");
    
}

-(void)sampleDelegate1:(BOOL)success{
    NSLog(@"finger : %d", success);
}

@end
