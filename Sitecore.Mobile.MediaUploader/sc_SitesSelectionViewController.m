//
//  sc_SitesSelectionViewController.m
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/18/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#import "sc_SitesSelectionViewController.h"
#import "sc_GlobalDataObject.h"
#import "sc_AppDelegateProtocol.h"
#import "sc_BrowseViewController.h"
#import "sc_UploadViewController.h"
#import "sc_Site.h"
#import "sc_Constants.h"
#import "sc_ReloadableViewProtocol.h"
#import "sc_ViewsHelper.h"

@interface sc_SitesSelectionViewController ()

@end

@implementation sc_SitesSelectionViewController
@synthesize sitesTableView = _sitesTableView;
@synthesize appDataObject = _appDataObject;

//--------------------------------------------------------------------------------------------------------
// Helper to return the global data object
//--------------------------------------------------------------------------------------------------------
- (sc_GlobalDataObject*) getAppDataObject; {
    
    id<sc_AppDelegateProtocol> delegate = (id<sc_AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (sc_GlobalDataObject*) delegate.appDataObject;
}

//--------------------------------------------------------------------------------------------------------
// numberOfRowsInSection
//--------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_appDataObject countOfList];
}

//--------------------------------------------------------------------------------------------------------
// willSelectRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath *oldIndex = [_sitesTableView indexPathForSelectedRow];
    [_sitesTableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [_sitesTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    return indexPath;
}

//--------------------------------------------------------------------------------------------------------
// didSelectRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
-(NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    [_sitesTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    return indexPath;
}

//--------------------------------------------------------------------------------------------------------
// didSelectRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self closeView];
}

//--------------------------------------------------------------------------------------------------------
// cellForRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellSiteUrl";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    sc_Site *siteAtIndex = [_appDataObject objectInListAtIndex:indexPath.row];
    [[cell textLabel] setText: siteAtIndex.siteUrl];
    
    [_sitesTableView setAllowsSelection:YES];
    
    _headerLabel.text = NSLocalizedString(@"Select the site you wish to browse.", nil);
    [_sitesTableView setAllowsMultipleSelection:NO];

    if(siteAtIndex.selectedForBrowse){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

//--------------------------------------------------------------------------------------------------------
// canEditRowAtIndexPath
//--------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
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

    _appDataObject = [self getAppDataObject];
    
    [_okButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
}

//--------------------------------------------------------------------------------------------------------
// didReceiveMemoryWarning
//--------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------------------------------------------------
// home button pushed
//--------------------------------------------------------------------------------------------------------
- (IBAction) goBack:(id)sender {
    
    [self closeView];
}

//--------------------------------------------------------------------------------------------------------
// closeView
//--------------------------------------------------------------------------------------------------------
- (IBAction) closeView {
    
    for (NSInteger i = 0; i < [_sitesTableView numberOfRowsInSection:0]; ++i)
    {
        sc_Site *siteAtIndex = [_appDataObject objectInListAtIndex:i];
        
        UITableViewCell *cell = [_sitesTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        siteAtIndex.selectedForBrowse = (cell.isSelected);
    }
    
    [_appDataObject saveSites];
    [sc_ViewsHelper reloadParentController:self.navigationController levels:2];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
