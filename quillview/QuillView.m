//
//  QuillView.m
//  quillview
//
//  Created by LIN on 2017/8/31.
//  Copyright © 2017年 hive. All rights reserved.
//

#import "QuillView.h"

#import <CoreText/CoreText.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "FLAnimatedImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"

static NSString * const QuillViewVideoPlayerObserverContext = @"QuillViewVideoPlayerObserverContext";
static NSString * const QuillViewVideoPlayerControllerPresentationSizeKey = @"presentationSize";

@interface QuillTextCell : UICollectionViewCell
@property (nonatomic, strong) UIView *leftBar;
@property (nonatomic, strong) UITextView *textView;
@end
@interface QuillImageCell : UICollectionViewCell
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@end
@interface QuillVideoCell : UICollectionViewCell
@property (nonatomic, strong) AVPlayerViewController *videoView;
@property (nonatomic, strong) NSMutableArray *playItems;
@property (nonatomic, weak) QuillView *quillView;
@end

@interface QuillView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate, AVPlayerViewControllerDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableDictionary *fontFamilyNames;
@property (nonatomic, strong) NSMutableDictionary *videoSizeDict;

@end

@implementation QuillView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[QuillTextCell class] forCellWithReuseIdentifier:@"text"];
        [_collectionView registerClass:[QuillImageCell class] forCellWithReuseIdentifier:@"image"];
        [_collectionView registerClass:[QuillVideoCell class] forCellWithReuseIdentifier:@"video"];
        [self addSubview:_collectionView];
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(self);
        }];
        
        _fontFamilyNames = [NSMutableDictionary new];
        for (NSString *name in [UIFont familyNames]) {
            [_fontFamilyNames setObject:name forKey:[name lowercaseString]];
        }
        
        _videoSizeDict = [NSMutableDictionary new];
        
        _style = [QuillStyle new];
    }
    return self;
}

