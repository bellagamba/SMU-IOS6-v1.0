//
//  sc_QuickImageViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by Steve Jennings on 6/9/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_QuickImageViewController.h"
#import "sc_ItemHelper.h"

@interface sc_QuickImageViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@end

@implementation sc_QuickImageViewController


//--------------------------------------------------------------------------------------------------------
// scrollViewDidScroll
//--------------------------------------------------------------------------------------------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView; {
    
    int currentCell = (int) (scrollView.contentOffset.x / scrollView.frame.size.width +0.5);
    [self setNavBarTitleForIndex:currentCell];
}

//--------------------------------------------------------------------------------------------------------
// setTitle
//--------------------------------------------------------------------------------------------------------
- (void) setNavBarTitleForIndex: (int) index {
    
    self.navigationItem.title = ((SCItem *)[_items objectAtIndex:index]).displayName;
}

//--------------------------------------------------------------------------------------------------------
// collectionView numberOfItemsInSection
//--------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _items.count;
}

//--------------------------------------------------------------------------------------------------------
// viewDidLayoutSubviews
//--------------------------------------------------------------------------------------------------------
- (void)viewDidLayoutSubviews {
    
    //Give default navbar title
    [self setNavBarTitleForIndex:_selectedImage];
    
    //Scroll to the selected image
    [super viewDidLayoutSubviews];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedImage inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
}

//--------------------------------------------------------------------------------------------------------
// collectionView cellForItemAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SCItem * cellObject=[_items objectAtIndex:indexPath.row];
    
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    SCImageView *imageView = (SCImageView *)[cell viewWithTag:100];
    UIActivityIndicatorView * cellActivityView = (UIActivityIndicatorView * ) [cell viewWithTag:33];
    cellActivityView.hidden = NO;
    [imageView setImage:NULL];

    
    // Here, we use the SiteCore SDK to download the image asynchronously (having the ability to cancel
    // is not crucial here, so we can use it). However, for the moment we must use a workaround and
    // concatenate key-value pairs onto the end of the path string in order to get an image of the desired size.
    // The SDK places '.ashx' on the end of the *whole* URL, so to the end of our path string we add '&ignore='.
    // This effectively sidesteps the issue by creating a dummy key-value pair (...&ignore=.ashx) that the server ignores.
     
    int mw = cell.frame.size.width;
    int mh = cell.frame.size.height;
    NSString * db = [sc_ItemHelper getDefaultDatabase];
    NSString * imagePath =[NSString stringWithFormat:@"%@.ashx?db=%@&mw=%d&mh=%d&ignore=", [sc_ItemHelper getPath:cellObject.itemId], db, mw, mh];
    SCAsyncOp imageReader = [_context imageLoaderForSCMediaPath: imagePath];
    imageReader(^(id result, NSError *error)
                {
                    if (error == NULL) {
                        cellActivityView.hidden = YES;
                        [imageView setImage:result];
                    }
                    else
                    {
                        NSLog(@"%@",[error localizedDescription]);
                    }
                }
                );
    return cell;
}

//--------------------------------------------------------------------------------------------------------
// initWithNibName
//--------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//--------------------------------------------------------------------------------------------------------
// pruneItems
//--------------------------------------------------------------------------------------------------------
- (void)pruneItems {
    
    //Remove anything that is not an image from the array
    NSMutableArray *discardedItems = [NSMutableArray array];
  
    SCItem *item;
    for (item in _items) {
        NSString * itemType = [sc_ItemHelper itemType:item];
        if ([itemType isEqualToString:@"folder"])
        {
            [discardedItems addObject:item];
            //Lower the index of the selected picture to compensate for any removed folder at start of array
            _selectedImage--;
        }
        else
        {
            //Folders always come first in the array, so no need to keep testing 
            break;
        }
    }

    [_items removeObjectsInArray:discardedItems];
}

//--------------------------------------------------------------------------------------------------------
// collectionView:didEndDisplayingCell:forItemAtIndexPath:
//--------------------------------------------------------------------------------------------------------
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell = NULL;
}

//--------------------------------------------------------------------------------------------------------
// viewDidLoad
//--------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self pruneItems];
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
