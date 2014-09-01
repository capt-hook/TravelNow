//
//  MHLabel.m
//
//  Created by Maksym Huk on 5/14/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//  Version 1.0
//

#import "MHLabel.h"

@implementation MHLabel

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.edgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize {
	CGSize size = [super intrinsicContentSize];
	size.width += (self.edgeInsets.left + self.edgeInsets.right);
	size.height += (self.edgeInsets.top + self.edgeInsets.bottom);
	return size;
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];
	if (self.numberOfLines != 1) {
		self.preferredMaxLayoutWidth = bounds.size.width;
	}
}

@end
