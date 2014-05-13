//
//  ViewController.m
//  RC Shark: Brody
//
//  Created by Compagnb
//  Copyright (c) 2014 Barbara Compagnoni. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


NSTimer *rssiTimer;



- (void)viewDidLoad
{
    [super viewDidLoad];

    // RedBear Code, to start ble object.
    _ble = [[BLE alloc] init];
    [_ble controlSetup];
    _ble.delegate = self;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SharkJoy"]]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



////////////////////////////////////////
#pragma mark - BLE delegate
////////////////////////////////////////

// Connect button will call to this
- (IBAction)bntConnect:(id)sender
{
    if (_ble.activePeripheral)
        if(_ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[_ble CM] cancelPeripheralConnection:[_ble activePeripheral]];
            //[_lblLogArea setText:@"Trying To Connect"];
            return;
        }
    
    if (_ble.peripherals)
        _ble.peripherals = nil;
    
    [_ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [_spinner startAnimating];
}



-(void) connectionTimer:(NSTimer *)timer

{
    
    
    if (_ble.peripherals.count > 0)
        
        for(int i = 0; i < _ble.peripherals.count; i++)
            
        {
            
            //////////////////////////////////////////////////////////
            
            //  PUT YOUR BLE SHEILD UUID HERE, Check DeBug Log Below For Available UUID's
            
            // example:  @"A1834B4A-CEF2-AD8B-A13F-20616683B36E";
            
            //////////////////////////////////////////////////////////
            
            
            NSString* myBlueSheildUUID = @"9E292D41-A288-32DF-A6CE-F06A2B821E6B";
            
            CBPeripheral *p = [_ble.peripherals objectAtIndex:i];
            
            NSMutableString * pUUIDString = [[NSMutableString alloc] initWithFormat:@"%@",CFUUIDCreateString(NULL, p.UUID) ];
            
            
            
            if ([myBlueSheildUUID isEqualToString:pUUIDString]) {
                
                NSLog(@"\n\n++++++   Found your Perfered Device UUID of: %@\n\n", myBlueSheildUUID);
                
                [_ble connectPeripheral:[_ble.peripherals objectAtIndex:i]];
                
            }
            
            if (![myBlueSheildUUID isEqualToString:pUUIDString]) {
                
                NSLog(@"Found a Bluetooth Device, But doesn't match your UUID \n\n");
                
                
                
            }    }
    
    else
        
    {
        
        
      [_spinner stopAnimating];
        
    }
    
}


///   Called on Connect
-(void) bleDidConnect
{
    //[_lblLogArea setText:@"ble Did Connect"];
    [_spinner stopAnimating];
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    static int localRSSI;
    localRSSI = [rssi intValue];
    
    globalRSSI = (localRSSI * -1)*1.3;
    
    _lblRSSI.text = rssi.stringValue;
    
}

-(void) readRSSITimer:(NSTimer *)timer
{
    [_ble readRSSI];
}

// When disconnected, this will be called
- (void)bleDidDisconnect
{
    //[_lblLogArea setText:@"ble Did Disconnect"];
    [_spinner stopAnimating];
    [_lblRSSI setText:@"Not Connected"];
    
    [rssiTimer invalidate];
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3)
    {
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
     //       if (data[i+1] == 0x01)
    //            swDigitalIn.on = true;
     //       else
      //          swDigitalIn.on = false;
        }
        else if (data[i] == 0x0B)
        {
            UInt16 Value;
            Value = data[i+2] | data[i+1] << 8;
            //[_lblLogArea setText:[NSString stringWithFormat:@"%d", Value]];
        }        
    }
}



////////////////////////////////////////
///  Switches
////////////////////////////////////////


//- (IBAction)swXTouchesServo:(id)sender {
//    if (_swXTouchPropery.on) {
//        NSLog(@"on");
//    }
//    if (!_swXTouchPropery.on) {
//        NSLog(@"off");
//    }
//}
//
//- (IBAction)swYTouchesServo1:(id)sender {
//    if (_swYTouchPropery.on) {
//        NSLog(@"on");
//    }
//    if (!_swYTouchPropery.on) {
//        NSLog(@"off");
//    }
//}

//- (IBAction)swThrowDemo:(id)sender {
//    if (_swArmThrowDemo.on) {
//        [_lblLogArea setText:[NSString stringWithFormat:@"Throw!"]];
//        [self sendValueTortServo:[NSNumber numberWithInt:70]];
//        [self sendValueTolftServo:[NSNumber numberWithInt:150]];
//
//
//    }
//    if (!_swArmThrowDemo.on) {
//        [_lblLogArea setText:[NSString stringWithFormat:@"Load Arm!"]];
//        [self sendValueTortServo:[NSNumber numberWithInt:155]];
//        [self sendValueTolftServo:[NSNumber numberWithInt:70]];
//    }
//}


