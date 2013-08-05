//
//  sc_Upload2ViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/20/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//
#import <ImageIO/CGImageProperties.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "sc_Upload2ViewController.h"
#import "sc_GlobalDataObject.h"
#import "sc_AppDelegateProtocol.h"
#import "sc_ReloadableViewProtocol.h"
#import "sc_Constants.h"
#import "sc_Media.h"
#import <MediaPlayer/MediaPlayer.h>
#import "sc_ViewsHelper.h"
#import "SitecoreMobileSDK/SCApiContext.h"
#import "SitecoreMobileSDK/SCCreateMediaItemRequest.h"
#import "sc_GradientButton.h"
#import "sc_StackArray.h"
#import "sc_UploadItem.h"
#import "sc_ImageHelper.h"
#import "sc_ItemHelper.h"

@interface sc_Upload2ViewController ()
@property (nonatomic)  NSArray *mediaItems;
@property int uploadItemIndex;
@property int uploadedMediaItems;
@property NSMutableArray *cellsArray;
@property sc_StackArray *uploadArray;
@property BOOL isPendingIemsUploading;
@property UIImage *image;
@property BOOL uploadingInterrupted;
@property int uploadImageSize;

@end

@implementation sc_Upload2ViewController
static NSString *CellIdentifier = @"cellSiteUrl";


//--------------------------------------------------------------------------------------------------------
// Helper to return the global data object
//--------------------------------------------------------------------------------------------------------
- (sc_GlobalDataObject*) getAppDataObject; {
    
    id<sc_AppDelegateProtocol> delegate = (id<sc_AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (sc_GlobalDataObject*) delegate.appDataObject;
}

//--------------------------------------------------------------------------------------------------------
// setMediaItems
//--------------------------------------------------------------------------------------------------------
- (void) initWithMediaItems: (NSArray*) mediaItems image:(UIImage*) image isPendingIemsUploading: (BOOL) isPendingIemsUploading {
    _mediaItems = mediaItems;
    _isPendingIemsUploading = isPendingIemsUploading;
    _image = image;
}

//--------------------------------------------------------------------------------------------------------
// initWithNibName
//--------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//--------------------------------------------------------------------------------------------------------
// viewDidLoad
//--------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _uploadImageSize = [sc_ImageHelper loadUploadImageSize];
    
    //Localize UI
    self.navigationItem.title = NSLocalizedString(self.navigationItem.title, nil);
    _doneButton.title=NSLocalizedString(_doneButton.title, nil);
    [_abortButton setTitle:NSLocalizedString(_abortButton.titleLabel.text, nil) forState:UIControlStateNormal];
    
    _appDataObject = [self getAppDataObject];
    
    [self initializeCells];
    
    _doneButton.enabled = false;
    self.navigationItem.hidesBackButton = YES;
    _uploadItemIndex = 0;
    _doneButton.target = self;
    _doneButton.action = @selector(doneButtonPushed:);
    [_abortButton addTarget:self action:@selector(abortButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _uploadingInterrupted = false;

    [(sc_GradientButton*) _abortButton setButtonWithStyle:CUSTOMBUTTONTYPE_DANGEROUS];
    
}

//--------------------------------------------------------------------------------------------------------
// viewDidAppear
//--------------------------------------------------------------------------------------------------------
-(void)viewDidAppear:(BOOL)animated {
    [self startUpload];
}

//--------------------------------------------------------------------------------------------------------
// continue putton pushed
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------------------------------------------------
// done putton pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) doneButtonPushed:(id)sender {
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *chosenView = [viewControllers objectAtIndex:0];
    [self.navigationController popToViewController:chosenView animated:YES];
}

//--------------------------------------------------------------------------------------------------------
// numberOfRowsInSection
//--------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        [sc_ViewsHelper reloadParentController:self.navigationController levels:1];
    }
}

