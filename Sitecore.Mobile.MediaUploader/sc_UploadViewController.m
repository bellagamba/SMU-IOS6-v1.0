//
//  sc_UploadViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/2/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <ImageIO/CGImageProperties.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "sc_GlobalDataObject.h"
#import "sc_AppDelegateProtocol.h"
#import "sc_UploadViewController.h"
#import "sc_Upload2ViewController.h"
#import "sc_SitesSelectionViewController.h"
#import "sc_Site.h"
#import "sc_Constants.h"
#import <MediaPlayer/MediaPlayer.h>
#import "sc_Media.h"
#import "sc_GradientButton.h"
#import "sc_ActivityIndicator.h"
#import "sc_Validator.h"
#import "sc_ImageHelper.h"
#import "sc_ItemHelper.h"

@interface sc_UploadViewController ()
@property CLLocation *currentLocation;
@property UIImage *thumbnail;
@property UIImagePickerController *imagePicker;
@property bool autoImagePickerLoadExecuted;
@property sc_ActivityIndicator * activityIndicator;

@end

@implementation sc_UploadViewController
@synthesize imageView, popoverController;

//--------------------------------------------------------------------------------------------------------
// viewWillDisappear
//--------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    
    //Remove popup, if present, for when popping back to root controller
    [self.popoverController dismissPopoverAnimated:NO];    
}

//--------------------------------------------------------------------------------------------------------
// reload selected site for browse
//--------------------------------------------------------------------------------------------------------
-(void) reload {
    
    [imageView setImage: nil];
    _name.text = @"";
    _location.text = NSLocalizedString(@"Location undefined", nil);
    _appDataObject.selectedPlaceMark = nil;
    [self hideUploadForm: true];
    _autoImagePickerLoadExecuted = false;
}

//--------------------------------------------------------------------------------------------------------
// Helper to return the global data object
//--------------------------------------------------------------------------------------------------------
- (sc_GlobalDataObject*) getAppDataObject; {
    
    id<sc_AppDelegateProtocol> delegate = (id<sc_AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (sc_GlobalDataObject*) delegate.appDataObject;
}

//--------------------------------------------------------------------------------------------------------
// initWithNibName
//--------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

//--------------------------------------------------------------------------------------------------------
// viewDidLoad
//--------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Localize UI
    self.navigationItem.title = NSLocalizedString(self.navigationItem.title, nil);
    _name.placeholder = NSLocalizedString(_name.placeholder, nil);
    [_uploadButton setTitle:NSLocalizedString(_uploadButton.titleLabel.text, nil) forState:UIControlStateNormal];
    [_saveButton setTitle:NSLocalizedString(_saveButton.titleLabel.text, nil) forState:UIControlStateNormal];
    
    if(_appDataObject.isOnline)
    {
        //Try to get current location as soon as view has loaded
        [self getCurrentLocation];
    }

    _appDataObject = [self getAppDataObject];
    _autoImagePickerLoadExecuted = false;
    [self reload];
    [_imageButton addTarget:self action:@selector(useCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    _name.delegate = self;
    
    [(sc_GradientButton*) _saveButton setButtonWithStyle:CUSTOMBUTTONTYPE_NORMAL];
    [(sc_GradientButton*) _imageButton setButtonWithStyle:CUSTOMBUTTONTYPE_TRANSPARENT];
    [(sc_GradientButton*) _uploadButton setButtonWithStyle:CUSTOMBUTTONTYPE_IMPORTANT];
    [(sc_GradientButton*) _locationButton setButtonWithStyle:CUSTOMBUTTONTYPE_NORMAL];
    
    [_locationView setBackgroundColor:LABEL_BG];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _dismissKeyboardButton.hidden = true;
}

//--------------------------------------------------------------------------------------------------------
// viewDidAppear
//--------------------------------------------------------------------------------------------------------
-(void)viewDidAppear:(BOOL)animated {
    
    _location.text = [sc_ImageHelper formatLocation:_appDataObject.selectedPlaceMark];
    
    if (_appDataObject.isOnline) {
        _uploadButton.hidden = false;
        _locationButton.hidden = false;
    }
    else {
        _uploadButton.hidden = true;
        _locationButton.hidden = true;
    }
    
    if (!_autoImagePickerLoadExecuted) {
        [self useCameraRoll:NULL];
        _autoImagePickerLoadExecuted = true;
    }
}

//--------------------------------------------------------------------------------------------------------
// locationManager:didFailWithError
//--------------------------------------------------------------------------------------------------------
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    //TODO: handle failure
    [locationManager stopUpdatingLocation];
}

//--------------------------------------------------------------------------------------------------------
// getCurrentLocation
//--------------------------------------------------------------------------------------------------------
- (void)getCurrentLocation {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    _currentLocation = [locationManager location];
    
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------------------------------------------------
// useCameraRoll
//--------------------------------------------------------------------------------------------------------
- (IBAction) useCameraRoll: (id)sender {
    if (!_appDataObject.isIpad) {
        // Iphone code
        if (self.popoverController == nil)
        {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                _imagePicker = [[UIImagePickerController alloc] init];
                _imagePicker.delegate = self;
                _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSArray *mediaTypesAllowed = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [_imagePicker setMediaTypes:mediaTypesAllowed];

                _imagePicker.allowsEditing = NO;
                [self presentModalViewController:_imagePicker animated:YES];
            }
            
            newMedia = NO;
            return;
        }
    }
    
    if ([self.popoverController isPopoverVisible]) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else
    {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            _imagePicker = [[UIImagePickerController alloc] init];
            _imagePicker.delegate = self;
            _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSArray *mediaTypesAllowed = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [_imagePicker setMediaTypes:mediaTypesAllowed];

            _imagePicker.allowsEditing = NO;
            
            _imagePicker.wantsFullScreenLayout = YES;
            
            self.popoverController = [[UIPopoverController alloc]
                                      initWithContentViewController:_imagePicker];
            
            popoverController.delegate = self;
            CGRect tRect = CGRectMake(0, 270, 768, 10);

            
            [self.popoverController
             presentPopoverFromRect: tRect
             inView: self.view
             permittedArrowDirections:UIPopoverArrowDirectionAny
             animated:YES];
    
        }
        newMedia = NO;
    }
}

