PhotoBrowser
============
    LXPhotoBrowserViewController *controller = [[LXPhotoBrowserViewController alloc]init];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.photos.count];
    for (int i=0;i<self.photos.count;i++) {
        LXPhotoBrowserModel *model = [[LXPhotoBrowserModel alloc]init];
        LXPhotoImageView *imageView = self.subviews[i];
        model.srcImageView = imageView;
        NSString *photoUrl = [self.photos[i][@"thumbnail_pic"]];
        model.urlString = photoUrl;
        [arr addObject:model];
    }
    [controller showPhotoBrowserWithPhotoList:arr photoIndex:recognizer.view.tag];
