//
//  BluetoothConnection.h
//  BluetoothConnectionForPractice
//
//  Created by WatanabeYoichiro on 2015/09/25.
//  Copyright (c) 2015年 YoichiroWatanabe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kTargetDeviceName       @"Bean"

#define kBatteryServiceUUID     @"180F"
#define kBatteryCharUUID        @"2A19"

#define kScratch1ServiceUUID    @"A495FF20-C5B1-4B44-B512-1370F02D74DE"
#define kScratch1CharUUID       @"A495FF21-C5B1-4B44-B512-1370F02D74DE"


@protocol bluetoothNotificationDelegate <NSObject>
//Private delegate Method
-(void)sampleMethod1:(NSString*)scanningState;
@end

@interface BluetoothConnection : NSObject

//Central(= iphone) status
@property(nonatomic)BOOL isCentralBlueToothPoweredOn;
@property(nonatomic)BOOL isCentralScanning;
@property(nonatomic)BOOL isCentralConnectedToPeripheral;

//Peripheral(= bluetooth device) status
@property(nonatomic)int peripheralBatteryLevel;
@property(nonatomic)int peripheralScratch1Data;
@property(nonatomic)NSNumber *peripheralRSSI;

//Delegate instance for bluetooth status
@property(nonatomic,assign)id<bluetoothNotificationDelegate> bltNotification;

//Method
-(void)startScanning;
-(void)stopScanning;
-(void)disconnect;
-(void)disconnectIntrinsic;

-(void)changeScratch1Characteristics:(NSInteger *)state;
-(int)getBluetoothConnectionState;

-(void)callNotificationDelegateMethod:(NSString*)notificationMessage;
@end

//Delegate method
@interface BluetoothConnection() <CBCentralManagerDelegate,CBPeripheralDelegate>{
    CBCentralManager *_centralManager;
    CBPeripheral *_peripheral;
    
    CBUUID *_batteryServiceUUID;
    CBUUID *_batteryServiceCharacteristicsUUID;
    CBUUID *_scratch1ServiceUUID;
    CBUUID *_scratch1ServiceCharacteristicsUUID;

    CBCharacteristic *_batteryServiceCharacteristics;
    CBCharacteristic *_scratch1ServiceCharacteristics;
}

@end