#FUNTable

This simple bit of code lets you easily adjust the size and scroll position of your tables to account for the keyboard showing and hiding. This is useful both for keeping a cell that you are currently entering data into visible when the keyboard activate, and for keeping all the content in a table visible even if you aren't editing it. 

*Note that if you need the table to scroll to a particular cell, you MUST pass it to the method so it knows where to scroll to. Otherwise you can pass nil*.

Simply extend your tableViews with this (either in code or interface builder), and then call these methods on keyboard notifications. : 

	- (void)adjustTableViewForKeyboardwithCell:(UITableViewCell *)cell userInformation:(NSDictionary *)userInfo;
	- (void)adjustTableViewNoKeyboardWithUserInformation:(NSDictionary *)userInfo scrollToOriginalCell:(BOOL)shouldScroll;

##Example usage from a tableViewController: 

[Example Screencast](http://screencast.com/t/PRtVlAXvJzL1)

In this example I have two tables visible on an iPad screen. One for entering search criteria, and one for displaying results. Both need to be adjusted size wise when the keyboard is activated, but only the table with entry needs to scroll to a particular cell, so I pass a reference to it:

	- (void)keyboardWillShow:(NSNotification*)notification {
	    NSDictionary* userInfo = [notification userInfo];
	    
	    // adjust the guest entry table
	    UITableViewCell *textFieldCell = (UITableViewCell*) [[self.guestEntryTableViewDelegate.activeTextField superview] superview];
	    [self.guestEntryTableView adjustTableViewForKeyboardwithCell:textFieldCell userInformation:userInfo];
	    
	    // adjust the searchResults table
	    [self.searchResultTableView adjustTableViewForKeyboardwithCell:nil userInformation:userInfo];
	}

	- (void)keyboardWillHide:(NSNotification*)notification {
	    NSDictionary* userInfo = [notification userInfo];
	    [self.guestEntryTableView adjustTableViewNoKeyboardWithUserInformation:userInfo scrollToOriginalCell:YES];
	    [self.searchResultTableView adjustTableViewNoKeyboardWithUserInformation:userInfo scrollToOriginalCell:NO];
	}

