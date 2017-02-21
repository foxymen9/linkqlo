//
//  JSProgress.m
//  PhotoSauce
//
//  Created by ZhXingli on 1/7/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JSProgress.h"

@implementation JSProgress
-(id)initWithParentView:(UIViewController*)parent title:(NSString*)text
{
    if (self = [super init])
    {
        m_hud = [[MBProgressHUD alloc] initWithView:parent.view];
        m_hud.mode = MBProgressHUDModeDeterminate;
        m_parent = [parent retain];
        [m_hud setDelegate:self];
        m_hud.labelText = text;
        m_hud.dimBackground = YES;
        m_bWaiting = false;
    }
    return self;
}

-(void)dealloc
{
    [m_hud release];
    [m_parent release];
    [super dealloc];
}

-(void)SetType
{
}

-(void)SetProgress:(float)percent
{
    m_hud.progress = percent;
}

-(void)SetText:(NSString *)text
{
    m_hud.labelText = text;
}

-(void)ShowProgress
{
    m_bWaiting = true;
    [m_parent.view addSubview:m_hud];
    [m_hud showWhileExecuting:@selector(ProgressTask) onTarget:self withObject:nil animated:YES];
}

-(void)ShowProgress:(SEL)method 
{
    [m_parent.view addSubview:m_hud];
    [m_hud showWhileExecuting:method onTarget:m_parent withObject:nil animated:YES];
}

-(void)HideProgress
{
    m_bWaiting = false;
}

-(void)ProgressTask
{
    while(m_bWaiting)
    {
        sleep(0.3f);
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}
@end
