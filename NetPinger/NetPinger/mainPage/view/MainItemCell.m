//
//  MainItemCell.m
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "MainItemCell.h"


@implementation MainItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:@"MainItemCell" owner:self options:nil].lastObject;
    }
    return self;
}

+ (instancetype)mainItemCell
{
    MainItemCell *mainItemCell = [[NSBundle mainBundle] loadNibNamed:@"MainItemCell" owner:self options:nil].lastObject;
    return mainItemCell;
}

+ (instancetype)mainItemCellWithMainItemInfo:(MainItemInfo *)mainItemInfo
{
    MainItemCell *cell = [self mainItemCell];
    cell.mainItemInfo = mainItemInfo;
    return cell;
}

- (void)setMainItemInfo:(MainItemInfo *)mainItemInfo
{
    _mainItemInfo = mainItemInfo;
    self.mainItemImageView.image = [UIImage imageNamed:mainItemInfo.icon];
    self.functionLabel.text = mainItemInfo.funcName;
}

@end