//--------------------------------------------------------------------------------------------------------
// initializeCells
//--------------------------------------------------------------------------------------------------------
- (void) initializeCells {
    _cellsArray = [NSMutableArray arrayWithCapacity:_appDataObject.countOfSelectedForUploadList * _mediaItems.count];
    for ( int x = 0; x < _mediaItems.count; ++x ) {
        for ( int y = 0; y < _appDataObject.selectedForUploadsites.count; ++y ) {
            sc_Media * media = _mediaItems[x];
            UITableViewCell *cell = [self setUploadingCellForMedia:media site: _appDataObject.selectedForUploadsites[y]  cellIdentifier:CellIdentifier cellIndex: _uploadItemIndex++ image:media.thumbnail];
            [_cellsArray addObject:cell];
        }
    }
}

//--------------------------------------------------------------------------------------------------------
// numberOfRowsInSection
//--------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _appDataObject.countOfSelectedForUploadList * _mediaItems.count;
}

//--------------------------------------------------------------------------------------------------------
// setUploadingCell
//--------------------------------------------------------------------------------------------------------
- (UITableViewCell *)setUploadingCellForMedia:(sc_Media*) media site:(sc_Site*) site cellIdentifier:(NSString *)cellIdentifier cellIndex:(NSInteger) cellIndex image: (UIImage*) image {
    
    UITableViewCell *cell = [_sitesTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    UILabel *siteLabel = (UILabel *)[cell viewWithTag:200];
    UILabel *folderLabel = (UILabel *)[cell viewWithTag:300];
    
    [cellImageView setImage:media.thumbnail];
    siteLabel.text = site.siteUrl;
    folderLabel.text = [sc_ItemHelper formatUploadFolder: site];
    cell.tag = 0;
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView startAnimating];
    [cell setAccessoryView:activityView];
    
    return cell;
}

//--------------------------------------------------------------------------------------------------------
// cellForRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _cellsArray[indexPath.row];
}

//--------------------------------------------------------------------------------------------------------
// willDisplayCell
//--------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (cell.tag) {
        case 0:
             cell.backgroundColor = NORMAL_ROW_BG;
            break;
        case 1:
            cell.backgroundColor = UPLOADED_ROW_BG;
            break;
        case 2:
            cell.backgroundColor = ERROR_ROW_BG;
    }
}

//--------------------------------------------------------------------------------------------------------
// canEditRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

//--------------------------------------------------------------------------------------------------------
// setUploadedCell
//--------------------------------------------------------------------------------------------------------
- (void)setUploadedCell:(UITableViewCell *)cell error: (NSError*) error aborted:(BOOL) aborted
{
    if (aborted)
    {
        for (UITableViewCell * cell in _cellsArray) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = NSLocalizedString(@"Cancelled", nil);
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
            cell.backgroundColor = UPLOADED_ROW_BG;
            cell.tag = 2;
        }
    }
    
    UILabel *siteLabel = (UILabel *)[cell viewWithTag:200];
    UILabel *folderLabel = (UILabel *)[cell viewWithTag:300];

    siteLabel.textColor = [UIColor whiteColor];
    folderLabel.textColor = [UIColor whiteColor];
    
    if (error == nil)
    {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteCheckmark.png"]];
        cell.backgroundColor = UPLOADED_ROW_BG;
        cell.tag = 1;
    }
    else {
        cell.detailTextLabel.text = error.localizedDescription;
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
        cell.backgroundColor = ERROR_ROW_BG;
        cell.tag = 2;
    }
    
}

//--------------------------------------------------------------------------------------------------------
// uploadFinished
//--------------------------------------------------------------------------------------------------------
-(void) startUpload {
    _uploadedMediaItems = 0;
    _uploadItemIndex = 0;
    _uploadArray = [[sc_StackArray alloc]init];
    for(int i=0;i<_mediaItems.count;i++) {
        [self uploadMediaItem: i];
    }
}

