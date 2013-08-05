//
//  sc_Upload2ViewController.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/20/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sc_GlobalDataObject.h"

@class sc_SiteDataController;

@interface sc_Upload2ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet NSURL *videoUrl;
@property (nonatomic, retain) IBOutlet NSURL *imageUrl;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *description;
@property (nonatomic, retain) IBOutlet UILabel *location;
@property (nonatomic, retain) IBOutlet UITableView *sitesTableView;
@property (nonatomic, retain) IBOutlet UIButton *abortButton;


@property sc_GlobalDataObject *appDataObject;

- (void) initWithMediaItems: (NSArray*) mediaItems image:(UIImage*) image isPendingIemsUploading: (BOOL) isPendingIemsUploading;

@end
