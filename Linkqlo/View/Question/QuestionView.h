//
//  QuestionView.h
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuestionViewDelegate <NSObject>

- (void) setAnswer:(NSInteger)newAnswer forKey:(NSString *)strKey;

@end

@interface QuestionView : UIView
{
    float m_offset;

    NSString *curKey;
    NSInteger curAnswer;
    
    IBOutlet UIImageView* ivBack;
    IBOutlet UILabel* lblTitle;
    IBOutlet UIView* viewLabel;

    IBOutlet UIButton* btnOption1;
    IBOutlet UIButton* btnOption2;
    IBOutlet UIButton* btnOption3;
}

@property (nonatomic, assign) id<QuestionViewDelegate> delegate;

-(void)initView:(NSInteger)oldAnswer forKey:(NSString *)forKey;

@end