////////////////////////////////////////
//  Send Servo Value as RSSI Value
// Control Servo Position by RSSI Siganl, or X, Y coords.
////////////////////////////////////////
// rightServo (0)
-(void)sendValueTortServo:(NSNumber*) localValue
{
//    [_lblLogArea setText:@"sendValueToServo called"];
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    
 //   [_lblLogArea setText:[NSString stringWithFormat:@"localValue: %@", localValue]];
    
    
    buf[1] = [localValue floatValue];
    buf[2] = (int)[localValue floatValue] >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [_ble write:data];
}

///leftServo (1)
-(void)sendValueTolftServo:(NSNumber*) localValue
{
    NSLog(@"sendalueToServo");
    UInt8 buf[3] = {0x02, 0x00, 0x00};
    
    buf[1] = [localValue floatValue];
    buf[2] = (int)[localValue floatValue] >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [_ble write:data];
}


////////////////////////////////////////
///  Listen for Touches
////////////////////////////////////////
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
   
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    globalX = location.x / 2;  // scales 0-320 to roughly 0-180
    globalY = location.y / 3.3;  //scales 0-600 to roughly 0-180
    
//    if (_swXTouchPropery.on) {
//        
//        [_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
//        [self sendValueTortServo:[NSNumber numberWithInt:globalX]];
//        [self sendValueTolftServo:[NSNumber numberWithInt:globalX]];
//
//        
//    }
//    
//    if (_swYTouchPropery.on) {
//          [_lblLogArea setText:[NSString stringWithFormat:@"y touch: %f",globalY]];
//        [self sendValueTolftServo:[NSNumber numberWithInt:globalY]];
//        [self sendValueTortServo:[NSNumber numberWithInt:globalY]];
//
//
//   }
//    if ((_swYTouchPropery.on)&&(_swXTouchPropery.on)) {
    
        //    //forward
        if(globalY <= 70){
            [self sendValueTortServo:[NSNumber numberWithInt:0]];
            [self sendValueTolftServo:[NSNumber numberWithInt:180]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"Forwards"]];
        }
        
        //    //backward
        if(globalY >= 110){
            [self sendValueTortServo:[NSNumber numberWithInt:180]];
            [self sendValueTolftServo:[NSNumber numberWithInt:0]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"Backwards"]];
        }
        //
        
        //    //Left
        if(globalX <= 50){
            [self sendValueTortServo:[NSNumber numberWithInt:30]];
            [self sendValueTolftServo:[NSNumber numberWithInt:90]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"Left"]];
        }
        //
        
        //    //Right
        if(globalX >=130){
            [self sendValueTortServo:[NSNumber numberWithInt:90]];
            [self sendValueTolftServo:[NSNumber numberWithInt:150]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"Right"]];
        }
        //
        
        //    //stop
        if((globalY <= 110) && (globalY >= 70)&&(globalX >= 50) && (globalX <=130)){
            [self sendValueTortServo:[NSNumber numberWithInt:90]];
            [self sendValueTolftServo:[NSNumber numberWithInt:90]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
            //[_lblLogArea setText:[NSString stringWithFormat:@"Stop"]];
        }
//    }
    //

//
////    //forward and to the right
//    if(globalX >= 25 && globalY >= 95){
//        [self sendValueTortServo:[NSNumber numberWithInt:90]];
//        [self sendValueTolftServo:[NSNumber numberWithInt:150]];
//        [_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
//        //[_lblLogArea setText:[NSString stringWithFormat:@"y touch: %f",globalY]];
//    }
////    //forward and to the left
//    else if(globalX <= 200 && globalY >= 85){
//        [self sendValueTortServo:[NSNumber numberWithInt:150]];
//        [self sendValueTolftServo:[NSNumber numberWithInt:90]];
//        [_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
//        //[_lblLogArea setText:[NSString stringWithFormat:@"y touch: %f",globalY]];
//    }
////    //backwards and to the right
//    else if(globalX <= 200 && globalY <= 95){
//        [self sendValueTortServo:[NSNumber numberWithInt:20]];
//        [self sendValueTolftServo:[NSNumber numberWithInt:60]];
//        [_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
//        //[_lblLogArea setText:[NSString stringWithFormat:@"y touch: %f",globalY]];
//    }
////    //backwards and to the left
//    else if(globalX >= 25 && globalY <= 85){
//        [self sendValueTortServo:[NSNumber numberWithInt:20]];
//        [self sendValueTolftServo:[NSNumber numberWithInt:80]];
//        [_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
//        //[_lblLogArea setText:[NSString stringWithFormat:@"y touch: %f",globalY]];
//    }
//    else{
//        [self sendValueTortServo:[NSNumber numberWithInt:globalX]];
//        [self sendValueTolftServo:[NSNumber numberWithInt:globalY]];
//        [_lblLogArea setText:[NSString stringWithFormat:@"x touch: %f",globalX]];
//        //[_lblLogArea setText:[NSString stringWithFormat:@"y touch: %f",globalY]];
//    }
    }
@end
