//
//  BBConnectCollectionViewCell.h
//  BattleBump
//
//  Created by Dave Augerinos on 2017-03-07.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BattleBump-Swift.h"

@interface BBConnectCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) Invitee *invitee;
@property (strong, nonatomic) IBOutlet BBCheckMark *checkMarkView;

- (instancetype)initWithFrame:(CGRect)frame;

@end
