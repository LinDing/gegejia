//
//  HomePage.m
//  GeGeJia
//
//  Created by dinglin on 16/2/28.
//  Copyright © 2016年 dinglin. All rights reserved.
//

#import "HomePageViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>
#import <AFHTTPSessionManager.h>
#import "DataModels.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BannerView.h"
#import "ActivityCell.h"


static NSString *const kCellID = @"Cell";
static NSString *const kOnSaleCellID = @"OnSaleCell";


@interface HomePageViewController () <UITableViewDataSource, UITableViewDelegate>{

}



//内容
@property (nonatomic) UITableView *table;
@property (nonatomic) BannerView *banner;
@property (nonatomic) NSArray *hotList;
@property (nonatomic) NSArray *activityList;

@end

@implementation HomePageViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    _table = [UITableView new];
    _table.delegate = self;
    _table.dataSource = self;
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
    [_table registerClass:[ActivityCell class] forCellReuseIdentifier:kOnSaleCellID];

    
    __unsafe_unretained UITableView *tableView = _table;
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [tableView.mj_header endRefreshing];
        });
    }];
    tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [tableView.mj_footer endRefreshing];
        });
    }];
    
    
    


    [self.view addSubview:_table];
    [_table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _banner = [BannerView new];
    _banner.frame = CGRectMake(0, 0, 375, 100);
    
    _table.tableHeaderView = _banner;
    
    NSString *URLString = @"http://app.gegejia.com/yangege/appNative/resource/homeList";
    NSDictionary *parameters = @{@"os": @"1",
                                 @"params": @"{\"type\":\"124569\"}",
                                 @"remark": @"isVestUpdate35",
                                 @"sign": @"4435912AAF47B2C3",
                                 @"version": @"2.3"
                                 };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"%d, %@", __LINE__, uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BaseNSObject *base = [BaseNSObject modelObjectWithDictionary:responseObject];
        
        NSError *error;
        NSData *data = [base.params dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *paramDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        HomePageNSObject *homePage = [HomePageNSObject modelObjectWithDictionary:paramDic];
        
        //广告板
        _banner.bannerList = homePage.bannerList;
   
//        for (HomePageActivityList *activityList in homePage.activityList) {
//            NSLog(@"%@", activityList.title);
//            
//            for (HomePageContent *content in activityList.content) {
//                NSLog(@"%@", content);
//            }
//        }
        _activityList = homePage.activityList;
//        for (HomePageHotList *hotList in homePage.hotList) {
//            NSLog(@"%d, %@", __LINE__, hotList);
//        }
//        _hotList = homePage.hotList;
        
//        HomePageNowGegeRecommend *NowGegeRecommend = homePage.nowGegeRecommend;
//        NSLog(@"%@", NowGegeRecommend.title);
//        for (NSString *content in NowGegeRecommend.content) {
//            NSLog(@"%@", content);
//        }
        [_table reloadData];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败---%@", error);
    }];
   

}

#pragma mark - 内容
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((HomePageActivityList *)_activityList[section]).title;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return [((HomePageContent *)((HomePageActivityList *)_activityList[indexPath.section]).content[indexPath.row]).height floatValue]/2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [((HomePageActivityList *)_activityList[section]).content count];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_activityList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        ActivityCell *cell = [_table dequeueReusableCellWithIdentifier:kOnSaleCellID forIndexPath:indexPath];
        [cell.image sd_setImageWithURL:[NSURL URLWithString:((HomePageContent *)((HomePageActivityList *)_activityList[indexPath.section]).content[indexPath.row]).image]];
        return cell;
    } else {
        UITableViewCell *cell = [_table dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
        return cell;
    }
    
}

@end
