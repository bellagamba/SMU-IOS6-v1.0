//
//  sc_SiteEditViewController.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 7/26/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sc_Site.h"
#import "sc_GlobalDataObject.h"
#import "sc_ReloadableViewProtocol.h"

@interface sc_SiteEditViewController : UITableViewController <UITextFieldDelegate, sc_ReloadableViewProtocol>
@property (strong, nonatomic) sc_Site *site;
@property (nonatomic, retain) IBOutlet UISwitch *selectedForUploadSwitch;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UILabel *choosenFolderLabel;
@property (nonatomic, retain) IBOutlet UILabel *siteUrlLabel;
@property (nonatomic, retain) IBOutlet UILabel *headerLabelEnabled;
@property (nonatomic, retain) IBOutlet UITableView *siteTableView;

@property sc_GlobalDataObject *appDataObject;

- (IBAction)setUploadMediaFolder:(NSString*) folder withId:(NSString*) folderId;
- (void)setSite:(sc_Site *) newSite isNew:(bool) isNew;
- (IBAction)dismissKeyboardOnTap:(id)sender;

@end
