//
//  BCPartsPickerController.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 2012/09/21.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCPartsPickerController.h"

@interface BCPartsPickerController ()
@property (strong, nonatomic) BCPathView *pathView;
@property (assign, nonatomic) UIImagePickerControllerSourceType sourceType;
@property (nonatomic, assign) BOOL showImagePicker;
@property (strong, nonatomic) UIImage *selectedParts;
@property (strong, nonatomic) UIImage *maskImage;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation BCPartsPickerController
@synthesize previewView = _previewView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (id)initWithPickerType:(UIImagePickerControllerSourceType)pickerType
{
	self = [self initWithNibName:@"BCPartsPickerController" bundle:nil];
	if (self) {
		self.sourceType = pickerType;
		self.originalImage = nil;
		self.showImagePicker = YES;
	}
	return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	CGRect pathViewFrame = CGRectMake(0, 0, _previewView.frame.size.width, _previewView.frame.size.height);
	self.pathView = [[BCPathView alloc] initWithFrame:pathViewFrame];
    _pathView.delegate = self;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelButtonTapped:)];
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"done"
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(doneButtonTapped:)];


    _doneButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.doneButton;

	[self.previewView addSubview:self.pathView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if (self.showImagePicker) {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		imagePicker.sourceType = self.sourceType;
		[self presentModalViewController:imagePicker animated:NO];
		self.showImagePicker = NO;
	}
}

- (void)viewDidUnload
{
	[_pathView removeFromSuperview];
    [_imageView removeFromSuperview];
    self.pathView    = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark  image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self dismissModalViewControllerAnimated:YES];
	UIImage *loadImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	self.originalImage = loadImage;
	self.imageView = [[UIImageView alloc] initWithFrame:self.pathView.frame];
	_imageView.contentMode = UIViewContentModeScaleAspectFill;
	_imageView.image = loadImage;
    _pathView.originalImage = loadImage;
	[self.previewView insertSubview:_imageView belowSubview:self.pathView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
	if ([self.delegate respondsToSelector:@selector(BCPartsPickerControllerCanceld:)]) {
		[self.delegate BCPartsPickerControllerCanceld:self];
	}
}

#pragma mark path view delegate
- (void)didPartsSelected:(BCPathView *)pathView andSelectedParts:(UIImage *)selectedParts
{
    self.doneButton.enabled = YES;
	self.selectedParts = selectedParts;
}

- (void)didPartsSelected:(BCPathView *)pathView andSelectedParts:(UIImage *)selectedParts maskImage:(UIImage *)maskImage
{
    self.doneButton.enabled = YES;
    self.selectedParts = selectedParts;
    self.maskImage = maskImage;
}

#pragma mark background extraction delegate
- (void)backgroundExtractionDone:(BCPartsBackgroundExtractionViewController *)extractionViewController
{
	self.selectedParts = extractionViewController.extractedImage;
	self.maskImage = extractionViewController.extractedMaskImage;
	[self.navigationController popViewControllerAnimated:YES];

    if ([self.delegate respondsToSelector:@selector(BCPartsPickerControllerPickDone:partsImage:andMask:)]) {
        [self.delegate BCPartsPickerControllerPickDone:self partsImage:_selectedParts andMask:_maskImage];
    }
}


#pragma mark actions
- (void)cancelButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(BCPartsPickerControllerCanceld:)]) {
        [self.delegate BCPartsPickerControllerCanceld:self];
    }
}

- (void)doneButtonTapped:(id)sender
{
    NSLog(@"done button tapped");

    BCPartsBackgroundExtractionViewController *extractionVC = [[BCPartsBackgroundExtractionViewController alloc] init];
    extractionVC.delegate = self;
    extractionVC.originalImage = _selectedParts;
    [self.navigationController pushViewController:extractionVC animated:YES];
}

- (void)clearButtonTapped:(id)sender
{
    [self.pathView clearPath];
    self.doneButton.enabled = NO;
}


@end
