//
//  SongsListViewController.m
//  PowerPlayer
//
//  Created by 许  on 12-6-26.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "SongsListViewController.h"
#import "FileManager.h"
#import "PlayerManager.h"
#import "SongsListCell.h"
#import "Player.h"
#import "Song.h"
#import "PublicDefinitions.h"
#import "PlayBoard.h"
#import "DynamicLabel.h"

@interface SongsListViewController ()
- (void)hideList;
- (void)tapped;
@end

@implementation SongsListViewController
@synthesize m_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    CGRect framePlayBoard = CGRectMake(0,
                                       0,
                                       CGRectGetWidth([self.view frame]),
                                       CGRectGetHeight([self.view frame]));
    
    m_playBoard = [[PlayBoard alloc] initWithFrame:framePlayBoard];
    [m_playBoard setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    m_playBoard.alpha = 0.0f;
    [self.view addSubview:m_playBoard];
    
    // Do any additional setup after loading the view from its nib.
    [m_tableView setSeparatorColor:[UIColor colorWithRed:0.8
                                                   green:0.8
                                                    blue:0.8
                                                   alpha:1]];
    [m_tableView setBackgroundColor:[UIColor colorWithWhite:.0
                                                      alpha:0.5]];
    
//    CGRect theRectForTable = [m_tableView frame];
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.startPoint = CGPointMake(0.5, 0.0);
//    gradient.endPoint = CGPointMake(0.5, 1);
//    gradient.frame = theRectForTable;
//    gradient.colors = [NSArray arrayWithObjects:
//                       (id)[UIColor colorWithWhite:0 alpha:0.9].CGColor,
//                       (id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,
//                       (id)[UIColor colorWithWhite:0 alpha:0.9].CGColor, nil];
//    [self.view.layer addSublayer:gradient];
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:3
                                               target:self
                                             selector:@selector(hideList)
                                             userInfo:nil
                                              repeats:NO];
    m_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(tapped)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    if (nil != m_timer)
    {
        if (YES == [m_timer isValid])
        {
            [m_timer invalidate];
        }
        m_timer = nil;
    }
    [m_tableView release];
    [m_tapGesture release];
    [m_playBoard release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[FileManager sharedInstance] allSongs] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SongsListCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"songs list cell";
    SongsListCell *cell = (SongsListCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[[SongsListCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    Song *aSong = [[PlayerManager sharedInstance] songAtListIndex:indexPath.row];
    [cell.titleLabel setText:aSong.title];
    [cell.performerLabel setText:aSong.performer];
    cell.song = aSong;
    [cell updatePlayStatus];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (nil != m_timer)
    {
        if (YES == [m_timer isValid])
        {
            [m_timer invalidate];
        }
        m_timer = nil;
        [self showList];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (nil != m_timer)
    {
        return;
    }
    m_timer = [NSTimer scheduledTimerWithTimeInterval:3
                                               target:self
                                             selector:@selector(hideList)
                                             userInfo:nil
                                              repeats:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (nil != m_timer)
    {
        return;
    }
    m_timer = [NSTimer scheduledTimerWithTimeInterval:3
                                               target:self
                                             selector:@selector(hideList)
                                             userInfo:nil
                                              repeats:NO];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (nil != m_timer)
    {
        return;
    }
    m_timer = [NSTimer scheduledTimerWithTimeInterval:3
                                               target:self
                                             selector:@selector(hideList)
                                             userInfo:nil
                                              repeats:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *aSong = [[PlayerManager sharedInstance] songAtListIndex:indexPath.row];
    [[PlayerManager sharedInstance] playAudio:aSong];
    SongsListCell *cell = (SongsListCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setPlaying:YES];
}

#pragma mark -
- (void)scrollListToCurrentSong
{
    Song *oneSong = [[[PlayerManager sharedInstance] currentPlayer] currentSong];
    if (nil != oneSong)
    {
        [m_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:oneSong.dIndex inSection:0]
                           atScrollPosition:UITableViewScrollPositionMiddle
                                   animated:YES];
    }
}

- (void)showList
{
    if (m_tableView.alpha > 0.5)
    {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_SongsListWillShow
                                                        object:nil];
    
    [self scrollListToCurrentSong];
    CGAffineTransform trans1 = CGAffineTransformMakeScale(0.9, 0.9);
    CGAffineTransform trans2 = CGAffineTransformMakeScale(1, 1);
    m_tableView.transform = trans1;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    m_tableView.transform = trans2;
    m_tableView.alpha = 1.0f;
    m_playBoard.alpha = 0.0f;
    [UIView commitAnimations];
    m_timer = [NSTimer scheduledTimerWithTimeInterval:3
                                               target:self
                                             selector:@selector(hideList)
                                             userInfo:nil
                                              repeats:NO];
    NSArray *arrGestures = [self.view gestureRecognizers];
    if (nil != arrGestures 
        && [arrGestures count] > 0 
        && [arrGestures containsObject:m_tapGesture])
        [self.view removeGestureRecognizer:m_tapGesture];
}

- (void)hideList
{
    if (m_tableView.alpha < 0.4)
    {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_SongsListWillHide
                                                        object:nil];
    
    CGAffineTransform trans1 = CGAffineTransformMakeScale(1, 1);
    CGAffineTransform trans2 = CGAffineTransformMakeScale(0.9, 0.9);
    m_tableView.transform = trans1;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    m_tableView.transform = trans2;
    m_tableView.alpha = 0.0f;
    m_playBoard.alpha = 1.0f;
    [UIView commitAnimations];
    if (nil != m_timer)
    {
        if (YES == [m_timer isValid])
        {
            [m_timer invalidate];
        }
        m_timer = nil;
    }
        
    NSArray *arrGestures = [self.view gestureRecognizers];
    if (nil == arrGestures
        || 0 == [arrGestures count]
        || NO == [arrGestures containsObject:m_tapGesture])
        [self.view addGestureRecognizer:m_tapGesture];
}

- (void)tapped
{
    [self showList];
}

@end
