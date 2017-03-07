//
//  BBConnectCollectionViewCell.h
//  BattleBump
//
//  Created by Dave Augerinos on 2017-03-07.
//  Copyright © 2017 Dave Augerinos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BattleBump-Swift.h"

@interface BBConnectCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) Game *game;

@end