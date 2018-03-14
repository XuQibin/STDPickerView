//
//  STDPickerTableViewController.m
//  STDPickerView
//
//  Created by XuQibin on 2018/3/10.
//  Copyright © 2018年 Standards. All rights reserved.
//

#import "STDPickerTableViewController.h"

#import "STDBasePickerViewController.h"
#import "STDAddressPickerViewController.h"

@interface STDPickerTableViewController ()

@property (assign, nonatomic) BOOL forceItemTypeText;
@property (assign, nonatomic) STDPickerViewSelectionIndicatorStyle style;
@property(assign, nonatomic) BOOL showVerticalDivisionLine;

@property (copy, nonatomic) NSString *selectedNumber;
@property (copy, nonatomic) NSString *selectedAddress;

@end

@implementation STDPickerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _forceItemTypeText = YES;
    _style = STDPickerViewSelectionIndicatorStyleNone;
    _showVerticalDivisionLine = NO;
}

#pragma mark - UISegmentedControl Action
- (IBAction)segmentedSelectedChange:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl.tag == 0) {
        _forceItemTypeText = segmentedControl.selectedSegmentIndex == 0;
    } else if (segmentedControl.tag == 1) {
        _style = segmentedControl.selectedSegmentIndex;
    } else if (segmentedControl.tag == 2) {
        _showVerticalDivisionLine = (BOOL)segmentedControl.selectedSegmentIndex;
    }
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return _selectedNumber != nil ? [NSString stringWithFormat:@"You picked the number (%@)",_selectedNumber] : @"You don't picked any number.";
            
        case 2:
            return _selectedAddress != nil ? [NSString stringWithFormat:@"You picked the address (%@)",_selectedAddress] : @"You don't picked any address.";

        default:
            return @"You can also set more custom apperance through methods in 'STDPickerView.h'";
    }
}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    if (indexPath.section == 1) {
        STDBasePickerViewController *pvc = [[STDBasePickerViewController alloc] init];
        
        pvc.forceItemTypeText = _forceItemTypeText;
        pvc.selectionIndicatorStyle = _style;
        pvc.showVerticalDivisionLine = _showVerticalDivisionLine;
        
        pvc.didSelectText = ^(NSString *selectedText) {
            self.selectedNumber = selectedText;
            [self.tableView reloadData];
        };
        
        [self.navigationController pushViewController:pvc animated:YES];
    } else if (indexPath.section == 2) {
        STDAddressPickerViewController *pvc = [[STDAddressPickerViewController alloc] init];
        
        pvc.forceItemTypeText = _forceItemTypeText;
        pvc.selectionIndicatorStyle = _style;
        pvc.showVerticalDivisionLine = _showVerticalDivisionLine;
        
        pvc.didSelectAddress = ^(NSArray<STDAddressNode *> *selectedAddress, NSString *selectedAddressString) {
            self.selectedAddress = selectedAddressString;
            [self.tableView reloadData];
        };
        
        [self.navigationController pushViewController:pvc animated:YES];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
