//
//  NewDiaryViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/19/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "NewDiaryViewController.h"
#import "Theme.h"

static NSString * const contentTextViewPlaceHolder = @"Something interesting happened to the baby?";

@interface NewDiaryViewController ()
<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextView *contentTextView;
@property (nonatomic, weak) IBOutlet UIView *imageBaseView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *albumButton;
@property (nonatomic, weak) IBOutlet UIButton *removeButton;
@property (nonatomic, strong) UIToolbar *accessoryView;
@property (nonatomic, strong) UIBarButtonItem *cancelButtonItem, *doneButtonItem;
@property (nonatomic, strong) NSArray *photoButtons;
@end

@implementation NewDiaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)])
    {
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    }

    self.navigationController.navigationBar.tintColor = [Theme colorWithAlpha:1.0];
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(buttonTapped:)];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(buttonTapped:)];
    self.navigationItem.rightBarButtonItem.enabled = (self.titleTextField.text.length > 0);
    
    self.title = NSLocalizedString(@"New Diary", nil);
    
    self.titleTextField.delegate = self;
    
    self.contentTextView.delegate = self;
    self.contentTextView.text = contentTextViewPlaceHolder;
    
    [self.photoButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = (UIButton*)obj;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        button.layer.cornerRadius = 5.0;
        [button addTarget:self
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    }];
    self.cameraButton.enabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    [self.removeButton addTarget:self
                          action:@selector(buttonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    self.removeButton.hidden = self.imageView.image == nil;
    
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


#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    self.navigationItem.rightBarButtonItem.enabled = (newLength > 0);
    return newLength <= 30;
}



#pragma mark - UITextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [textView setInputAccessoryView:self.accessoryView];
    if ([textView.text isEqualToString:contentTextViewPlaceHolder])
    {
        textView.text = nil;
    }
    return YES;
}



#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.imageView.image = image;
    [self updateImageBaseViewConstraints];
    self.removeButton.hidden = self.imageView.image == nil;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - Private utility

- (void) updateImageBaseViewConstraints
{
    [self.imageBaseView.constraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLayoutConstraint *constraint = (NSLayoutConstraint*)obj;
        
        if (constraint.firstAttribute == NSLayoutAttributeWidth ||
            constraint.secondAttribute == NSLayoutAttributeWidth )
        {
            [self.imageBaseView removeConstraint:constraint];
            [self.imageBaseView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageBaseView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.imageBaseView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:self.imageView.image.size.width/self.imageView.image.size.height
                                                                            constant:0.0]];
        }
    }];
}

- (void) buttonTapped:(id)sender
{
    if ( sender == self.removeButton )
    {
        self.imageView.image = nil;
        self.removeButton.hidden = (self.imageView.image == nil);
    }
    else if ( sender == self.cancelButtonItem || sender == self.doneButtonItem )
    {
        if ( sender == self.cancelButtonItem )
        {
            self.contentTextView.text = contentTextViewPlaceHolder;
        }
        [self.contentTextView resignFirstResponder];
    }
    else if (sender == self.navigationItem.leftBarButtonItem )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (sender == self.navigationItem.rightBarButtonItem )
    {
        DiaryManager *diaryManager = [DiaryManager manager];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDiaryManagerNotification:)
                                                     name:@"DiaryManagerNotification"
                                                   object:diaryManager];
        
        [diaryManager saveDiary:[self createDiaryData]];
    }
    else
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.navigationBar.tintColor = [Theme colorWithAlpha:1.0];
        imagePickerController.allowsEditing = YES;
        imagePickerController.delegate = self;
        if ( sender == self.albumButton )
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else if ( sender == self.cameraButton )
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (NSDictionary*) createDiaryData
{
    NSMutableDictionary *diaryData = [NSMutableDictionary dictionaryWithObject:self.titleTextField.text
                                                                        forKey:@"title"];
    if ( ![self.contentTextView.text isEqualToString:contentTextViewPlaceHolder] )
    {
        [diaryData setObject:self.contentTextView.text forKey:@"content"];
    }
    
    if ( self.imageView.image != nil )
    {
        [diaryData setObject:UIImagePNGRepresentation(self.imageView.image) forKey:@"image"];
        [diaryData setObject:@(self.imageView.image.size.width) forKey:@"imageWidth"];
        [diaryData setObject:@(self.imageView.image.size.height) forKey:@"imageHeight"];
    }
    return diaryData;
}

- (void) handleDiaryManagerNotification:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DiaryManagerNotification"
                                                  object:[DiaryManager manager]];
    NSDictionary *userInfo = notification.userInfo;
    if ( userInfo )
    {
        NSString *operation = userInfo[@"operation"];
        if ( [operation isEqualToString:@"save"] )
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}



#pragma mark - Property accessors

- (UIToolbar*) accessoryView {
    
    if (_accessoryView == nil)
    {
        _accessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        [_accessoryView setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *flexibleSpace =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
        [_accessoryView setItems:@[self.cancelButtonItem, flexibleSpace, self.doneButtonItem]];
        _accessoryView.tintColor = [Theme colorWithAlpha:1.0];
    }
    return _accessoryView;
}

- (UIBarButtonItem*) cancelButtonItem
{
    if (_cancelButtonItem == nil)
    {
        _cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(buttonTapped:)];
    }
    return _cancelButtonItem;
}

- (UIBarButtonItem*) doneButtonItem
{
    if (_doneButtonItem == nil)
    {
        _doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                        target:self
                                                                        action:@selector(buttonTapped:)];
    }
    return _doneButtonItem;
}

- (NSArray*) photoButtons
{
    if (_photoButtons == nil)
    {
        _photoButtons = @[self.cameraButton, self.albumButton];
    }
    return _photoButtons;
}

@end
