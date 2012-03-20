//
//  FUNTableView.m
//  perimeter
//
//  Created by M. Robert Spryn on 7/22/11.
//  Copyright 2011 PowerPro. All rights reserved.
//
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "FUNTableView.h"

CGRect XYWidthHeightRectSwap(CGRect rect);
CGRect FixOriginRotation(CGRect rect, UIInterfaceOrientation orientation, int parentWidth, int parentHeight);


@interface FUNTableView()
@end

@implementation FUNTableView

@synthesize topMostRowBeforeKeyBoardWasShown, originalFrame;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    self.topMostRowBeforeKeyBoardWasShown = nil;
    [super dealloc];
}

- (void)adjustTableViewForKeyboardwithCell:(UITableViewCell *)cell userInformation:(NSDictionary *)userInfo
{
    
    if ([self indexPathsForVisibleRows].count) {
		NSIndexPath *indexPath = (NSIndexPath*)[[self indexPathsForVisibleRows] objectAtIndex:0];
        self.topMostRowBeforeKeyBoardWasShown = indexPath;
	} 
    
    NSValue* keyboardFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    id *appDelegate = [[UIApplication sharedApplication] delegate];
    // Reduce the tableView height by the part of the keyboard that actually covers the tableView
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect windowRect = appDelegate.window.bounds;
    CGRect viewRectAbsolute = [self convertRect:self.bounds toView:nil];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    if (UIInterfaceOrientationLandscapeLeft == orientation ||UIInterfaceOrientationLandscapeRight == orientation ) {
        windowRect = XYWidthHeightRectSwap(windowRect);
        viewRectAbsolute = XYWidthHeightRectSwap(viewRectAbsolute);
        keyboardFrame = XYWidthHeightRectSwap(keyboardFrame);
    }
    // fix the coordinates of our rect to have a top left origin 0,0
    viewRectAbsolute = FixOriginRotation(viewRectAbsolute, orientation, windowRect.size.width, windowRect.size.height);
    
    CGRect frame = self.frame;
    // store the value on the table for later
    self.originalFrame = frame;
    
    int remainder = (viewRectAbsolute.origin.y + viewRectAbsolute.size.height + keyboardFrame.size.height) - windowRect.size.height;
    if (remainder > 0 && !(remainder > frame.size.height + 50)) {
        frame.size.height = frame.size.height - remainder;
        float duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration: duration
                         animations:^{
                             self.frame = frame;
                         }
                         completion:^(BOOL finished){
                             if (cell) {
                                 NSIndexPath *textFieldIndexPath = [self indexPathForCell:cell];
                                 [self scrollToRowAtIndexPath:textFieldIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                             }
                         }];
    }
}

- (void)adjustTableViewNoKeyboardWithUserInformation:(NSDictionary *)userInfo scrollToOriginalCell:(BOOL)shouldScroll
{
    float duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // update the frame with the old size
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.originalFrame.size.width, self.originalFrame.size.height);
    
    [UIView animateWithDuration: duration
                          delay: 0.0
                        options: (UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         self.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         if (self.topMostRowBeforeKeyBoardWasShown && shouldScroll) {
                             [self scrollToRowAtIndexPath:self.topMostRowBeforeKeyBoardWasShown atScrollPosition:UITableViewScrollPositionTop animated:YES];
                         }
                     }];
}

#pragma mark CGRect Utility functions

CGRect XYWidthHeightRectSwap(CGRect rect) {
	CGRect newRect;
	newRect.origin.x = rect.origin.y;
	newRect.origin.y = rect.origin.x;
	newRect.size.width = rect.size.height;
	newRect.size.height = rect.size.width;
	return newRect;
}

CGRect FixOriginRotation(CGRect rect, UIInterfaceOrientation orientation, int parentWidth, int parentHeight) {
    CGRect newRect;
    switch(orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            newRect = CGRectMake(parentWidth - (rect.size.width + rect.origin.x), rect.origin.y, rect.size.width, rect.size.height);
            break;
        case UIInterfaceOrientationLandscapeRight:
            newRect = CGRectMake(rect.origin.x, parentHeight - (rect.size.height + rect.origin.y), rect.size.width, rect.size.height);
            break;
        case UIInterfaceOrientationPortrait:
            newRect = rect;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            newRect = CGRectMake(parentWidth - (rect.size.width + rect.origin.x), parentHeight - (rect.size.height + rect.origin.y), rect.size.width, rect.size.height);
            break;
    }
    return newRect;
}




@end