//--------------------------------------------------------------------------------------------------------
// uploadMediaItem
//--------------------------------------------------------------------------------------------------------
- (void) uploadMediaItem:(int) index {
    
    sc_Media *media = _mediaItems[index];
    //Media file to store
    if (media.imageUrl != nil)
    {
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset){
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            
            UIImageOrientation orientation = UIImageOrientationUp;
            NSNumber* orientationValue = [myasset valueForProperty:@"ALAssetPropertyOrientation"];
            if (orientationValue != nil) {
                orientation = [orientationValue intValue];
            }
            
            UIImage *image = [self normalize:[UIImage imageWithCGImage:[rep fullResolutionImage]] forOrientation:orientation];
            UIImage *resizedImage = [sc_ImageHelper resizeImageToSize:image uploadImageSize:_uploadImageSize];
            NSData *data = UIImageJPEGRepresentation(resizedImage,[sc_ImageHelper getCompressionFactor:_uploadImageSize]);
            
            int siteIndex = 0;
            for (sc_Site* site in _appDataObject.selectedForUploadsites) {
                [self createMediaItem:media site:site data:data index:((index * _appDataObject.countOfSelectedForUploadList) + siteIndex++)];
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
            NSLog(@"Cannot get image - %@",[myerror localizedDescription]);
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:media.imageUrl resultBlock:resultblock failureBlock:failureblock];
    }
    else
        if (media.videoUrl != nil)
        {
            NSData *data = [NSData dataWithContentsOfURL:media.videoUrl];
            int siteIndex = 0;
            for (sc_Site* site in _appDataObject.selectedForUploadsites) {
                [self createMediaItem:media site:site data:data index:((index * _appDataObject.countOfSelectedForUploadList) + siteIndex++)];
            }
        } else {
            NSLog(@"Error: no media url found:");
    }
}

//--------------------------------------------------------------------------------------------------------
// createMediaItem:mediaItem
//--------------------------------------------------------------------------------------------------------
-(void)createMediaItem: (sc_Media*) mediaItem site:(sc_Site*) site data:(NSData*) data index:(int)index
{
    sc_UploadItem * uploadItem = [[sc_UploadItem alloc] initWithObjectData:mediaItem site:site data:data index:index];
    [_uploadArray push:uploadItem];
    
    if ([self uploadingFilesCount] == _uploadArray.count) {
        [self sendUploadRequest:[_uploadArray pop]];
    }
}

//--------------------------------------------------------------------------------------------------------
// sendUploadRequest
//--------------------------------------------------------------------------------------------------------
-(void)sendUploadRequest: (sc_UploadItem *) uploadItem
{
    
    //Creating the API's context
    SCApiContext *context = [sc_ItemHelper getContext: uploadItem.site];
    
    //Assigning media items fields as item's name, item's template etc.
    SCCreateMediaItemRequest *request = [SCCreateMediaItemRequest new];
    request.itemName =  uploadItem.mediaItem.name;
    
    NSString *fileName;
    NSString *itemTemplate;
    NSString *contentType;
    NSURL *assetURL;
    
    //Media file to store
    if (uploadItem.mediaItem.imageUrl != nil)
    {
        fileName =  [NSString stringWithFormat:@"%@.jpeg", uploadItem.mediaItem.name];
        itemTemplate = @"System/Media/Unversioned/Jpeg";
        contentType = @"image/jpeg";
        assetURL = uploadItem.mediaItem.imageUrl;
    }
    else
        if (uploadItem.mediaItem.videoUrl != nil)
        {
            fileName =  [NSString stringWithFormat:@"%@.mov", uploadItem.mediaItem.name];
            itemTemplate = @"System/Media/Unversioned/Video";
            contentType = @"video/mp4";
            assetURL = uploadItem.mediaItem.videoUrl;
            
        } else {
            NSLog(@"Error: no media url found:");
            return;
        }
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset){
        request.fileName = fileName;
        request.itemTemplate = itemTemplate;
        request.mediaItemData = uploadItem.data;
        request.fieldNames = [NSSet new];
        request.contentType = contentType;
        request.folder = uploadItem.site.uploadFolderPathInsideMediaLibrary;
        [context mediaItemCreatorWithRequest:request](^(SCItem *item, NSError *error)
                                                      {
                                                          [self uploadFinished: uploadItem.site mediaItem: uploadItem.mediaItem index:uploadItem.index error: error];
                                                          if (_uploadArray.count > 0) {

                                                              [self sendUploadRequest:[_uploadArray pop]];
                                                          }
                                                      });
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
        NSLog(@"Cannot get image - %@",[myerror localizedDescription]);
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:assetURL resultBlock:resultblock failureBlock:failureblock];
    
}

