//
//  MainItemCell.h
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainItemInfo.h"

@interface MainItemCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mainItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *functionLabel;
@property (nonatomic,strong) MainItemInfo *mainItemInfo;

+ (instancetype)mainItemCellWithMainItemInfo:(MainItemInfo *)mainItemInfo;
@end
