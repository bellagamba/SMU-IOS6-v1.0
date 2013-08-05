//
//  sc_SitesSelectionViewController.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/18/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sc_GlobalDataObject.h"
#import "sc_ReloadableViewProtocol.h"


@interface sc_SitesSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) IBOutlet UITableView *sitesTableView;
@property (nonatomic, retain) IBOutlet UIButton *okButton;
@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property sc_GlobalDataObject *appDataObject;
@property  NSString *selectionType;
@end
