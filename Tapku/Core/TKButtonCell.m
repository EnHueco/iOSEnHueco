//
//  TKButtonCell.m
//  Created by Devin Ross on 7/2/09.
//
/*
 
 tapku || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKButtonCell.h"


@implementation TKButtonCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
	
	self.textLabel.textAlignment = NSTextAlignmentCenter;
	self.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
	
	self.textLabel.textColor = [UIColor colorWithRed:74/255.0 green:110/255.0 blue:165/255.0 alpha:1.0];
	self.textLabel.highlightedTextColor = [UIColor whiteColor];
	
	
	
    return self;
}

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}


- (void) layoutSubviews {
	[super layoutSubviews];
	CGRect r = CGRectInset(self.contentView.bounds , 20, 8);
	self.textLabel.frame = r;
}







@end