//--------------------------------------------------------------------------------------------------------
// getReadableLocation
//--------------------------------------------------------------------------------------------------------
-(void)getReadableLocation:(CLLocation *)location {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                       
                       if (error){
                           _appDataObject.selectedPlaceMark = nil;
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       
                       if (placemarks.count > 0) {
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           _appDataObject.selectedPlaceMark = placemark;
                       }
                       else {
                           _appDataObject.selectedPlaceMark = nil;
                       }
                       
                       _location.text = [sc_ImageHelper formatLocation:_appDataObject.selectedPlaceMark];
                   }];
}

//--------------------------------------------------------------------------------------------------------
// dismissKeyboardOnTap
//--------------------------------------------------------------------------------------------------------
-(IBAction)dismissKeyboardOnTap:(id)sender
{
    [[self view] endEditing:YES];
}

//--------------------------------------------------------------------------------------------------------
// imagePickerController
//--------------------------------------------------------------------------------------------------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self.popoverController dismissPopoverAnimated:true];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    [self hideUploadForm:false];
    
    // IMAGE
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [imageView setImage: image];
     
        _videoUrl = nil;
        
        if (newMedia)
        {
            if (!_appDataObject.isOnline)
            {
                [self getReadableLocation:_currentLocation];
            }
            
            NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
            
            // Handle a still image capture
            if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)== kCFCompareEqualTo) {
                
                UIImage *imageToSave = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
                
                // Get the image metadata
                UIImagePickerControllerSourceType pickerType = picker.sourceType;
                if(pickerType == UIImagePickerControllerSourceTypeCamera)
                {
                    NSMutableDictionary *imageMetadata = [info objectForKey: UIImagePickerControllerMediaMetadata];
                    
                    [imageMetadata setObject:[self gpsDictionaryForLocation:_currentLocation] forKey:(NSString*)kCGImagePropertyGPSDictionary];
                    
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock;
                    
                    // Get the assets library
                    imageWriteCompletionBlock =
                    ^(NSURL *newURL, NSError *error) {
                        if (error) {
                            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
                        } else {
                            NSLog( @"Wrote image with metadata to Photo Library");
                            _imageUrl = newURL;
                        }
                        
                        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
                            CGImageRef iref = [myasset thumbnail];
                            if (iref) {
                                _thumbnail = [UIImage imageWithCGImage:iref];
                            }
                        };
                        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror) {
                            NSLog(@"cant get image - %@", [myerror localizedDescription]);
                        };
                        
                        
                        [library assetForURL:_imageUrl resultBlock:resultblock failureBlock:failureblock];
                        
                        [self dismissViewControllerAnimated:YES completion:nil];
                    };
                    
                    // Save the new image to the Camera Roll
                    [library writeImageToSavedPhotosAlbum:[imageToSave CGImage] 
                                                 metadata:imageMetadata 
                                          completionBlock:imageWriteCompletionBlock];
                    
                }
            }
        }
        else
        {
            // NOT NEW MEDIA

            //Extract metadata
            NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
            if (url) {
                
                _imageUrl = url;
                ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
                ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
                    CLLocation *location = [myasset valueForProperty:ALAssetPropertyLocation];
                    [self getReadableLocation:location];
                    
                    CGImageRef iref = [myasset thumbnail];
                    if (iref) {
                        _thumbnail = [UIImage imageWithCGImage:iref];
                    }
                };
                ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror) {
                    NSLog(@"cant get image - %@", [myerror localizedDescription]);
                };
                
                
                [assetsLib assetForURL:url resultBlock:resultblock failureBlock:failureblock];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    // VIDEO
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {

        _imageUrl = nil;
        _videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [_videoUrl path];

        if (newMedia)
        {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum (moviePath, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
            }
            
            if(!_appDataObject.isOnline)
            {
                [self getReadableLocation:_currentLocation];
            }
        }

        [self dismissViewControllerAnimated:YES completion:nil];
        
        _thumbnail = [sc_ImageHelper getVideoThumbnail:_videoUrl];
        [imageView setImage: _thumbnail];
    }
}

