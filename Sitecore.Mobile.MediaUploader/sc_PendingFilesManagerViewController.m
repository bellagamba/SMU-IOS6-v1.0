
//
//  sc_PendingFilesManagerViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 7/7/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_PendingFilesManagerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "sc_GlobalDataObject.h"
#import "sc_AppDelegateProtocol.h"
#import "sc_Upload2ViewController.h"
#import "sc_GradientButton.h"
#import "sc_Media.h"
#import "sc_Constants.h"

@interface sc_PendingFilesManagerViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation sc_PendingFilesManagerViewController

//--------------------------------------------------------------------------------------------------------
// buttonAction:button
//--------------------------------------------------------------------------------------------------------
-(IBAction)removeButtonClickEvent:(id)sender event:(id)event {
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];    
    CGPoint currentTouchPosition =[touch locationInView:_collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint: currentTouchPosition];
   [self removeItem:indexPath.item];
}

//--------------------------------------------------------------------------------------------------------
// removeItem
//--------------------------------------------------------------------------------------------------------
-(IBAction)removeItem:(int)index {
    
    ((sc_Media* )[_appDataObject.mediaUpload objectAtIndex:index]).status = MEDIASTATUS_REMOVED;
    [_appDataObject saveMediaUpload];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    _uploadButton.hidden = ([_appDataObject.mediaUpload count] == 0) ? YES : NO;
}

//--------------------------------------------------------------------------------------------------------
// Helper to return the global data object
//--------------------------------------------------------------------------------------------------------
- (sc_GlobalDataObject*) getAppDataObject; {
    
    id<sc_AppDelegateProtocol> delegate = (id<sc_AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (sc_GlobalDataObject*) delegate.appDataObject;
}

//--------------------------------------------------------------------------------------------------------
// collectionView
//--------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [_appDataObject.mediaUpload count];
}

//--------------------------------------------------------------------------------------------------------
// collectionView
//--------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int index=indexPath.item;
    
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    cellImageView.contentMode = UIViewContentModeScaleAspectFill;

    sc_GradientButton * removeButton = (sc_GradientButton *)[cell viewWithTag:2000] ;
    [removeButton setButtonWithStyle:CUSTOMBUTTONTYPE_DANGEROUS];
    [removeButton addTarget:self action:@selector(removeButtonClickEvent:event:) forControlEvents:UIControlEventTouchUpInside];

    //Get image thumbnails
    sc_Media * media= (sc_Media *)[_appDataObject.mediaUpload objectAtIndex:index];
    
    [cellImageView setImage:media.thumbnail];
      
    return cell;
}

//--------------------------------------------------------------------------------------------------------
// prepareForSegue
//--------------------------------------------------------------------------------------------------------
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"uploadPendingMedia"])
    {
        // Obtain handles on the current and destination controllers
        sc_Upload2ViewController * destinationController = (sc_Upload2ViewController * ) segue.destinationViewController;
        [destinationController initWithMediaItems:_appDataObject.mediaUpload image:nil isPendingIemsUploading: true];
    }
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
    
    //Localize UI
    self.navigationItem.title = NSLocalizedString(self.navigationItem.title, nil);
    [_uploadButton setTitle:NSLocalizedString(_uploadButton.titleLabel.text, nil) forState:UIControlStateNormal];

    _appDataObject = [self getAppDataObject];
    [(sc_GradientButton *)_uploadButton setButtonWithStyle:CUSTOMBUTTONTYPE_IMPORTANT];    
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

