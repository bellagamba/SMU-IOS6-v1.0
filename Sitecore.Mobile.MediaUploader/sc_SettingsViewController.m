//
//  sc_SettingsViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/4/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_GlobalDataObject.h"
#import "sc_AppDelegateProtocol.h"
#import "sc_SettingsViewController.h"
#import "sc_SiteEditViewController.h"
#import "sc_SiteAddViewController.h"
#import "sc_UploadViewController.h"
#import "sc_Site.h"
#import "sc_ViewsHelper.h"
#import "sc_Constants.h"
#import "sc_ImageHelper.h"
#import "sc_ItemHelper.h"

@interface sc_SettingsViewController ()

@end

@implementation sc_SettingsViewController

@synthesize backButton = _backButton;
@synthesize addSiteButton = _addSiteButton;
@synthesize sitesTableView = _sitesTableView;
@synthesize appDataObject = _appDataObject;

//--------------------------------------------------------------------------------------------------------
// reload tableview data
//--------------------------------------------------------------------------------------------------------
-(void) reload {
    
    [_sitesTableView reloadData];
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
    if (self) {
    }
    return self;
}

//--------------------------------------------------------------------------------------------------------
// viewDidLoad
//--------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Localize UI
    self.navigationItem.title = NSLocalizedString(self.navigationItem.title, nil);
    _appDataObject = [self getAppDataObject];
    
    if(_appDataObject.sites.count == 0){
        [sc_ImageHelper saveUploadImageSize:UPLODIMAGESIZE_MEDIUM];
    }
}

//--------------------------------------------------------------------------------------------------------
// numberOfRowsInSection
//--------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        NSArray *viewControllers = [self.navigationController viewControllers];
        UIViewController *previusController = [viewControllers objectAtIndex:viewControllers.count - 1];
        if (![previusController isKindOfClass:[sc_UploadViewController class]]) {
            [sc_ViewsHelper reloadParentController:self.navigationController levels:1];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_appDataObject deleteSite:[_appDataObject.sites objectAtIndex:indexPath.row]];
        [self reload];
    }
}

//--------------------------------------------------------------------------------------------------------
// titleForHeaderInSection
//--------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return NSLocalizedString(@"Sites", nil);
    }
    
    return NSLocalizedString(@"Upload image size", nil);
}

//--------------------------------------------------------------------------------------------------------
// numberOfRowsInSection
//--------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return [_appDataObject countOfList] + 1;
    }
    
    return 1;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

//--------------------------------------------------------------------------------------------------------
// cellForRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UITableViewCell *  cell =  [tableView dequeueReusableCellWithIdentifier:@"ImageSize" forIndexPath:indexPath];
        cell.backgroundView = [UIView new];
        UISegmentedControl *segmentedControl = (UISegmentedControl *)[cell viewWithTag:100];
        [segmentedControl setSelectedSegmentIndex:[sc_ImageHelper loadUploadImageSize]];
        [segmentedControl addTarget:self
                             action:@selector(segmentedControlChanged:)
                   forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == [_appDataObject countOfList]) {
            UITableViewCell *  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AddNewSite"];
            cell.imageView.image = [UIImage imageNamed:@"empty_small.png"];
            cell.textLabel.text = NSLocalizedString(@"Add new site...", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        
        UITableViewCell *  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellSiteUrl"];
        
        sc_Site *siteAtIndex = [_appDataObject objectInListAtIndex:indexPath.row];

        cell.textLabel.lineBreakMode = UILineBreakModeHeadTruncation;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeHeadTruncation;
        cell.textLabel.text = siteAtIndex.siteUrl;
        cell.detailTextLabel.text = [sc_ItemHelper formatUploadFolder: siteAtIndex];
        if (siteAtIndex.selectedForUpdate) {
            cell.imageView.image = [UIImage imageNamed:@"upload_small.png"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"empty_upload_small.png"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    return nil;
}

//--------------------------------------------------------------------------------------------------------
// canEditRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------------------------------------------------
// didSelectRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == [_appDataObject countOfList]) {
            sc_SiteAddViewController *siteAddViewController = (sc_SiteAddViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AddSite"];
            [self.navigationController pushViewController:siteAddViewController animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        sc_SiteEditViewController *siteEditViewController = (sc_SiteEditViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SiteEdit"];
        [siteEditViewController setSite:[_appDataObject objectInListAtIndex:[_sitesTableView indexPathForSelectedRow].row] isNew:false];
        [self.navigationController pushViewController:siteEditViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
// segmentedControlChanged
//--------------------------------------------------------------------------------------------------------
-(IBAction)segmentedControlChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    [sc_ImageHelper saveUploadImageSize:segmentedControl.selectedSegmentIndex];
}

@end
