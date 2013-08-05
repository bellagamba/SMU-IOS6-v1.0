//
//  sc_UploadViewController.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/2/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import "sc_GlobalDataObject.h"
#import "sc_ReloadableViewProtocol.h"
#import <MediaPlayer/MediaPlayer.h>

@interface sc_UploadViewController : UIViewController <UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, CLLocationManagerDelegate, sc_ReloadableViewProtocol>
{
    UIPopoverController *popoverController;
    UIImageView *imageView; 
    BOOL newMedia;
    CLLocationManager *locationManager;
}
@property (nonatomic, retain) IBOutlet UIButton *dismissKeyboardButton;
@property (nonatomic, retain) IBOutlet UIButton *locationButton;
@property (nonatomic, retain) IBOutlet UIButton *imageButton;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *uploadButton;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UILabel *location;
@property (nonatomic, retain) IBOutlet NSURL *videoUrl;
@property (nonatomic, retain) IBOutlet NSURL *imageUrl;
@property (nonatomic, retain) IBOutlet UIView *locationView;

@property sc_GlobalDataObject *appDataObject;

- (IBAction)useCameraRoll: (id)sender;
- (IBAction)dismissKeyboardOnTap:(id)sender;

-(void) reload;
@end
