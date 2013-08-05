//
//  sc_PendingFilesManagerViewController.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 7/7/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sc_GlobalDataObject.h"
//#import "sc_ReloadableViewProtocol.h"



@interface sc_PendingFilesManagerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate> {

}

@property (nonatomic, retain) IBOutlet UIButton *uploadButton;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) IBOutlet UIButton *removeButton;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property sc_GlobalDataObject *appDataObject;
@end

