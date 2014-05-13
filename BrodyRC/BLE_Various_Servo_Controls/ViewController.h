//
//  ViewController.h
//  RC Shark: Brody
//
//  Created by Compagnb
//  Copyright (c) 2014 Barbara Compagnoni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface ViewController : UIViewController <BLEDelegate>{

    float globalRSSI;
    float globalX;
    float globalY;
}

/// BLE Instance
@property (strong, nonatomic) BLE *ble;
@property CBUUID* myUUIB;


///  Interface Elements
//  Text Labels
@property (weak, nonatomic) IBOutlet UILabel *lblRSSI;
//@property (weak, nonatomic) IBOutlet UILabel *lblLogArea;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

//   Switches Actions
- (IBAction)bntConnect:(id)sender;
//- (IBAction)swYTouchesServo1:(id)sender;
//- (IBAction)swXTouchesServo:(id)sender;

//   Switch Properties
//@property (weak, nonatomic) IBOutlet UISwitch *swYTouchPropery;
//@property (weak, nonatomic) IBOutlet UISwitch *swXTouchPropery;


// Buttons
@property (weak, nonatomic) IBOutlet UIButton *btnBite;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;


@end
