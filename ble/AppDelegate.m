//
//  AppDelegate.m
//  ble
//
//  Created by Aaron Elkins on 8/21/18.
//  Copyright © 2018 Aaron Elkins. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    uartUUID = [CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];
    rxUUID = [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
    txUUID = [CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
   
}

- (void)scanForPeripherals {
    NSLog(@"Scanning ...");
    NSDictionary *scanningOptions =
    @{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES };
    
    [manager scanForPeripheralsWithServices:nil
                                         options:nil];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"State changed");
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"BLE ready");
            [self scanForPeripherals];
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    NSLog(@"didDiscoverPeripheral: Name: %@", peripheral.name);
    NSLog(@"didDiscoverPeripheral: Advertisment Data: %@", advertisementData);
    NSLog(@"didDiscoverPeripheral: RSSI: %@", RSSI);
    
    connectedPeripheral = peripheral;
    [peripheral setDelegate:self];
    [manager stopScan];
    [manager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnect: %@", peripheral.name);
    [connectedPeripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        if ([service.UUID isEqual:uartUUID]) {
            [connectedPeripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@ UUID:%@", characteristic, characteristic.UUID.UUIDString);
        if ([characteristic.UUID isEqual: txUUID]) {
            NSString *string = @"AAA.";
            NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
            [connectedPeripheral writeValue:data forCharacteristic:characteristic
                                       type:CBCharacteristicWriteWithoutResponse];
        } else if ([characteristic.UUID isEqual:rxUUID]){
            [connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
            if (characteristic.properties == CBCharacteristicPropertyRead){
                [connectedPeripheral readValueForCharacteristic:characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error changing notification state: %@",
              [error localizedDescription]);
        return ;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    if (error) {
        NSLog(@"Error on updating value: %@", [error localizedDescription]);
        return ;
    }
    
    if ([characteristic.UUID isEqual:rxUUID]) {
        NSData *data = characteristic.value;
        NSString* str = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"%@", str);
    }

}
@end