//--------------------------------------------------------------------------------------------------------
// setHeader
//--------------------------------------------------------------------------------------------------------
- (void)setHeader {
    
    if (_mediaItems.count > 1)
    {
         self.navigationItem.title  = [NSString stringWithFormat:NSLocalizedString(@"Uploading  %d of %lu", nil), _uploadedMediaItems+1, (unsigned long)(_mediaItems.count * _appDataObject.countOfSelectedForUploadList)];
    }
    else
    {
         self.navigationItem.title  = NSLocalizedString(@"Uploading", nil);
    }
}

//--------------------------------------------------------------------------------------------------------
// upload terminated
//--------------------------------------------------------------------------------------------------------
- (void)uploadTerminated {
    
    _doneButton.enabled = true;
    _abortButton.hidden = true;
}

//--------------------------------------------------------------------------------------------------------
// upload finished
//--------------------------------------------------------------------------------------------------------
-(void)uploadFinished:(sc_Site *)site mediaItem:(sc_Media*) mediaItem index:(int) index error:(NSError*) error
{
    if (_uploadingInterrupted)
    {
        return;
    }
    
    UITableViewCell *cell = _cellsArray[index];
        
    [self setUploadedCell:cell error:error aborted:false];
    _uploadedMediaItems++;
    
    mediaItem.status = MEDIASTATUS_UPLOADED;
    
    if (_uploadedMediaItems == [self uploadingFilesCount])
    {
        [_appDataObject saveMediaUpload];
        self.navigationItem.title = NSLocalizedString(@"Uploaded", nil);
        [self uploadTerminated];
    }
    else {
        [self setHeader];
    }
}

//--------------------------------------------------------------------------------------------------------
// uploadimgFilesCount
//--------------------------------------------------------------------------------------------------------
-(int) uploadingFilesCount {
    return _appDataObject.selectedForUploadsites.count * _mediaItems.count;
}

//--------------------------------------------------------------------------------------------------------
// normalize:forOrientation:
//--------------------------------------------------------------------------------------------------------
- (UIImage *)normalize: (UIImage *)image forOrientation:(UIImageOrientation)orientation {
        
    if (orientation == UIImageOrientationUp || orientation == UIImageOrientationUpMirrored) return image;
    
    //Translate and rotate
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown: //1
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft: // 2
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:// 3
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.width);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        case UIImageOrientationUp: // 0
        case UIImageOrientationUpMirrored:
            break;
    }
    
    CGContextRef ctx;
    switch (orientation) {
        case UIImageOrientationRight:
        case UIImageOrientationLeft:
        case UIImageOrientationRightMirrored:
        case UIImageOrientationLeftMirrored:
            
            ctx = CGBitmapContextCreate(NULL, image.size.height, image.size.width,
                                        CGImageGetBitsPerComponent(image.CGImage), 0,
                                        CGImageGetColorSpace(image.CGImage),
                                        CGImageGetBitmapInfo(image.CGImage));
            break;
            
        default:
            ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                        CGImageGetBitsPerComponent(image.CGImage), 0,
                                        CGImageGetColorSpace(image.CGImage),
                                        CGImageGetBitmapInfo(image.CGImage));
            break;
    }
    
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
    
    // Create new image
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);

    return img;
    
}


//--------------------------------------------------------------------------------------------------------
// abort button pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) abortButtonPressed:(id)sender {
    _uploadingInterrupted = false;
    
    self.navigationItem.title = NSLocalizedString(@"Cancelled", nil);
    [self uploadTerminated];
    [self setUploadedCell:NULL error:NULL aborted:true];
    [_sitesTableView reloadData];
    
    // TODO: Interrupt all current Upload request
}


@end