- (void)setContentString:(NSString *)contentString
{
    _contentString = contentString;
    
    @try {
        NSError *error = nil;
        id delta = [NSJSONSerialization JSONObjectWithData:[contentString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        
        _dataArray = [self parseOps:delta[@"ops"]];
        
        [_collectionView reloadData];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (NSArray *)parseOps:(NSArray *)ops
{
    if (![ops isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *dataArray = [NSMutableArray new];
    NSMutableArray *line = [NSMutableArray new];
    NSMutableDictionary *listStack = [NSMutableDictionary new];
    for (NSDictionary *op in ops) {
        NSDictionary *attr = op[@"attributes"];
        id insert = op[@"insert"];
        if ([insert isKindOfClass:[NSString class]]) {
            NSRange range = [insert rangeOfString:@"\n"];
            NSArray *textArray = [insert componentsSeparatedByString:@"\n"];
            BOOL isBlock = [insert isEqualToString:@"\n"] && attr != nil;
            if (isBlock) {
                [line addObject:@{@"attributes":attr, @"text":@""}];
                NSNumber *blockquote = @(NO);
                NSAttributedString *atext = [self textFromLine:line listStack:listStack blockquote:&blockquote];
                [dataArray addObject:@{@"text":atext, @"blockquote":blockquote}];
                line = [NSMutableArray new];
            }
            else {
                NSInteger index = 0;
                for (NSString *text in textArray) {
                    if (attr) {
                        [line addObject:@{@"attributes":attr, @"text":text}];
                    }
                    else {
                        [line addObject:@{@"text":text}];
                    }
                    if (range.location != NSNotFound
                        && index < textArray.count - 1) {
                        NSNumber *blockquote = @(NO);
                        NSAttributedString *atext = [self textFromLine:line listStack:listStack blockquote:&blockquote];
                        [dataArray addObject:@{@"text":atext, @"blockquote":blockquote}];
                        line = [NSMutableArray new];
                    }
                    index += 1;
                }
            }
        }
        else if ([insert isKindOfClass:[NSDictionary class]]) {
            // embed
            NSString *image = insert[@"image"];
            if ([image isKindOfClass:[NSString class]]) {
                [dataArray addObject:[NSMutableDictionary dictionaryWithDictionary:insert]];
            }
            NSString *video = insert[@"video"];
            if ([video isKindOfClass:[NSString class]]) {
                [dataArray addObject:[NSMutableDictionary dictionaryWithDictionary:insert]];
            }
            NSString *formula = insert[@"formula"];
            // TODO: 公式如何实现？
            if ([formula isKindOfClass:[NSString class]]) {
                // 暂时作为文本插入
                if (attr) {
                    [line addObject:@{@"attributes":attr, @"text":formula}];
                }
                else {
                    [line addObject:@{@"text":formula}];
                }
            }
        }
    }
    if (line.count > 0) {
        NSNumber *blockquote = @(NO);
        NSAttributedString *atext = [self textFromLine:line listStack:listStack blockquote:&blockquote];
        [dataArray addObject:@{@"text":atext, @"blockquote":blockquote}];
    }
    return dataArray;
}

- (NSString *)textWithListStack:(NSMutableDictionary *)listStack indent:(NSInteger)indent
{
    NSInteger max = [listStack[@"max"] integerValue];
    if (indent > max) {
        // 记录最大的缩进
        listStack[@"max"] = @(indent);
        max = indent;
    }
    NSInteger oldIndent = [listStack[@"current"] integerValue];
    listStack[@"current"] = @(indent);
    if (indent < oldIndent) {
        // 将缩进更大的值重置为0
        for (NSInteger otherIndent = indent+1; otherIndent <= max; otherIndent++) {
            listStack[@(otherIndent)] = @(0);
        }
    }
    id value = listStack[@(indent)];
    NSInteger level = 0;
    if (value) {
        level = [value integerValue] + 1;
        for (NSInteger sublevel = 1; sublevel < level; sublevel++) {
            [listStack setObject:@(1) forKey:@(indent)];
        }
    }
    else {
        level = 1;
    }
    listStack[@(indent)] = @(level);
    if (indent % 3 == 0) {
        // 数字
        return [NSString stringWithFormat:@"%ld", level];
    }
    else if (indent % 3 == 1) {
        // 字母
        return [QuillUtil alphabetNumber:level];
    }
    else {
        // 罗马数字
        return [[QuillUtil romanNumber:level] lowercaseString];
    }
}

- (NSAttributedString *)textFromLine:(NSMutableArray *)line listStack:(NSMutableDictionary *)listStack blockquote:(NSNumber **)blockquote
{
    NSMutableAttributedString *textAll = [[NSMutableAttributedString alloc] init];
    
    // block
    NSInteger headingLevel = 0;
    NSTextAlignment textAlignment = NSTextAlignmentLeft;
    NSWritingDirection textDirection = NSWritingDirectionNatural;
    NSInteger indent = 0;
    CGFloat textIndent = 0.0f;

    // block块属性，在最后一个对象
    id lastAttr = [line lastObject][@"attributes"];
    if (lastAttr) {
        // 标题1/2/3/4/5/6
        if (lastAttr[@"header"]) {
            headingLevel = [lastAttr[@"header"] integerValue];
            if (headingLevel < 0) {
                headingLevel = 0;
            }
        }
        // 对齐
        if (lastAttr[@"align"]) {
            NSString *align = lastAttr[@"align"];
            if ([align isEqualToString:@"center"]) {
                textAlignment = NSTextAlignmentCenter;
            }
            else if ([align isEqualToString:@"right"]) {
                textAlignment = NSTextAlignmentRight;
            }
            else if ([align isEqualToString:@"justify"]) {
                textAlignment = NSTextAlignmentJustified;
            }
        }
        // 方向
        if (lastAttr[@"direction"]) {
            NSString *direction = lastAttr[@"direction"];
            if ([direction isEqualToString:@"rtl"]) {
                textDirection = NSWritingDirectionRightToLeft;
            }
        }
        // 缩进
        if (lastAttr[@"indent"]) {
            indent = [lastAttr[@"indent"] integerValue];
            if (indent > 0) {
                textIndent = [_style indentDistance:indent];
            }
            else {
                indent = 0;
            }
        }
        // 引用
        if (lastAttr[@"blockquote"]) {
            indent += 1;
            textIndent = [_style indentDistance:indent];
            if (blockquote) {
                *blockquote = @(YES);
            }
        }
        // 编号列表
        if (lastAttr[@"list"]) {
            NSString *listType = lastAttr[@"list"];
            if ([listType isEqualToString:@"ordered"]) {
                // 序号
                NSString *text = [NSString stringWithFormat:@" %@. ", [self textWithListStack:listStack indent:indent]];
                [line insertObject:@{@"text":text} atIndex:0];
            }
            else if ([listType isEqualToString:@"bullet"]) {
                [listStack removeAllObjects];
                
                // 圆点
                [line insertObject:@{@"text":@" \u2022 "} atIndex:0];
            }
            else {
                [listStack removeAllObjects];
            }
        }
        else {
            [listStack removeAllObjects];
        }
    }
    else {
        [listStack removeAllObjects];
    }
    
    // inline
    for (id fragment in line) {
        NSString *text = fragment[@"text"];
        if (text) {
            NSMutableAttributedString *atext = [[NSMutableAttributedString alloc] initWithString:text];
            NSRange range = NSMakeRange(0, text.length);
            UIFontDescriptorSymbolicTraits fontTraits = 0;
            CGFloat fontSize = 0.0f;
            NSString *fontFamilyName = nil;
            NSMutableDictionary *attrDict = [NSMutableDictionary new];
            id attrs = fragment[@"attributes"];
            if (attrs) {
                id background = attrs[@"background"];
                if (background) {
                    UIColor *colorValue = [QuillUtil colorWithAttr:background];
                    [attrDict setObject:colorValue forKey:NSBackgroundColorAttributeName];
                }
                else {
                    [attrDict setObject:[UIColor clearColor] forKey:NSBackgroundColorAttributeName];
                }
                
                id color = attrs[@"color"];
                if (color) {
                    UIColor *colorValue = [QuillUtil colorWithAttr:color];
                    [attrDict setObject:colorValue forKey:NSForegroundColorAttributeName];
                }
                else {
                    [attrDict setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
                }
                
                id bold = attrs[@"bold"];
                if (bold) {
                    fontTraits |= UIFontDescriptorTraitBold;
                }
                
                id italic = attrs[@"italic"];
                if (italic) {
                    //fontTraits |= UIFontDescriptorTraitItalic;
                    [attrDict setObject:@(0.15) forKey:NSObliquenessAttributeName]; // 解决汉字斜体问题
                }
                
                id underline = attrs[@"underline"];
                if (underline) {
                    [attrDict setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
                }
                
                id strike = attrs[@"strike"];
                if (strike) {
                    [attrDict setObject:@(NSUnderlineStyleSingle) forKey:NSStrikethroughStyleAttributeName];
                }
                
                id link = attrs[@"link"];
                if (link) {
                    [attrDict setObject:link forKey:NSLinkAttributeName];
                }
                
                id size = attrs[@"size"];
                if (size) {
                    if ([size isEqualToString:@"small"]) {
                        fontSize = _style.smallFontSize;
                    }
                    else if ([size isEqualToString:@"large"]) {
                        fontSize = _style.largeFontSize;
                    }
                    else if ([size isEqualToString:@"huge"]) {
                        fontSize = _style.hugeFontSize;
                    }
                    else {
                        fontSize = [QuillUtil sizeWithAttr:size basicSize:_style.fontSize];
                    }
                }
                
                id fontFamily = attrs[@"font"];
                if (fontFamily) {
                    // 自定义字体
                    fontFamilyName = [_fontFamilyNames objectForKey:[fontFamily lowercaseString]];
                }

                id script = attrs[@"script"];
                if (script) {
                    if ([script isEqualToString:@"super"]) {
                        [attrDict setObject:@(1) forKey:(NSString *)kCTSuperscriptAttributeName];
                    }
                    else if ([script isEqualToString:@"sub"]) {
                        [attrDict setObject:@(-1) forKey:(NSString *)kCTSuperscriptAttributeName];
                    }
                }
            }
            
            // 标题 1/2/3/4/5/6
            if (headingLevel == 1) {
                fontSize = _style.h1FontSize;
            }
            else if (headingLevel == 2) {
                fontSize = _style.h2FontSize;
            }
            else if (headingLevel == 3) {
                fontSize = _style.h3FontSize;
            }
            else if (headingLevel == 4) {
                fontSize = _style.h4FontSize;
            }
            else if (headingLevel == 5) {
                fontSize = _style.h5FontSize;
            }
            else if (headingLevel >= 6) {
                fontSize = _style.h6FontSize;
            }
            
            // 标题加粗
            if (headingLevel > 0) {
                fontTraits |= UIFontDescriptorTraitBold;
            }
            
            UIFont *font = [UIFont systemFontOfSize:_style.fontSize];
            if (fontFamilyName) {
                font = [UIFont fontWithName:fontFamilyName size:_style.fontSize];
            }
            if (fontTraits != 0) {
                UIFontDescriptor *desc = [[font fontDescriptor] fontDescriptorWithSymbolicTraits:fontTraits];
                font = [UIFont fontWithDescriptor:desc size:0];
            }
            if (fontSize > 0) {
                font = [font fontWithSize:fontSize];
            }
            [attrDict setObject:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.minimumLineHeight = _style.lineHeight * (fontSize > 0 ? fontSize : _style.fontSize);
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = textAlignment;
            style.firstLineHeadIndent = textIndent;
            style.headIndent = textIndent;
            [attrDict setObject:style forKey:NSParagraphStyleAttributeName];
            
            [atext setAttributes:attrDict range:range];
            [textAll appendAttributedString:atext];
        }
    }
    
    // 文字方向
    if (textDirection != NSWritingDirectionNatural) {
        [textAll addAttribute:NSWritingDirectionAttributeName value:@[@(textDirection | NSWritingDirectionEmbedding)] range:NSMakeRange(0, textAll.length)];
    }
    return textAll;
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id line = _dataArray[indexPath.row];
    if (line[@"image"]) {
        // 图片
        QuillImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"image" forIndexPath:indexPath];
        NSURL *imageURL = [NSURL URLWithString:line[@"image"]];
        __weak typeof(self) weakSelf = self;
        [cell.imageView sd_setImageWithURL:imageURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

            if (cacheType == SDImageCacheTypeNone && weakSelf) {
                // 修正图片高度
                [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(reloadData) object:nil];
                [weakSelf performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
            }
        }];
        return cell;
    }
    else if (line[@"video"]) {
        // 视频
        QuillVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"video" forIndexPath:indexPath];
        NSURL *videoURL = [NSURL URLWithString:line[@"video"]];
        if (videoURL) {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoURL];
            if (playerItem) {
                [playerItem addObserver:cell forKeyPath:QuillViewVideoPlayerControllerPresentationSizeKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(QuillViewVideoPlayerObserverContext)];
                [cell.playItems addObject:playerItem];
            }
            cell.videoView.player = [AVPlayer playerWithPlayerItem:playerItem];
            [cell.videoView.player play];
            cell.quillView = self;
        }
        return cell;
    }
    
    // 文本
    QuillTextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"text" forIndexPath:indexPath];
    cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName: _style.linkColor,
                                        NSUnderlineColorAttributeName: _style.linkUnderlineColor,
                                        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    cell.textView.textContainerInset = _style.textBlockInset;
    cell.textView.attributedText = line[@"text"];
    cell.textView.delegate = self;
    // 引用
    cell.leftBar.hidden = ![line[@"blockquote"] boolValue];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = [_style widthWithContainer:collectionView];
    id line = _dataArray[indexPath.row];
    if (line[@"image"]) {
        // 图片高度
        CGFloat width = 0.0f;
        CGFloat height = 0.0f;
        NSURL *imageURL = [NSURL URLWithString:line[@"image"]];
        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:imageURL];
        UIImage *lastPreviousCachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:key];
        if (lastPreviousCachedImage) {
            width = lastPreviousCachedImage.size.width;
            height = lastPreviousCachedImage.size.height;
        }
        if (width > 0 && height > 0) {
            height = cellWidth * height / width;
        }
        else {
            height = cellWidth / 2;
        }
        return CGSizeMake(cellWidth, height);
    }
    else if (line[@"video"]) {
        // 视频高度
        CGFloat width = 0.0f;
        CGFloat height = 0.0f;
        NSURL *videoURL = [NSURL URLWithString:line[@"video"]];
        if (_videoSizeDict[videoURL]) {
            CGSize size = [_videoSizeDict[videoURL] CGSizeValue];
            width = size.width;
            height = size.height;
        }
        if (width > 0 && height > 0) {
            height = cellWidth * height / width;
        }
        else {
            height = cellWidth / 2;
        }
        return CGSizeMake(cellWidth, height);
    }
    
    NSAttributedString *text = line[@"text"];
    if (text.length > 0) {
        // 文本高度
        CGSize maxSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGRect frame = [text boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        // TODO: 为什么高度需要+2才能显示完整？
        // 文字含有上下标时，ios10高度有误，ios8、9、11高度正确
        return CGSizeMake(cellWidth, frame.size.height + _style.textBlockInset.top + _style.textBlockInset.bottom + 2);
    }
    
    // 空行高度
    return CGSizeMake(cellWidth, _style.fontSize);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    // cell间距
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    // 总体间距
    return _style.contentInset;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0)
{
    return YES;
}

@end

@implementation QuillTextCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor],
                                         NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        _textView.dataDetectorTypes = UIDataDetectorTypeLink;
        _textView.editable = NO;
        _textView.contentInset = UIEdgeInsetsZero;
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.scrollEnabled = NO;
        [self.contentView addSubview:_textView];
        
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.width.equalTo(self.contentView);
            make.height.equalTo(self.contentView);
        }];
        
        _leftBar = [[UIView alloc] init];
        _leftBar.hidden = YES;
        _leftBar.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.00];
        [self.contentView addSubview:_leftBar];
        [_leftBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.width.mas_equalTo(5);
            make.height.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _textView.text = nil;
    _textView.attributedText = nil;
}