//--------------------------------------------------------------------------------------------------------
// movieFinishedCallback
//--------------------------------------------------------------------------------------------------------
    - (void)moviePlayBackDidFinish:(NSNotification *)notification {
}

//--------------------------------------------------------------------------------------------------------
// image manager
//--------------------------------------------------------------------------------------------------------
-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"Save failed", nil)
                              message: NSLocalizedString(@"Failed to save media item", nil)\
                              delegate: nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
        [alert show];
    }
}

//--------------------------------------------------------------------------------------------------------
// imagePickerControllerDidCancel
//--------------------------------------------------------------------------------------------------------
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // here it's arriving from camera cancel
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        newMedia = NO;
    }
}

//--------------------------------------------------------------------------------------------------------
// textFieldShouldReturn
//--------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//--------------------------------------------------------------------------------------------------------
// back button pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//--------------------------------------------------------------------------------------------------------
// save button pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) save:(id)sender {
     [self saveFileAsPending];
}

//--------------------------------------------------------------------------------------------------------
// prepareForSegue
//--------------------------------------------------------------------------------------------------------
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"upload2"])
    {
        [self initializeActivityIndicator];
        [_activityIndicator showWithLabel:@"Preparing media"];
        
        sc_Media *media = [[sc_Media alloc] initWithObjectData: _name.text location: _location.text videoUrl:_videoUrl imageUrl:_imageUrl  status: MEDIASTATUS_PENDING thumbnail:_thumbnail];
        [self setMediaItemValidName:media];
  
        sc_Upload2ViewController * destinationController = (sc_Upload2ViewController * ) segue.destinationViewController;
            
        NSArray *mediaItems = @[media];
        [destinationController initWithMediaItems:mediaItems image:imageView.image isPendingIemsUploading: false];
         [_activityIndicator hide];
    }
}

