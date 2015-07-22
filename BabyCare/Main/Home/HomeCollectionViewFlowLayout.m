//
//  HomeCollectionViewFlowLayout.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/14/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "HomeCollectionViewFlowLayout.h"

@implementation HomeCollectionViewFlowLayout

- (CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    for(NSUInteger i = 0; i < [self.collectionView numberOfSections]; i++)
    {
        CGRect headerFrame = [self rectForHeaderInSection:i];
        
        if (CGRectIntersectsRect(headerFrame, rect))
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
            attr.frame = headerFrame;
            [layoutAttributes addObject:attr];
        }
        
        for(NSUInteger j = 0; j < [self.collectionView numberOfItemsInSection:i]; j++)
        {
            //this is the cell at row j in section i
            CGRect cellFrame = [self rectForItem:j inSection:i];
            
            //see if the collection view needs this cell
            if(CGRectIntersectsRect(cellFrame, rect))
            {
                //create the attributes object
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                
                //set the frame for this attributes object
                attr.frame = cellFrame;
                [layoutAttributes addObject:attr];
            }
        }
    }
    
    return layoutAttributes;
}

- (CGRect) rectForHeaderInSection:(NSUInteger)section
{
    CGRect rect = CGRectNull;
    if (section == 0)
    {
        rect = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                          CGRectGetMinY(self.collectionView.bounds),
                          CGRectGetWidth(self.collectionView.bounds),
                          CGRectGetHeight(self.collectionView.bounds)*0.15);
    }
    return rect;
}

- (CGFloat) heightForLastSectionView
{
    return 50;
}

- (CGRect) rectForItem:(NSInteger)item inSection:(NSInteger)section
{
    NSUInteger numItemsPerRow = [self numItemsPerRowInSection:section];
    CGFloat cellWidth = CGRectGetWidth(self.collectionView.bounds) / numItemsPerRow;
    CGFloat x = self.sectionInset.left + cellWidth * (MIN(item,5)%3);
    CGFloat y = CGRectGetHeight([self rectForHeaderInSection:0]);
    
    y +=
    
    // section 0/1/2 y-offset
    (MIN(item,5)/3) * [self cellHeightForItem:0 inSection:0] + (item/6) * [self cellHeightForItem:item inSection:section]
    
    // section 1/2 y-offset
    + ( section * 2 / pow(section ? section : section+1, section ? section-1 : section) * [self cellHeightForItem:0 inSection:0] )
    
    // section 2 y-offset
    + ( (section-1)*[self cellHeightForItem:0 inSection:(section-1)]);

    return CGRectMake(x, y, cellWidth, [self cellHeightForItem:item inSection:section]);
}


- (CGFloat) cellHeightForItem:(NSInteger)item inSection:(NSInteger)section
{
    if (section < 0)
    {
        return 0;
    }
    
    CGFloat
    cellHeight        = 0,
    minusHeaderView   = CGRectGetHeight(self.collectionView.bounds) -
                        CGRectGetHeight([self rectForHeaderInSection:0]),
    lastSectionHeight = [self heightForLastSectionView];
    
    switch (section) {
        case 0:
            cellHeight = (item < 5) ? (minusHeaderView - lastSectionHeight)*3/8 : (minusHeaderView - lastSectionHeight)*3/16;
            break;
            
        case 1:
            cellHeight = (minusHeaderView - lastSectionHeight)*1/4;
            break;
            
        case 2:
            cellHeight = lastSectionHeight;
            break;
            
        default:
            break;
    }
    return cellHeight;
}

- (NSUInteger) numItemsPerRowInSection:(NSUInteger)section
{
    return (section < 2) ? 3 : 1;
}

@end
