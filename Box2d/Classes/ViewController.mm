//
//  ViewController.m
//  ViewControllerTest
//

#import <UIKit/UIDevice.h>
#import "ViewController.h"
#import "GameController.h"

// PRIVATES
@interface ViewController()

@end

@implementation ViewController

- (id)initWithSparrowView:(SPView *)sparrowView
{
    if ((self = [super init]))
    {
        mSparrowView = sparrowView;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self selector:@selector(onApplicationDidBecomeActive:) 
                   name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [nc addObserver:self selector:@selector(onApplicationWillResignActive:) 
                   name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (id)init
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"ViewController requires Sparrow View"];
    return nil;
}

- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning
{
    [SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];   
    
    [super didReceiveMemoryWarning];
}

#pragma mark - view lifecycle

- (void)loadView
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.view = [[SPOverlayView alloc] initWithFrame:screenBounds];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSArray *supportedOrientations = 
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    
    return ((interfaceOrientation == UIInterfaceOrientationPortrait &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationPortrait"]) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeLeft &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"]) ||
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationPortraitUpsideDown"]) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeRight &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"]));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    // rotate Sparrow content
    GameController *gameController = (GameController *)mSparrowView.stage;
    [gameController rotateToInterfaceOrientation:interfaceOrientation
                                   animationTime:duration];
}

#pragma mark - notifications

- (void)onApplicationDidBecomeActive:(NSNotification *)notification
{
    [mSparrowView start];
}

- (void)onApplicationWillResignActive:(NSNotification *)notification
{
    [mSparrowView stop];
}




@end
