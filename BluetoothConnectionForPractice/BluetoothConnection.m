//
//  BluetoothConnection.m
//  BluetoothConnectionForPractice
//
//  Created by WatanabeYoichiro on 2015/09/25.
//  Copyright (c) 2015年 YoichiroWatanabe. All rights reserved.
//

#import "BluetoothConnection.h"

@implementation BluetoothConnection

#pragma mark - Constructor
//Initialize centralManager, Set variables
-(id)init{
    self = [super init];
    if(self){
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        _batteryServiceUUID = [CBUUID UUIDWithString:kBatteryServiceUUID];
        _batteryServiceCharacteristicsUUID =[CBUUID UUIDWithString:kBatteryCharUUID];

        _scratch1ServiceUUID = [CBUUID UUIDWithString:kScratch1ServiceUUID];
        _scratch1ServiceCharacteristicsUUID = [CBUUID UUIDWithString:kScratch1CharUUID];
    }

    NSLog(@"%@", _centralManager);
    NSLog(@"%@", _batteryServiceUUID);
    NSLog(@"%@", _batteryServiceCharacteristicsUUID);
    NSLog(@"%@", _scratch1ServiceUUID);
    NSLog(@"%@", _scratch1ServiceCharacteristicsUUID);

    return self;
};

#pragma mark - Public methods
//Start scanning for peripherals
-(void)startScanning{
    if (!_isCentralBlueToothPoweredOn || _isCentralScanning) {
        NSLog(@"%s", "Central Bluetooth is OFF, or Central is scannning now");
        return;
    }
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    //Start scanning
    [_centralManager scanForPeripheralsWithServices:nil options:scanOptions];
    self.isCentralScanning = YES;
    
    NSLog(@"%s", "Central started scanning...");
}

//disconnect method (including stopScannning)
-(void)disconnectIntrinsic {
    [self stopScanning];
    
    self.isCentralScanning  = NO;
    self.isCentralConnectedToPeripheral= NO;
    
    _peripheral = nil;
    _batteryServiceCharacteristics = nil;
    _scratch1ServiceCharacteristics = nil;
    
    self.peripheralBatteryLevel = 0;
    self.peripheralScratch1Data = 0;
    self.peripheralRSSI = 0;

    //Notify by delegate method
    [self callNotificationDelegateMethod:@"Central is disconnected : delegate"];

}

//Stop Scanning for peripherals
-(void)stopScanning{
    if (!_isCentralScanning) {
        return;
    }
    [_centralManager stopScan];
    self.isCentralScanning = NO;
}

//Disconnect to peripherals
-(void)disconnect{
    if (_peripheral == nil) {
        return;
    }
    [_centralManager cancelPeripheralConnection:_peripheral];
}

//Find characteristics
-(CBCharacteristic *)findCharacteristics:(NSArray *)cs uuid:(CBUUID *)uuid{
    for (CBCharacteristic *c in cs) {
        if ([c.UUID.data isEqualToData:uuid.data]) {
            return c;
        }
    }
    return nil;
}

#pragma mark CBCentralManagerDelegate //Automatic load?
//Judge Central Bluetooth state
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch ([_centralManager state]) {
        case CBCentralManagerStatePoweredOff:
            self.isCentralBlueToothPoweredOn = NO;
            self.isCentralScanning = NO;
            self.isCentralConnectedToPeripheral = NO;
            break;
        case CBCentralManagerStatePoweredOn:
            self.isCentralBlueToothPoweredOn = YES;
            break;
        case CBCentralManagerStateResetting:
            break;
        case CBCentralManagerStateUnauthorized:
            break;
        case CBCentralManagerStateUnknown:
            break;
        case CBCentralManagerStateUnsupported:
            break;
    }
}


