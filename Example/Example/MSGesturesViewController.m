//
//  MSDraggingViewController.m
//  Example
//
//  Created by Eric Horacek on 10/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MSGesturesViewController.h"

NSString * const MSGestureDirectionCellReuseIdentifier = @"Gesture Direction Cell";

typedef NS_ENUM(NSInteger, MSGesturesSectionType) {
    MSGesturesSectionTypeDragToReveal,
    MSGesturesSectionTypeTapToClose,
    MSGesturesSectionTypeCount,
};

@implementation MSGesturesViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSGestureDirectionCellReuseIdentifier];
}

#pragma mark - UITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MSGesturesSectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case MSGesturesSectionTypeDragToReveal:
        case MSGesturesSectionTypeTapToClose: {
            MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
            NSInteger possibleDrawerDirection = dynamicsDrawerViewController.possibleDrawerDirection;
            __block NSInteger possibleDirectionCount = 0;
            MSDynamicsDrawerDirectionActionForMaskedValues(possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
                possibleDirectionCount++;
            });
            return possibleDirectionCount;
        }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSGestureDirectionCellReuseIdentifier forIndexPath:indexPath];
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    NSInteger possibleDrawerDirection = dynamicsDrawerViewController.possibleDrawerDirection;
    __block NSInteger possibleDrawerDirectionRow = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
        if (indexPath.row == possibleDrawerDirectionRow) {
            NSString *title;
            switch (drawerDirection) {
                case MSDynamicsDrawerDirectionLeft:
                    title = @"Left";
                    break;
                case MSDynamicsDrawerDirectionRight:
                    title = @"Right";
                    break;
                case MSDynamicsDrawerDirectionTop:
                    title = @"Top";
                    break;
                case MSDynamicsDrawerDirectionBottom:
                    title = @"Bottom";
                    break;
                default:
                    break;
            }
            BOOL gestureEnabled = NO;
            switch (indexPath.section) {
                case MSGesturesSectionTypeDragToReveal:
                    gestureEnabled = [dynamicsDrawerViewController paneDragRevealEnabledForDirection:drawerDirection];
                    break;
                case MSGesturesSectionTypeTapToClose:
                    gestureEnabled = [dynamicsDrawerViewController paneTapToCloseEnabledForDirection:drawerDirection];
                    break;
            }
            cell.textLabel.text = [NSString stringWithFormat:(gestureEnabled ? @"✔︎ %@" : @"✘ %@"), title];
        }
        possibleDrawerDirectionRow++;
    });
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case MSGesturesSectionTypeDragToReveal:
            return @"Pane Drag to Reveal";
        case MSGesturesSectionTypeTapToClose:
            return @"Pane Tap to Close";
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case MSGesturesSectionTypeDragToReveal:
            return @"Setting the 'paneDragRevealEnabled' property to 'NO' prevents the user from dragging the pane to reveal a drawer view controller (in the specified reveal direction).";
        case MSGesturesSectionTypeTapToClose:
            return @"Setting the 'paneTapToCloseEnabled' property to 'NO' prevents the user from tapping anywhere on the pane view to close it when it's currently opened (in the specified reveal direction).";
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    __block NSInteger possibleDrawerDirectionRow = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(dynamicsDrawerViewController.possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
        if (indexPath.row == possibleDrawerDirectionRow) {
            BOOL gestureEnabled = NO;
            switch (indexPath.section) {
                case MSGesturesSectionTypeDragToReveal:
                    gestureEnabled = [dynamicsDrawerViewController paneDragRevealEnabledForDirection:drawerDirection];
                    [dynamicsDrawerViewController setPaneDragRevealEnabled:!gestureEnabled forDirection:drawerDirection];
                    break;
                case MSGesturesSectionTypeTapToClose:
                    gestureEnabled = [dynamicsDrawerViewController paneTapToCloseEnabledForDirection:drawerDirection];
                    [dynamicsDrawerViewController setPaneTapToCloseEnabled:!gestureEnabled forDirection:drawerDirection];
                    break;
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
        possibleDrawerDirectionRow++;
    });
}

@end
