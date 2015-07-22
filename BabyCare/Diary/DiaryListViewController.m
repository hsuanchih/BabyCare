//
//  DiaryListViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/19/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "DiaryListViewController.h"
#import "DiaryListTableViewCell.h"
#import "NewDiaryViewController.h"
#import "DataManager.h"
#import "DiaryManager.h"
#import "Theme.h"

@interface DiaryListViewController ()
<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIBarButtonItem *addButtonItem;
@property (nonatomic, strong) DiaryManager *diaryManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation DiaryListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [Theme backgroundColorWithAlpha:1.0];
    self.title = NSLocalizedString(@"Diary", nil);
    self.navigationItem.rightBarButtonItem = self.addButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDiaryManagerNotification:)
                                                 name:@"DiaryManagerNotification"
                                               object:[DiaryManager manager]];
    
    [self.fetchedResultsController performFetch:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"DiaryListTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"DiaryListTableViewCell"];
    
    [self.view addSubview:self.tableView];
    [self setViewConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) setViewConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_tableView]-(0)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[_tableView]-(0)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
}




#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSTimeInterval birthday;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        birthday = [[DataManager manager] birthday];
    });
    
    DiaryListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DiaryListTableViewCell"
                                                                        forIndexPath:indexPath];
    
    DiaryEntry *diaryEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSTimeInterval creationTime = [diaryEntry.creationTime timeIntervalSince1970];
    NSUInteger days = (creationTime - birthday)/(24*60*60);
    
    cell.dayLabel.text = [@(days) stringValue];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"On", nil), [self.dateFormatter stringFromDate:diaryEntry.creationTime]];
    cell.titleLabel.text = diaryEntry.title;
    cell.contentLabel.text = diaryEntry.content;
    
    if ([diaryEntry.hasImage boolValue])
    {
        NSData *imageData = [self.diaryManager loadMediaOfType:MCMediaTypeImage
                                                       andName:[@(creationTime) stringValue]];
        cell.cellImageView.image = [UIImage imageWithData:imageData];
    }
    [self updateImageViewConstraintsForCell:cell];
    
    return cell;
}



#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static DiaryListTableViewCell *sizingCell = nil;
    static CGFloat defaultCellHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"DiaryListTableViewCell"];
        defaultCellHeight = CGRectGetHeight(sizingCell.bounds) + 25;
    });
    
    DiaryEntry *diaryEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CGFloat cellTitleHeight = 0, cellContentHeight = 0, cellImageHeight  = 0;
    
    sizingCell.titleLabel.text = diaryEntry.title;
    CGSize titleLabelSize = [sizingCell.titleLabel sizeThatFits:CGSizeMake(CGRectGetWidth(sizingCell.titleLabel.bounds), MAXFLOAT)];
    cellTitleHeight = titleLabelSize.height;
    
    if ( diaryEntry.content != nil )
    {
        sizingCell.contentLabel.text = diaryEntry.content;
        CGSize contentLabelSize = [sizingCell.contentLabel sizeThatFits:CGSizeMake(CGRectGetWidth(sizingCell.contentLabel.bounds), MAXFLOAT)];
        cellContentHeight = contentLabelSize.height;
    }
    
    if ( [diaryEntry.hasImage boolValue] )
    {
        CGFloat
        imageWidth = [diaryEntry.imageWidth floatValue],
        imageHeight = [diaryEntry.imageHeight floatValue];
        cellImageHeight = CGRectGetWidth(sizingCell.cellImageView.bounds) * imageHeight / imageWidth;
    }
    
    return defaultCellHeight + cellTitleHeight + cellContentHeight + cellImageHeight;
}

- (BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        DiaryEntry *diaryEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:diaryEntry];
        [self.managedObjectContext save:nil];
        [self.diaryManager updateDeletes];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}



#pragma mark - NSFetchedResultsController delegate

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type)
    {
        case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        default:
            break;
    }
}



#pragma mark - Private utility

- (void) loadData
{
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if ( error == nil )
    {
        [self.tableView reloadData];
    }
}

- (void) buttonTapped:(id)sender
{
    if (sender == self.addButton)
    {
        NewDiaryViewController *newDiaryVC = [[NewDiaryViewController alloc] init];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:newDiaryVC] animated:YES completion:nil];
    }
}

- (void) updateImageViewConstraintsForCell:(DiaryListTableViewCell*)cell
{
    [cell.cellImageView.constraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLayoutConstraint *constraint = (NSLayoutConstraint*)obj;
        
        if (constraint.firstAttribute == NSLayoutAttributeHeight)
    
        {
            [cell.cellImageView removeConstraint:constraint];
            if ( cell.cellImageView.image != nil )
            {
                [cell.cellImageView addConstraint:[NSLayoutConstraint constraintWithItem:cell.cellImageView
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:cell.cellImageView
                                                                               attribute:NSLayoutAttributeWidth
                                                                              multiplier:cell.cellImageView.image.size.height/cell.cellImageView.image.size.width
                                                                                constant:0.0]];
            }
            else
            {
                [cell.cellImageView addConstraint:[NSLayoutConstraint constraintWithItem:cell.cellImageView
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1.0
                                                                                 constant:0.0]];
            }
            
        }
    }];
}

- (void) handleDiaryManagerNotification:(NSNotification*)notification
{
    [self loadData];
}



#pragma mark - CoreData execution context

- (NSManagedObjectContext*) managedObjectContext
{
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.parentContext = self.diaryManager.managedObjectContext;
    }
    return _managedObjectContext;
}



#pragma mark - Property accessor methods

- (UITableView*) tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        [_tableView registerNib:[UINib nibWithNibName:@"SidePanelTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"SidePanelTableViewCell"];
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.alwaysBounceVertical = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _tableView;
}

- (UIButton*) addButton
{
    if (_addButton == nil)
    {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"add_button"];
        CGFloat height = CGRectGetHeight(self.navigationController.navigationBar.frame) * 0.5 ;
        CGFloat width = image.size.width * height / image.size.height;
        [_addButton setImage:image forState:UIControlStateNormal];
        _addButton.frame = CGRectMake(0, 0, width, height);
        [_addButton addTarget:self
                       action:@selector(buttonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _addButton;
}

- (UIBarButtonItem *) addButtonItem {
    
    if (_addButtonItem == nil)
    {
        _addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addButton];
    }
    return _addButtonItem;
}

- (NSFetchedResultsController*) fetchedResultsController
{
    if (_fetchedResultsController == nil)
    {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (NSFetchRequest*) fetchRequest
{
    if (_fetchRequest == nil)
    {
        _fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DiaryEntry"];
        _fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationTime" ascending:NO]];
    }
    return _fetchRequest;
}

- (DiaryManager *)diaryManager
{
    if (_diaryManager == nil)
    {
        _diaryManager = [DiaryManager manager];
    }
    return _diaryManager;
}

- (NSDateFormatter*) dateFormatter
{
    if (_dateFormatter == nil)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MMM dd, YYYY, HH:mm"];
    }
    return _dateFormatter;
}

@end