@end

@implementation QuillImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.width.equalTo(self.contentView);
            make.height.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _imageView.image = nil;
}

@end

@implementation QuillVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoView = [[AVPlayerViewController alloc] init];
        _videoView.view.backgroundColor = [UIColor clearColor];
        _videoView.showsPlaybackControls = YES;
        [self.contentView addSubview:_videoView.view];
        
        [_videoView.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.width.equalTo(self.contentView);
            make.height.equalTo(self.contentView);
        }];
        
        _playItems = [NSMutableArray new];
    }
    return self;
}

- (void)removeAllObservers
{
    for (id playerItem in _playItems) {
        @try {
            [playerItem removeObserver:self forKeyPath:QuillViewVideoPlayerControllerPresentationSizeKey context:(__bridge void *)(QuillViewVideoPlayerObserverContext)];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
    [_playItems removeAllObjects];
}

- (void)dealloc
{
    [self removeAllObservers];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self removeAllObservers];
    
    if (_videoView.player) {
        [_videoView.player pause];
        _videoView.player = nil;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)(QuillViewVideoPlayerObserverContext) )
    {
        if ([keyPath isEqualToString:QuillViewVideoPlayerControllerPresentationSizeKey])
        {
            CGSize size = [change[NSKeyValueChangeNewKey] CGSizeValue];
            NSLog(@"PresentationSize = [%f, %f]",size.width,size.height);
            
            AVPlayerItem *playerItem = object;
            if (playerItem) {
                NSURL *videoURL = [(AVURLAsset *)(playerItem.asset) URL];
                QuillView *strongQuillView = self.quillView;
                if (strongQuillView && strongQuillView.videoSizeDict[videoURL] == nil) {
                    strongQuillView.videoSizeDict[videoURL] = [NSValue valueWithCGSize:size];
                    
                    // 修正视频高度
                    [NSObject cancelPreviousPerformRequestsWithTarget:strongQuillView selector:@selector(reloadData) object:nil];
                    [strongQuillView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
                }
            }
        }
    }
}

@end

@implementation QuillUtil

+ (CGFloat)sizeWithAttr:(NSString *)attr basicSize:(CGFloat)basicSize
{
    attr = [attr lowercaseString];
    if ([attr hasSuffix:@"px"]) {
        return [attr floatValue];
    }
    else if ([attr hasSuffix:@"em"]) {
        return [attr floatValue] * basicSize;
    }
    return [attr floatValue];
}

+ (UIColor *)colorWithAttr:(NSString *)attr
{
    attr = [attr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([attr isEqualToString:@"transparent"]) {
        return [UIColor clearColor];
    }
    else if ([attr isEqualToString:@"black"]) {
        return [UIColor blackColor];
    }
    else if ([attr isEqualToString:@"white"]) {
        return [UIColor whiteColor];
    }
    else if ([attr isEqualToString:@"yellow"]) {
        return [UIColor yellowColor];
    }
    else if ([attr isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    }
    else if ([attr isEqualToString:@"red"]) {
        return [UIColor redColor];
    }
    else if ([attr isEqualToString:@"orange"]) {
        return [UIColor orangeColor];
    }
    else if ([attr isEqualToString:@"purple"]) {
        return [UIColor purpleColor];
    }
    else if ([attr isEqualToString:@"green"]) {
        return [UIColor greenColor];
    }
    
    if (attr.length == 4) {
        // Separate into r, g, b substrings
        NSRange range;
        range.location = 1;
        range.length = 1;
        //r
        NSString *rString = [attr substringWithRange:range];
        //g
        range.location = 2;
        NSString *gString = [attr substringWithRange:range];
        //b
        range.location = 3;
        NSString *bString = [attr substringWithRange:range];
        attr = [NSString stringWithFormat:@"#%@%@%@%@%@%@", rString, rString, gString, gString, bString, bString];
    }
    
    @try {
        // Separate into r, g, b substrings
        NSRange range;
        range.location = 1;
        range.length = 2;
        //r
        NSString *rString = [attr substringWithRange:range];
        //g
        range.location = 3;
        NSString *gString = [attr substringWithRange:range];
        //b
        range.location = 5;
        NSString *bString = [attr substringWithRange:range];
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        return [UIColor colorWithRed:r /255.0f green:g/255.0f blue:b/255.0f alpha:1.0];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return [UIColor blackColor];
}

+ (NSString *)alphabetNumber:(NSInteger)num
{
    NSArray *alphabet = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
    NSString *text = @"";
    while (num > 0) {
        NSInteger base = num % 26;
        if (base == 0) {
            base = 26;
        }
        num = (num - base) / 26;
        text = [alphabet[base - 1] stringByAppendingString:text];
    }
    return text;
}

// https://stackoverflow.com/a/21643549
+ (NSString *)romanNumber:(NSInteger)num
{
    if (num < 0 || num > 9999) { return @""; } // out of range
    
    NSArray *r_ones = [NSArray arrayWithObjects:@"I", @"II", @"III", @"IV", @"V", @"VI", @"VII", @"VIII", @"IX", nil];
    NSArray *r_tens = [NSArray arrayWithObjects:@"X", @"XX", @"XXX", @"XL", @"L", @"LX", @"LXX",@"LXXX", @"XC", nil];
    NSArray *r_hund = [NSArray arrayWithObjects:@"C", @"CC", @"CCC", @"CD", @"D", @"DC", @"DCC",@"DCCC", @"CM", nil];
    NSArray *r_thou = [NSArray arrayWithObjects:@"M", @"MM", @"MMM", @"MMMM", @"MMMMM", @"MMMMMM", @"MMMMMMM", @"MMMMMMMM", @"MMMMMMMMM", nil];
    // real romans should have an horizontal   __           ___           _____
    // bar over number to make x 1000: 4000 is IV, 16000 is XVI, 32767 is XXXMMDCCLXVII...
    
    NSInteger thou = num / 1000;
    NSInteger hundreds = (num -= thou*1000) / 100;
    NSInteger tens = (num -= hundreds*100) / 10;
    NSInteger ones = num % 10; // cheap %, 'cause num is < 100!
    
    return [NSString stringWithFormat:@"%@%@%@%@",
            thou ? [r_thou objectAtIndex:thou-1] : @"",
            hundreds ? [r_hund objectAtIndex:hundreds-1] : @"",
            tens ? [r_tens objectAtIndex:tens-1] : @"",
            ones ? [r_ones objectAtIndex:ones-1] : @""];
}

@end

@implementation QuillStyle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _indent = 3.0;
        _lineHeight = 1.42;
        _contentInset = UIEdgeInsetsMake(10, 15, 10, 15);
        _textBlockInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _linkColor = [UIColor blueColor];
        _linkUnderlineColor = [UIColor lightGrayColor];
        _fontSize = 13.0;
        _h1FontSize = 2.0 * _fontSize;
        _h2FontSize = 1.5 * _fontSize;
        _h3FontSize = 1.17 * _fontSize;
        _h4FontSize = 1.0 * _fontSize;
        _h5FontSize = 0.83 * _fontSize;
        _h6FontSize = 0.67 * _fontSize;
        _smallFontSize = 0.75 * _fontSize;
        _largeFontSize = 1.5 * _fontSize;
        _hugeFontSize = 2.5 * _fontSize;
    }
    return self;
}

- (CGFloat)widthWithContainer:(UIView *)container
{
    return container.bounds.size.width - _contentInset.left - _contentInset.right;
}

- (CGFloat)heightWithContainer:(UIView *)container
{
    return container.bounds.size.width - _contentInset.top - _contentInset.bottom;
}

- (CGFloat)indentDistance:(NSUInteger)indentLevel
{
    return indentLevel * _indent * _fontSize;
}

@end