//--------------------------------------------------------------------------------------------------------
// save File as pending
//--------------------------------------------------------------------------------------------------------
- (void)saveFileAsPending
{
    sc_Media *media = [[sc_Media alloc] initWithObjectData: _name.text location: _location.text videoUrl:_videoUrl imageUrl:_imageUrl status: MEDIASTATUS_PENDING thumbnail:_thumbnail];
    [self setMediaItemValidName:media];
    
    [_appDataObject addMediaUpload:media];
    [_appDataObject saveMediaUpload];
    
    [self.navigationController popViewControllerAnimated:YES ];
}

//--------------------------------------------------------------------------------------------------------
// set MediaItem valid name
//--------------------------------------------------------------------------------------------------------
-(void)setMediaItemValidName: (sc_Media *) media {
    
    NSString *validName;
    
        if (media.videoUrl != nil)
        {
            validName = @"Video";
        }
        else  {
            validName = @"Image";
        }

    media.name = [sc_Validator proposeValidItemName:media.name withDefault:[sc_ItemHelper generateItemName:validName]];

}

//--------------------------------------------------------------------------------------------------------
// shouldPerformSegueWithIdentifier
//--------------------------------------------------------------------------------------------------------
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"upload2"])
    {
        if (!_appDataObject.isOnline)
        {
            [self saveFileAsPending];
            
            return NO;
        }
    }
    return YES;
}

//--------------------------------------------------------------------------------------------------------
// didUpdateToLocation
//--------------------------------------------------------------------------------------------------------
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [locationManager stopUpdatingLocation];
}

//--------------------------------------------------------------------------------------------------------
// gpsDictionaryForLocation
//--------------------------------------------------------------------------------------------------------
- (NSDictionary *) gpsDictionaryForLocation:(CLLocation *)location
{
    //Helper to create a dictionary of geodata to be incorporate into photo metadata
    CLLocationDegrees exifLatitude  = location.coordinate.latitude;
    CLLocationDegrees exifLongitude = location.coordinate.longitude;
    
    NSString * latRef;
    NSString * longRef;
    if (exifLatitude < 0.0) {
        exifLatitude = exifLatitude * -1.0f;
        latRef = @"S";
    } else {
        latRef = @"N";
    }
    
    if (exifLongitude < 0.0) {
        exifLongitude = exifLongitude * -1.0f;
        longRef = @"W";
    } else {
        longRef = @"E";
    }
    
    NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
    
    [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    [locDict setObject:longRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    [locDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
    [locDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    
    return locDict;
}

//--------------------------------------------------------------------------------------------------------
// willShowViewController
//--------------------------------------------------------------------------------------------------------
- (void) navigationController: (UINavigationController *) navigationController  willShowViewController: (UIViewController *) viewController animated: (BOOL) animated
{
    if (_imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
        if ([NSStringFromClass([viewController class]) isEqualToString: @"PLUILibraryViewController"])
        {
            if (!_appDataObject.isIpad) {
               viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            }
        
        }
    }
}

//--------------------------------------------------------------------------------------------------------
// cancel
//--------------------------------------------------------------------------------------------------------
- (void) cancel: (id) sender {

    if (imageView.image == NULL)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//--------------------------------------------------------------------------------------------------------
// showCamera
//--------------------------------------------------------------------------------------------------------
- (void) showCamera: (id) sender {
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray *mediaTypesAllowed = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [_imagePicker setMediaTypes:mediaTypesAllowed];
        _imagePicker.allowsEditing = NO;
        
        newMedia = YES;
    }
}

//--------------------------------------------------------------------------------------------------------
// initializeActivityIndicator
//--------------------------------------------------------------------------------------------------------
- (void)initializeActivityIndicator {
    _activityIndicator = [[sc_ActivityIndicator alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_activityIndicator];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.view window]){
        _dismissKeyboardButton.hidden = false;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([self.view window]){
         _dismissKeyboardButton.hidden = true;
    }
}

//--------------------------------------------------------------------------------------------------------
// showError
//--------------------------------------------------------------------------------------------------------
-(void) showError:(NSString*) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message: message delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show];
    [alert show];
}

//--------------------------------------------------------------------------------------------------------
// hideUploadForm
//--------------------------------------------------------------------------------------------------------
-(void) hideUploadForm:(bool) status {
    _uploadButton.hidden = status;
    _saveButton.hidden = status;
    _locationView.hidden = status;
    _name.hidden = status;
}
@end
