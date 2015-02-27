//
//  LDDiffViewController.m
//  GitLab
//
//  Created by Alan Seto on 8/11/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDDiffViewController.h"
#import "LDCommitStore.h"

@interface LDDiffViewController ()
{
    int maxWidth;
    int maxHeight;
}

@property (nonatomic) NSIndexPath *indexPath;

@end

@implementation LDDiffViewController

- (instancetype)init:(NSIndexPath *)indexPath
{
    self = [super initWithNibName:@"LDDiffViewController" bundle:nil];
    if (self) {
        self.indexPath = indexPath;
        self.navigationItem.title = [[[[LDCommitStore sharedStore] getItem:self.indexPath] objectForKey:@"new_path"] lastPathComponent];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.diffView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollV withView:(UIView *)view atScale:(float)scale
{
    [self.scrollView setContentSize:CGSizeMake(scale * maxWidth, scale * maxHeight + 80)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    NSLog(@"Orientation changed");
    NSLog(@"%f, %f", self.view.bounds.size.width, self.view.bounds.size.height);
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait) {
        self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        self.scrollView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        self.diffView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        self.diffView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } else {
        self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
        self.scrollView.bounds = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
        self.diffView.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
        self.diffView.bounds = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
    }
    [self.scrollView setNeedsDisplay];
    [self.diffView setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = self.view.bounds;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.delegate = self;
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait)
        self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    else
        self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
    [self.view addSubview:self.scrollView];
    
    self.diffView = [[UIView alloc] initWithFrame:screenRect];
    [self.scrollView addSubview:self.diffView];
    
    NSArray *diffArray = [[[[LDCommitStore sharedStore] getItem:self.indexPath] objectForKey:@"diff"] componentsSeparatedByString:@"\n"];
    maxWidth = 0;
    maxHeight = 20;
    
    for (NSString *string in diffArray) {
        UILabel *diffLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Courier" size:12]}].width + 40,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Courier" size:12]}].height + 5)];
        [diffLabel setFont:[UIFont fontWithName:@"Courier" size:12]];
        if ([[string substringToIndex:1] isEqualToString:@"+"]) {
            diffLabel.textColor = [UIColor colorWithRed:0 green:200.0f/255.0f blue:0 alpha:1];
        } else if ([[string substringToIndex:1] isEqualToString:@"-"]) {
            diffLabel.textColor = [UIColor redColor];
        }
        diffLabel.text = string;
        [self.diffView addSubview:diffLabel];
        if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Courier" size:12]}].width + 40 > maxWidth)
            maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Courier" size:12]}].width + 40;
        maxHeight += [string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Courier" size:12]}].height + 5;
    }
    
    CGRect bigRect;
    bigRect.size.width = maxWidth;
    bigRect.size.height = maxHeight + 80;
    self.scrollView.contentSize = bigRect.size;
}

@end
