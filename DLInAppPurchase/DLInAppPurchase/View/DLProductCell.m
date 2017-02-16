//
//  DLProductCell.m
//  DLInAppPurchase
//
//  Created by FT_David on 2017/2/16.
//  Copyright © 2017年 FT_David. All rights reserved.
//

#import "DLProductCell.h"

@interface DLProductCell()

@property (weak, nonatomic) IBOutlet UILabel *productIDLabel;

@end

@implementation DLProductCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setProductID:(NSString *)productID
{
    _productID = productID;
    self.productIDLabel.text = productID;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