//Discover peripherals
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (_peripheral != nil) {
        NSLog(@"%s","Aready Discovered peripheral.");
        return;
    }
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (localName != nil) {
        _peripheral = peripheral;
        [central connectPeripheral:_peripheral options:nil];
        NSLog(@"%s","Device name is ");
        NSLog(@"%@",localName);
        [self stopScanning];
    } else {
        NSLog(@"%s","Device name is nil.");
        NSLog(@"%@",localName);
        
    }
    
}

//Build connection with peripheral
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    _peripheral.delegate = self;
    self.isCentralConnectedToPeripheral = YES;
    
    //Notify by delegate method
    [self callNotificationDelegateMethod:@"Central is connected : delegate"];
    
    [peripheral discoverServices:[NSArray arrayWithObjects:_batteryServiceUUID, _scratch1ServiceUUID, nil]];
}

//Failed to connect to peripheral
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self disconnectIntrinsic];
}

//Disconnected with peripheral
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self disconnectIntrinsic];
}

#pragma mark CBPeripheralDelegate
//Searching characteristics on service
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        if ([service.UUID.data isEqualToData:_batteryServiceUUID.data]) {
            [peripheral discoverCharacteristics:[NSArray arrayWithObjects:_batteryServiceCharacteristicsUUID, nil] forService:service];
            NSLog(@"%s", "Discovered battery service");
        } else if ([service.UUID.data isEqualToData:_scratch1ServiceUUID.data]){
            [peripheral discoverCharacteristics:[NSArray arrayWithObjects:_scratch1ServiceCharacteristicsUUID, nil] forService:service];
            NSLog(@"%s", "Discovered scratch1 service");
        }
    }
}

//Read value of characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if ([service.UUID.data isEqualToData:_batteryServiceUUID.data]) {
        _batteryServiceCharacteristics = [self findCharacteristics:service.characteristics uuid:_batteryServiceCharacteristicsUUID];
        [peripheral readValueForCharacteristic:_batteryServiceCharacteristics];
        NSLog(@"%s", "Discovered battery characteristics");
    } else if ([service.UUID.data isEqualToData:_scratch1ServiceUUID.data]){
        _scratch1ServiceCharacteristics = [self findCharacteristics:service.characteristics uuid:_scratch1ServiceCharacteristicsUUID];
        [peripheral readValueForCharacteristic:_scratch1ServiceCharacteristics];
        NSLog(@"%s", "Discovered scratch1 characteristics");
    }
}

//Read RSSI value
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    self.peripheralRSSI = peripheral.RSSI;
}

//Read updated characteristics
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    uint8_t b;
    if(characteristic == _batteryServiceCharacteristics){
        [characteristic.value getBytes:&b length:1];
        self.peripheralBatteryLevel = b;
        NSLog(@"%d", self.peripheralBatteryLevel);
    } else if (characteristic == _scratch1ServiceCharacteristics){
        //something...
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"%s","Send data to peripheral");
}

#pragma mark - Private methods
//Send data to peripheral
//Data must be Binary
-(void)changeScratch1Characteristics:(NSInteger *)state{
    NSLog(@"Get state value is : %ld", (long)*state);
    ushort value = *state;
    NSMutableData *data = [NSMutableData dataWithBytes:&value length:2];
    [_peripheral writeValue:data forCharacteristic:_scratch1ServiceCharacteristics type:CBCharacteristicWriteWithResponse];
    NSLog(@"Wrote value of : %d", value);

}
-(int)getBluetoothConnectionState{
    int scanningState;
    if (self.isCentralScanning) {
        scanningState = 1;
        return scanningState;
    } else if (self.isCentralConnectedToPeripheral){
        scanningState = 2;
        return scanningState;
    } else {
        scanningState = 0;
        return scanningState;
    }
}


#pragma mark - Private delegate methods
-(void)callNotificationDelegateMethod:(NSString*)notificationMessage{
    NSString *scanningState = notificationMessage;
    //Check delegate method is exist or not
    if ([self.bltNotification respondsToSelector:@selector(sampleMethod1:)]) {
        [self.bltNotification sampleMethod1:scanningState];
        NSLog(@"sampleMethod1 was called");
    }
}


@end