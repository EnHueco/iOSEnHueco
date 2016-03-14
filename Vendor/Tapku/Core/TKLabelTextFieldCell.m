//
//  TKLabelTextfieldCell.m
//  Created by Devin Ross on 7/1/09.
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

#import "TKLabelTextFieldCell.h"


@implementation TKLabelTextFieldCell


- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	if(!(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    _field = [[UITextField alloc] initWithFrame:CGRectZero];
	_field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_field.backgroundColor = [UIColor clearColor];
    _field.font = [UIFont boldSystemFontOfSize:16.0];
    _field.delegate = self;
    [self.contentView addSubview:_field];
		
    
    return self;
}
- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	return self;
}



- (void) layoutSubviews {
    [super layoutSubviews];
	
	CGRect r = CGRectInset(self.contentView.bounds, 8, 8);
	CGFloat wid = CGRectGetWidth(self.label.frame);
	r.origin.x += wid + 6;
	r.size.width -= wid + 6;
	_field.frame = r;
	
	
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
	[_field resignFirstResponder];
	return NO;
}


- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	if(animated)
		[UIView beginAnimations:nil context:nil];
	_field.textColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
	if(animated)
		[UIView commitAnimations];
}
- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
	[super setHighlighted:highlighted animated:animated];
	
	if(animated)
		[UIView beginAnimations:nil context:nil];
	_field.textColor = highlighted ? [UIColor whiteColor] : [UIColor blackColor];
	if(animated)
		[UIView commitAnimations];
}


@end
