//
//  BYDataHandleManager.m
//  BYStat
//
//  Created by 许龙 on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "BYStatDataHandleManager.h"
#import <UIKit/UIKit.h>
#import "BYStatUploadDataMerger.h"
#import "BYStatUploadManager.h"
#import "BYStatNetworkReachabilityManager.h"
#import "BYStatThreadForSqliteHandle.h"
#import "BYStatPageLogModel.h"
#import "BYStatAccountLogModel.h"
#import "BYStatApplicationLogModel.h"
#import "NSMutableDictionary+BYStatSetObject.h"
#import "NSData+BYStatGZIP.h"

@interface BYStatDataHandleManager()

/**
 用ViewControllerId作为Key, BYPageLogMode作为Value
 页面开始时间保存，等有结束时间的时候，取出一起传给下一层，然后删除
 值保留top一个数据
 当设置的时候已经存在该Key，则更新此Key
 */
@property (nonatomic, strong) NSMutableDictionary *pageStartInfoDictionary;

/**
 最新统计的页面开始Model
 */
@property (nonatomic, strong) BYStatPageLogModel *lastBeginPageLogModel;

/**
 记录自己监听应用打开信息Model
 */
@property (nonatomic, strong) BYStatApplicationLogModel *byDataHandleApplicationOpenModel;

/**
 记录用户的登录信息的Model
 */
@property (nonatomic, strong) BYStatAccountLogModel *accountLogModel;

/**
 保存根据设备获取的基本信息，用来和从数据库中获取的基本信息做对比，来判断是否全部上传
 */
@property (nonatomic, strong) NSMutableDictionary *basicInfoDictionary;

/**
 保存从数据库获取的统计信息
 其中只有7个Key，因为只有7张表
 Key都是定义好的宏
 */
@property (nonatomic, strong) NSMutableDictionary *allTablesDataDictionary;

/**
 是否正在上传数据
 */
@property (nonatomic, assign) BOOL isUploading;


@end

//qa测试环境
#define  kBYStatQaUploadUrl  @"https://qalog.iqdnet.com/api/json/collect/collectClickRateByStr"
//boss线上环境
#define  kBYStatBossUploadUrl  @"https://log.iqdnet.com/api/json/collect/collectClickRateByStr"


@implementation BYStatDataHandleManager

#pragma mark - 单例
+ (instancetype)shareDataHandleManager {
    static BYStatDataHandleManager *dataHandleManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataHandleManager = [[BYStatDataHandleManager alloc] init];
        [dataHandleManager listentNetworkStatus];
        [dataHandleManager registerNotification];
    });
    return dataHandleManager;
}

#pragma mark - 注册通知
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name: UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark 通知方法实现
- (void)didEnterBackground {
    [self handleEndPageByApplicationClose];
    [self byDataHandleCloseApplicationWithAdditionalInfo:nil];
}

- (void)willEnterForeground {
    [self handleBeginPageByApplicationOpen];
    [self byDataHandleOpenApplicationWithAdditionalInfo:nil];
}


#pragma mark - 监听网络
- (void)listentNetworkStatus {
    BYStatNetworkReachabilityManager *netManager = [BYStatNetworkReachabilityManager sharedManager];
    
    __weak typeof(self) weakSelf = self;
    [netManager setReachabilityStatusChangeForAccessNameBlock:^(NSString * _Nonnull accessName) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        BYStatLog(accessName);
        [strongSelf handleNetWork:accessName additionalInfo:nil];
    }];
     
    [netManager startMonitoring];
}


#pragma mark - 基本信息统计
- (void)handleConfigureBasicInfoWithApplicationName:(NSString *)applicationKey applicationChannel:(NSString *)applicationChannel {
    [self.basicInfoDictionary removeAllObjects];
    NSDictionary *basicInfo = [[BYStatUploadDataMerger shareDataMerger] getDeviceBasicInfo];
    [self.basicInfoDictionary setDictionary:basicInfo];
    //这个方法中只做保存 上传成功后，再去保存
    NSString *tempApplicationKey = [applicationKey stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (tempApplicationKey == nil || tempApplicationKey.length <= 0) {
        BYStatWarnLog(@"ApplicationKey 不能为空或者空格");
        return;
    }
    
    if (applicationChannel == nil || applicationChannel.length <= 0) {
        applicationChannel = kBYSTApplicationChannelDefaultValue;
    }
    
    [self.basicInfoDictionary byStat_setObject:applicationKey forKey:kBYSTApplicationKeyKey];
    [self.basicInfoDictionary byStat_setObject:applicationChannel forKey:kBYSTApplicationChannelKey];
    //获取数据库中最后一条登录信息
    __weak typeof(self)weakSelf = self;
    [self getLastAccountInfoDataWithSuccessBlock:^(BYStatInfoTableType type, id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (type == BYStatInfoTableTypeOfAccountInfo && [result isKindOfClass:[NSDictionary class]]
             && [result count] != 0) {
            NSData *additionalData = [result objectForKey:kBYSTAdditionalInfoKey];
            if ([additionalData isKindOfClass:[NSData class]]) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:additionalData options:NSJSONReadingMutableLeaves error:nil];
                [result byStat_setObject:dic forKey:kBYSTAdditionalInfoKey];
            }
            BYStatAccountLogModel *accountModel = [[BYStatAccountLogModel alloc] initDBLastRecordWithDic:result];
            NSTimeInterval sinceValue = [accountModel.signOffDate timeIntervalSinceDate:accountModel.signInDate];
            if (sinceValue == 0.0) {
                strongSelf.accountLogModel = accountModel;
            }
        }
    }];
    [self byDataHandleOpenApplicationWithAdditionalInfo:nil];
}

#pragma mark - 应用统计
#pragma mark 用户统计应用打开
- (void)handleOpenApplicationWithAdditionalInfo:(NSDictionary *)additionalInfo {
    additionalInfo =[self judgeAdditionalInfoLogWarnWithTableName:BYStatInfoTableTypeOfApplicationInfo additionalInfo:additionalInfo];
    NSDate *openDate = [NSDate date];
    if (self.byDataHandleApplicationOpenModel == nil) {
        self.byDataHandleApplicationOpenModel = [[BYStatApplicationLogModel alloc] initWithOpenDate:openDate closeDate:openDate additionDic:additionalInfo];
    }else {
        [self.byDataHandleApplicationOpenModel.additionalDictionary removeAllObjects];
        [self.byDataHandleApplicationOpenModel.additionalDictionary addEntriesFromDictionary:additionalInfo ? additionalInfo : @{}];
    }
}

#pragma mark 自己监听应用打开
- (void)byDataHandleOpenApplicationWithAdditionalInfo:(NSDictionary *)additionalInfo {
    additionalInfo = [self judgeAdditionalInfoLogWarnWithTableName:BYStatInfoTableTypeOfApplicationInfo additionalInfo:additionalInfo];
    NSDate *openDate = [NSDate date];
    if (self.byDataHandleApplicationOpenModel == nil) {
        self.byDataHandleApplicationOpenModel = [[BYStatApplicationLogModel alloc] initWithOpenDate:openDate closeDate:openDate additionDic:additionalInfo];
    }else {
        self.byDataHandleApplicationOpenModel.openDate = openDate;
        self.byDataHandleApplicationOpenModel.closeDate = openDate;
    }
    NSDictionary *dic =  @{
                           kBYSTApplicationOpenTimeKey : openDate,
                           kBYSTApplicationCloseTimeKey : openDate,
                           kBYSTAdditionalInfoKey : self.byDataHandleApplicationOpenModel.additionalDictionary ? self.byDataHandleApplicationOpenModel.additionalDictionary : @{}
                           };
    [self insertDataToTable:BYStatInfoTableTypeOfApplicationInfo data:dic];
    //从后台启动上传
    [self handleUploadStatData];
}

#pragma mark 自己监听应用关闭
- (void)byDataHandleCloseApplicationWithAdditionalInfo:(NSDictionary *)additionalInfo {
    if (self.byDataHandleApplicationOpenModel != nil) {
        additionalInfo = [self judgeAdditionalInfoLogWarnWithTableName:BYStatInfoTableTypeOfApplicationInfo additionalInfo:additionalInfo];
        NSDate *closeDate = [NSDate date];
        [self.byDataHandleApplicationOpenModel.additionalDictionary addEntriesFromDictionary:additionalInfo ? additionalInfo : @{}];
        NSDictionary *dic = @{
                               kBYSTApplicationOpenTimeKey : self.byDataHandleApplicationOpenModel.openDate,
                               kBYSTApplicationCloseTimeKey : closeDate,
                               kBYSTAdditionalInfoKey : self.byDataHandleApplicationOpenModel.additionalDictionary ? self.byDataHandleApplicationOpenModel.additionalDictionary : @{}
                               };
        [self updateDataToTable:BYStatInfoTableTypeOfApplicationInfo data:dic];
        self.byDataHandleApplicationOpenModel = nil;
    }else {
        BYStatWarnLog(@"缺少应用的打开时间");
    }
    //进入后台上传
    [self handleUploadStatData];
}

#pragma mark - 页面统计
- (void)handleBeginLogPageView:(NSString *)pageID additionalInfo:(NSDictionary *)additionalInfo {
    NSString *tempPageId = [pageID stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSAssert(tempPageId != nil && tempPageId.length > 0, @"页面ID不能为nil、@\"\"、@\"  \"");
    if (tempPageId == nil || tempPageId.length == 0) {
        return;
    }
    if ([self.pageStartInfoDictionary.allKeys containsObject:pageID]) {
        BYStatWarnLog(@"该页面%@未关闭，又重新插入一条该页面ID的新纪录",pageID);
    }
    if (self.pageStartInfoDictionary.count > 10) {
        [self.pageStartInfoDictionary removeAllObjects];
    }
    additionalInfo = [self judgeAdditionalInfoLogWarnWithTableName:BYStatInfoTableTypeOfPageInfo additionalInfo:additionalInfo];
    NSDate *beginDate = [NSDate date];
    BYStatPageLogModel *pageModel = [[BYStatPageLogModel alloc] initWithPageId:pageID openTiem:beginDate closeTime:beginDate additionalInfo:additionalInfo];
    [self.pageStartInfoDictionary byStat_setObject:pageModel forKey:pageID];
    self.lastBeginPageLogModel = pageModel;
    NSDictionary *dic = @{
                          kBYSTPageIdKey : pageID ? pageID : @"",
                          kBYSTPageOpenTimeKey : beginDate,
                          kBYSTPageCloseTimeKey : beginDate,
                          kBYSTAdditionalInfoKey : additionalInfo ? additionalInfo : @{}
                          };
    [self insertDataToTable:BYStatInfoTableTypeOfPageInfo data:dic];
}

- (void)handleEndLogPageView:(NSString *)pageID additionalInfo:(NSDictionary *)additionalInfo {
    NSString *tempPageId = [pageID stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSAssert(tempPageId != nil && tempPageId.length > 0, @"页面ID不能为nil、@\"\"、@\"  \"");
    if (tempPageId == nil || tempPageId.length == 0) {
        return;
    }
    additionalInfo = [self judgeAdditionalInfoLogWarnWithTableName:BYStatInfoTableTypeOfPageInfo additionalInfo:additionalInfo];
    NSArray *keys = self.pageStartInfoDictionary.allKeys;
    if ([keys containsObject:pageID]) {
        if ([pageID isEqualToString:self.lastBeginPageLogModel.pageId]) {
            self.lastBeginPageLogModel = nil;
        }
        NSDate *endDate = [NSDate date];
        BYStatPageLogModel *pageModel = [self.pageStartInfoDictionary objectForKey:pageID];
        [pageModel.additionalInfo addEntriesFromDictionary:additionalInfo ? additionalInfo : @{}];
        NSDictionary *dic = @{
                              kBYSTPageIdKey : pageID ? pageID : @"",
                              kBYSTPageOpenTimeKey : pageModel.openTime,
                              kBYSTPageCloseTimeKey : endDate,
                              kBYSTAdditionalInfoKey : pageModel.additionalInfo
                              };
        [self.pageStartInfoDictionary removeObjectForKey:pageID];
        [self updateDataToTable:BYStatInfoTableTypeOfPageInfo data:dic];
    }else {
        BYStatWarnLog(@"缺少该页面-%@的打开时间统计",pageID);
    }
}

#pragma mark 应用进入到前台的时候，发送保存最后统计、未关闭页面的数据给数据库
- (void)handleBeginPageByApplicationOpen {
    if (self.lastBeginPageLogModel != nil) {
        NSDate *beginDate = [NSDate date];
        BYStatPageLogModel *tempPageModel = [self.pageStartInfoDictionary objectForKey:self.lastBeginPageLogModel.pageId];
        tempPageModel.openTime = beginDate;
        tempPageModel.closeTime = beginDate;
        NSDictionary *dic = @{
                              kBYSTPageIdKey : self.lastBeginPageLogModel.pageId ? self.lastBeginPageLogModel.pageId : @"",
                              kBYSTPageOpenTimeKey : beginDate,
                              kBYSTPageCloseTimeKey : beginDate,
                              kBYSTAdditionalInfoKey : self.lastBeginPageLogModel.additionalInfo
                              };
        [self insertDataToTable:BYStatInfoTableTypeOfPageInfo data:dic];
    }
}

#pragma mark 应用结束或者进入到后台的时候，把未关闭、最后统计页面的结束时间补齐
- (void)handleEndPageByApplicationClose {
    if (self.lastBeginPageLogModel != nil) {
        NSDate *endDate = [NSDate date];
        NSDictionary *dic = @{
                              kBYSTPageIdKey : self.lastBeginPageLogModel.pageId ? self.lastBeginPageLogModel.pageId : @"",
                              kBYSTPageOpenTimeKey : self.lastBeginPageLogModel.openTime,
                              kBYSTPageCloseTimeKey : endDate,
                              kBYSTAdditionalInfoKey : self.lastBeginPageLogModel.additionalInfo
                              };
        [self updateDataToTable:BYStatInfoTableTypeOfPageInfo data:dic];
    }
}

#pragma mark - 帐号统计
- (void)handleSignInWithUserId:(NSString *)userId provider:(NSString *)provider additionalInfo:(NSDictionary *)additionalInfo {
    NSString *tempUserId = [userId stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSAssert(tempUserId != nil && tempUserId.length > 0, @"帐号ID不能为nil、@\"\"、@\"  \"");
    if (tempUserId == nil || tempUserId.length == 0) {
        return;
    }
    if (self.accountLogModel) {
        NSString *userID = self.accountLogModel.userId;
        BYStatWarnLog(@"上次登录的用户ID：%@未更新登出事件，此条新的登录信息也会插入到统计信息里",userID);
    }
    additionalInfo = [self judgeAdditionalInfoLogWarnWithTableName:BYStatInfoTableTypeOfAccountInfo additionalInfo:additionalInfo];
    NSDate *currentDate = [NSDate date];
    BYStatAccountLogModel *accountModel = [[BYStatAccountLogModel alloc] initWithUserId:userId provider:provider signInDate:currentDate signOffDate:currentDate additionalInfo:additionalInfo];
    NSDictionary *dic = @{
                          kBYSTUserIdKey : userId ? userId : @"",
                          kBYSTProviderKey : provider ? provider : @"",
                          kBYSTSignInTimeKey : currentDate,
                          kBYSTSignOffTimeKey : currentDate,
                          kBYSTAdditionalInfoKey : additionalInfo ? additionalInfo : @{}
                          };
    self.accountLogModel = accountModel;
    [self insertDataToTable:BYStatInfoTableTypeOfAccountInfo data:dic];
}

- (void)handleSignOffWithAdditionalInfo:(NSDictionary *)additionalInfo {
    if (self.accountLogModel == nil) {
        BYStatWarnLog(@"缺少该用户的登录时间统计");
        return;
    }
    additionalInfo = [self judgeAdditionalInfoLogWarnWithTableName:BYStatInfoTableTypeOfAccountInfo additionalInfo:additionalInfo];
    NSDate *signOffDate = [NSDate date];

    [self.accountLogModel.additionalInfo addEntriesFromDictionary:additionalInfo ? additionalInfo : @{}];
    NSDictionary *dic = @{
                          kBYSTUserIdKey : self.accountLogModel.userId ? self.accountLogModel.userId : @"",
                          kBYSTProviderKey : self.accountLogModel.provider ? self.accountLogModel.provider : @"",
                          kBYSTSignInTimeKey : self.accountLogModel.signInDate,
                          kBYSTSignOffTimeKey : signOffDate,
                          kBYSTAdditionalInfoKey : self.accountLogModel.additionalInfo ? self.accountLogModel.additionalInfo : @{}
                          };
    self.accountLogModel = nil;
    [self updateDataToTable:BYStatInfoTableTypeOfAccountInfo data:dic];
}

#pragma mark - 事件统计
- (void)handleEvent:(NSString *)eventId additionalInfo:(NSDictionary *)additionalInfo {
    NSString *tempEventId = [eventId stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSAssert(tempEventId != nil && tempEventId.length > 0, @"事件ID不能为nil、@\"\"、@\"  \"");
    if (tempEventId == nil || tempEventId.length == 0) {
        return;
    }
    additionalInfo = [self judgeAdditionalInfoLogWarnWithTableName:BYStatInfoTableTypeOfEventInfo additionalInfo:additionalInfo];
    NSDictionary *dic = @{
                          kBYSTEventIdKey : eventId ? eventId : @"",
                          kBYSTEventHappenTimeKey : [NSDate date],
                          kBYSTAdditionalInfoKey : additionalInfo ? additionalInfo : @{}
                          };
    [self insertDataToTable:BYStatInfoTableTypeOfEventInfo data:dic];
}

#pragma mark - 位置统计
- (void)handlePositionLatitude:(double)latitude longitude:(double)longitude additionalInfo:(NSDictionary *)additionalInfo {
    additionalInfo = [self judgeAdditionalInfoLogWarnWithTableName:BYStatInfoTableTypeOfPositionInfo additionalInfo:additionalInfo];
    NSDictionary *dic = @{
                          kBYSTLongitudeKey : @(longitude),
                          kBYSTLatitudeKey : @(latitude),
                          kBYSTPositionChangeTimeKey : [NSDate date],
                          kBYSTAdditionalInfoKey : additionalInfo ? additionalInfo : @{}
                          };
    [self insertDataToTable:BYStatInfoTableTypeOfPositionInfo data:dic];
}


#pragma mark - 网络统计
- (void)handleNetWork:(NSString *)network additionalInfo:(NSDictionary *)additionalInfo {
    NSDictionary *dic = @{
                          kBYSTNetworkTypeKey : network ? network : @"",
                          kBYSTNetworkChangeTimeKey : [NSDate date],
                          kBYSTAdditionalInfoKey : additionalInfo ? additionalInfo : @{}
                          };
    [self insertDataToTable:BYStatInfoTableTypeOfNetworkInfo data:dic];
}

#pragma mark - 上传数据
- (void)handleUploadStatData {
    
    if (self.isUploading) {
        return;
    }
    self.isUploading = YES;
    
    //上传之前删除指定多少天之前的数据
    [self deleteAllTableDataBeforeDays:kValidRecordDuration];
    
    __weak typeof(self) weakSelf = self;
    [self getDataWith:BYStatInfoTableTypeOfBaseInfo successBlock:^(BYStatInfoTableType type, id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.allTablesDataDictionary byStat_setObject:result forKey:kBYSTStatUploadBasicInfoTableKey];
    }];
    
    [self getDataWith:BYStatInfoTableTypeOfApplicationInfo successBlock:^(BYStatInfoTableType type, id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.allTablesDataDictionary byStat_setObject:result forKey:kBYSTStatUploadApplicationInfoTableKey];
    }];
    
    [self getDataWith:BYStatInfoTableTypeOfPageInfo successBlock:^(BYStatInfoTableType type, id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.allTablesDataDictionary byStat_setObject:result forKey:kBYSTStatUploadPageInfoTableKey];
    }];
    
    [self getDataWith:BYStatInfoTableTypeOfAccountInfo successBlock:^(BYStatInfoTableType type, id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.allTablesDataDictionary byStat_setObject:result forKey:kBYSTStatUploadAccountInfoTableKey];
    }];
    
    [self getDataWith:BYStatInfoTableTypeOfEventInfo successBlock:^(BYStatInfoTableType type, id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.allTablesDataDictionary byStat_setObject:result forKey:kBYSTStatUploadEventInfoTableKey];
    }];
    
    [self getDataWith:BYStatInfoTableTypeOfPositionInfo successBlock:^(BYStatInfoTableType type, id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.allTablesDataDictionary byStat_setObject:result forKey:kBYSTStatUploadPositionInfoTableKey];
    }];
    
    //获取数据是一个串行队列，所以在最后一个表的时候上传数据
    [self getDataWith:BYStatInfoTableTypeOfNetworkInfo successBlock:^(BYStatInfoTableType type, id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.allTablesDataDictionary byStat_setObject:result forKey:kBYSTStatUploadNetworkInfoTableKey];
        //数据全部获取完成 多数据进行加工 然后上传操作
        [strongSelf uploadData];
    }];
}

#pragma mark 上传
- (void)uploadData {
    
    [self judgeAllUploadBasicInfo];
    
    NSString *uploadUrl = kBYStatBossUploadUrl;
    if (self.byStatDebug) {
        uploadUrl = kBYStatQaUploadUrl;
    }
    
    //上传JSON模型及header设置需要 AK  SDKV 两个字段
    NSDictionary *headerDic = @{
                                kBYSTApplicationKeyKey_short : [self.basicInfoDictionary objectForKey:kBYSTApplicationKeyKey],
                                kBYSTSDKVersionKey_short : [self.basicInfoDictionary objectForKey:kBYSTSDKVersionKey],
                                @"Content-Encoding": @"gzip"
                                };
    
    NSDictionary *logsValueDic = [[BYStatUploadDataMerger shareDataMerger] convertDataToUploadDataWith:self.allTablesDataDictionary];
    NSString *logsValueJsonString = [[BYStatUploadDataMerger shareDataMerger] convertOriginJSONStringWith:logsValueDic];
    NSDictionary *logsDic =@{
                             @"logs" : logsValueJsonString ? logsValueJsonString : @""
                             };
    NSString *bodyJsonString = [[BYStatUploadDataMerger shareDataMerger] convertOriginJSONStringWith:logsDic];
    NSString *addiBody = [NSString stringWithFormat:@"body=%@",bodyJsonString];
    NSData *addiBodyData = [addiBody dataUsingEncoding:NSUTF8StringEncoding];
    NSData *zipedData = [addiBodyData gzippedDataWithCompressionLevel:1];

    __weak typeof(self) weakSelf = self;
    [BYStatUploadManager postRequestUploadDataWithUrl:uploadUrl header:headerDic body:zipedData success:^(NSData *data) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        NSError *error;
        NSDictionary *responDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error == nil && [responDic isKindOfClass:[NSDictionary class]]) {
            if ([[NSString stringWithFormat:@"%@",[responDic objectForKey:@"code"]] isEqualToString:@"200"]) {
                //上传成功
                BYStatLog(@"upload success");
                //上传成功后1.把新获取的设备信息保存到本地数据库
                [strongSelf insertDataToTable:BYStatInfoTableTypeOfBaseInfo data:strongSelf.basicInfoDictionary];
                //2.删除其它表已经上传的数据
                [strongSelf deleteDataAfterUploadSuccess];
            }
        }
        strongSelf.allTablesDataDictionary = nil;
        strongSelf.isUploading = NO;
    } failure:^(NSError *error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        BYStatLog(@"upload fail:");
        BYStatLog(error);
        //失败清空字典
        strongSelf.allTablesDataDictionary = nil;
        strongSelf.isUploading = NO;
    }];
}

#pragma mark 上传成功后删除数据
- (void)deleteDataAfterUploadSuccess {
    //应用信息表 需要保留最后一条
    NSMutableArray *applicationInfoArray = [NSMutableArray arrayWithArray:[self.allTablesDataDictionary objectForKey:kBYSTStatUploadApplicationInfoTableKey]];
    if (applicationInfoArray.count >= 1) {
        NSDictionary *lastDic = applicationInfoArray.lastObject;
        double openDate = [[lastDic objectForKey:kBYSTApplicationOpenTimeKey] doubleValue];
        double closeDate = [[lastDic objectForKey:kBYSTApplicationCloseTimeKey] doubleValue];
        if (closeDate == openDate) {
            [applicationInfoArray removeObjectAtIndex:(applicationInfoArray.count - 1)];
        }
    }
    [self deleteData:applicationInfoArray tableType:BYStatInfoTableTypeOfApplicationInfo];
    
    //帐号信息表 判断最后一条的登录时间和登出时间是否一样 一样：从删除的数据中剔除掉，让数据库保留该条记录
    NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[self.allTablesDataDictionary objectForKey:kBYSTStatUploadAccountInfoTableKey]];
    if (accountInfoArray.count >= 1) {
        NSDictionary *lastDic = accountInfoArray.lastObject;
        double signInDate = [[lastDic objectForKey:kBYSTSignInTimeKey] doubleValue];
        double signOffDate = [[lastDic objectForKey:kBYSTSignOffTimeKey] doubleValue];
        if (signOffDate == signInDate) {
            [accountInfoArray removeObjectAtIndex:(accountInfoArray.count - 1)];
        }
    }
    [self deleteData:accountInfoArray tableType:BYStatInfoTableTypeOfAccountInfo];
    
    //页面信息表 判断最后一条的登录时间和登出时间是否一样 一样：从删除的数据中剔除掉，让数据库保留该条记录
    NSMutableArray *pageInfoArray = [NSMutableArray arrayWithArray:[self.allTablesDataDictionary objectForKey:kBYSTStatUploadPageInfoTableKey]];
    if (pageInfoArray.count >= 1) {
        NSDictionary *lastDic = pageInfoArray.lastObject;
        double pageOpenDate = [[lastDic objectForKey:kBYSTPageOpenTimeKey] doubleValue];
        double pageCloseDate = [[lastDic objectForKey:kBYSTPageCloseTimeKey] doubleValue];
        if (pageCloseDate == pageOpenDate) {
            [pageInfoArray removeObjectAtIndex:(pageInfoArray.count - 1)];
        }
    }
    [self deleteData:pageInfoArray tableType:BYStatInfoTableTypeOfPageInfo];
    
    //事件
    NSMutableArray *eventInfoArray = [NSMutableArray arrayWithArray:[self.allTablesDataDictionary objectForKey:kBYSTStatUploadEventInfoTableKey]];
    [self deleteData:eventInfoArray tableType:BYStatInfoTableTypeOfEventInfo];
    
    //位置
    NSMutableArray *positionInfoArray = [NSMutableArray arrayWithArray:[self.allTablesDataDictionary objectForKey:kBYSTStatUploadPositionInfoTableKey]];
    [self deleteData:positionInfoArray tableType:BYStatInfoTableTypeOfPositionInfo];
    
    //网络
    NSMutableArray *networkInfoArray = [NSMutableArray arrayWithArray:[self.allTablesDataDictionary objectForKey:kBYSTStatUploadNetworkInfoTableKey]];
    [self deleteData:networkInfoArray tableType:BYStatInfoTableTypeOfNetworkInfo];
}

#pragma mark 判断获取设备的基本信息和从数据库中取出的基本信息是否改变
/**
 等上传启动成功后再获取本地数据库中的基本信息表，做比较，然后增量上传
 增量上传：设备ID变了的时候，全传； 如果设备ID没变，就只上传改变的字段；
 */
- (void)judgeAllUploadBasicInfo {
    //现在不做增量上传，都全部上传
    [self.allTablesDataDictionary byStat_setObject:self.basicInfoDictionary forKey:kBYSTStatUploadBasicInfoTableKey];
    
    /*
    NSDictionary *dbBasicInfoDic = [self.allTablesDataDictionary objectForKey:kBYSTStatUploadBasicInfoTableKey];
    if (![[dbBasicInfoDic objectForKey:kBYSTDeviceIdKey] isEqualToString:[self.basicInfoDictionary objectForKey:kBYSTDeviceIdKey]]) {
        //全部上传
        [self.allTablesDataDictionary byStat_setObject:self.basicInfoDictionary forKey:kBYSTStatUploadBasicInfoTableKey];
    }else {
        //部分上传
        NSDictionary *changeDic = [self getChangedBasicInfoValue];
        [self.allTablesDataDictionary byStat_setObject:changeDic forKey:kBYSTStatUploadBasicInfoTableKey];
    }
     */
}

#pragma mark 获取改变的值
- (NSDictionary *)getChangedBasicInfoValue {
    NSMutableDictionary *changeDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDictionary *dbBasicInfoDic = [self.allTablesDataDictionary objectForKey:kBYSTStatUploadBasicInfoTableKey];
    for (NSString *key in self.basicInfoDictionary.allKeys) {
        if (![[dbBasicInfoDic objectForKey:key] isEqualToString:[self.basicInfoDictionary objectForKey:key]]) {
            [changeDic byStat_setObject:[self.basicInfoDictionary objectForKey:key] forKey:key];
        }
    }
    return changeDic;
}

#pragma mark - 共同AdditionalInfo警告信息
/**
 判断additionalInfo是否需要打印警告信息，根据value是否符合BYST格式标准

 @param tableType BYStatInfoTableType
 @param additionalInfo 用户传的额外的字典
 @return BYST标准字典
 */
- (NSDictionary *)judgeAdditionalInfoLogWarnWithTableName:(BYStatInfoTableType )tableType additionalInfo:(NSDictionary *)additionalInfo {
    if (![[BYStatUploadDataMerger shareDataMerger] judgeDicValueIsStandardTypeWith:additionalInfo]) {
        NSString *tableName = [[BYStatUploadDataMerger shareDataMerger] getLogTableNameWith:tableType];
        tableName = tableName ? tableName : @"";
        BYStatWarnLog(@"%@additionalInfo所传字典非BYST标准的格式:%@",tableName, additionalInfo);
        return [[BYStatUploadDataMerger shareDataMerger] ignoreNotBYAdditionStandardTypeWith:additionalInfo];
    }
    return additionalInfo;
}

#pragma mark - 关闭监听：网络监听和应用打开和关闭的监听
- (void)closeListenApplicationAndNetwork {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    BYStatNetworkReachabilityManager *netManager = [BYStatNetworkReachabilityManager sharedManager];
    [netManager stopMonitoring];
}


#pragma mark - Get
- (NSMutableDictionary *)pageStartInfoDictionary {
    if (!_pageStartInfoDictionary) {
        _pageStartInfoDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _pageStartInfoDictionary;
}

- (NSMutableDictionary *)allTablesDataDictionary {
    if (!_allTablesDataDictionary) {
        _allTablesDataDictionary = [NSMutableDictionary dictionaryWithCapacity:7];
    }
    return _allTablesDataDictionary;
}

- (NSMutableDictionary *)basicInfoDictionary {
    if (!_basicInfoDictionary) {
        _basicInfoDictionary = [NSMutableDictionary dictionaryWithCapacity:14];
    }
    return _basicInfoDictionary;
}

@end

#pragma mark - 分类 ：插入数据
@implementation BYStatDataHandleManager (InsertData)

- (void)insertDataToTable:(BYStatInfoTableType)tableType data:(NSDictionary *)dataDic {
    switch (tableType) {
        case BYStatInfoTableTypeOfBaseInfo:
            [self insertData:dataDic selector:@selector(insertRecordToBaseInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfApplicationInfo:
            [self insertData:dataDic selector:@selector(insertRecordToApplicationInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfAccountInfo:
            [self insertData:dataDic selector:@selector(insertRecordToAccountInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfPageInfo:
            [self insertData:dataDic selector:@selector(insertRecordToPageInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfEventInfo:
            [self insertData:dataDic selector:@selector(insertRecordToEventInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfPositionInfo:
            [self insertData:dataDic selector:@selector(insertRecordToPositionInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfNetworkInfo:
            [self insertData:dataDic selector:@selector(insertRecordToNetworkInfoTableWithParam:)];
            break;
            
        default:
            break;
    }
}

- (void)insertData:(NSDictionary *)dataDic selector:(SEL)selector {
    BYStatSqliteHandleCoordinator *share = [BYStatSqliteHandleCoordinator sharedSqliteHandleCoordinator];
    BYStatThreadForSqliteHandle *threadShare = [BYStatThreadForSqliteHandle sharedThreadForSqliteHandle];
    [share performSelector:selector onThread:threadShare withObject:dataDic waitUntilDone:NO];
}

@end

#pragma mark - 分类 ：更新数据
@implementation BYStatDataHandleManager (UpdateData)

- (void)updateDataToTable:(BYStatInfoTableType)tableType data:(NSDictionary *)dataDic {
    switch (tableType) {
        case BYStatInfoTableTypeOfBaseInfo:
            //基本信息无更新操作
            break;
        case BYStatInfoTableTypeOfApplicationInfo:
            [self updateData:dataDic selector:@selector(updateRecordToApplicationInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfAccountInfo:
            [self updateData:dataDic selector:@selector(updateRecordToAccountInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfPageInfo:
            [self updateData:dataDic selector:@selector(updateRecordToPageInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfEventInfo:
            //事件无更新操作
            break;
        case BYStatInfoTableTypeOfPositionInfo:
            //位置无更新操作
            break;
        case BYStatInfoTableTypeOfNetworkInfo:
            //网络状态无更新操作
            break;
            
        default:
            break;
    }
}

- (void)updateData:(NSDictionary *)dataDic selector:(SEL)selector {
    BYStatSqliteHandleCoordinator *share = [BYStatSqliteHandleCoordinator sharedSqliteHandleCoordinator];
    BYStatThreadForSqliteHandle *threadShare = [BYStatThreadForSqliteHandle sharedThreadForSqliteHandle];
    [share performSelector:selector onThread:threadShare withObject:dataDic waitUntilDone:NO];
}


@end

#pragma mark - 分类 ：从数据库获取数据

@implementation BYStatDataHandleManager (GetData)

- (void)getDataWith:(BYStatInfoTableType)tableType successBlock:(sqliteHandleCallback)successBlock {
    switch (tableType) {
        case BYStatInfoTableTypeOfBaseInfo:
            [self queryDataWith:@selector(queryRecordFromBaseInfoTableWithParam: ) successBlock:successBlock];
            break;
        case BYStatInfoTableTypeOfApplicationInfo:
            [self queryDataWith:@selector(queryRecordFromApplicationInfoTableWithParam: ) successBlock:successBlock];
            break;
        case BYStatInfoTableTypeOfAccountInfo:
            [self queryDataWith:@selector(queryRecordFromAccountInfoTableWithParam:) successBlock:successBlock];
            break;
        case BYStatInfoTableTypeOfPageInfo:
            [self queryDataWith:@selector(queryRecordFromPageInfoTableWithParam: ) successBlock:successBlock];
            break;
        case BYStatInfoTableTypeOfEventInfo:
            [self queryDataWith:@selector(queryRecordFromEventInfoTableWithParam: ) successBlock:successBlock];
            break;
        case BYStatInfoTableTypeOfPositionInfo:
            [self queryDataWith:@selector(queryRecordFromPositionInfoTableWithParam: ) successBlock:successBlock];
            break;
        case BYStatInfoTableTypeOfNetworkInfo:
            [self queryDataWith:@selector(queryRecordFromNetworkInfoTableWithParam: ) successBlock:successBlock];
            break;
            
        default:
            break;
    }
}

- (void)queryDataWith:(SEL)queryFunction successBlock:(sqliteHandleCallback )callback {
    BYStatSqliteHandleCoordinator *share = [BYStatSqliteHandleCoordinator sharedSqliteHandleCoordinator];
    BYStatThreadForSqliteHandle *threadShare = [BYStatThreadForSqliteHandle sharedThreadForSqliteHandle];
    NSDictionary *object =@{kBYSTSqliteHandleCallback: callback};
    [share performSelector:queryFunction onThread:threadShare withObject:object waitUntilDone:NO];
}

- (void)getLastAccountInfoDataWithSuccessBlock:(sqliteHandleCallback)successBlock {
    BYStatSqliteHandleCoordinator *share = [BYStatSqliteHandleCoordinator sharedSqliteHandleCoordinator];
    BYStatThreadForSqliteHandle *threadShare = [BYStatThreadForSqliteHandle sharedThreadForSqliteHandle];
    NSDictionary *object =@{kBYSTSqliteHandleCallback: successBlock};
    [share performSelector:@selector(queryLastRecordFromAccountInfoTableWithParam:) onThread:threadShare withObject:object waitUntilDone:NO];
}

@end


#pragma mark - 分类 ：从数据库删除数据

@implementation BYStatDataHandleManager (DeleteData)

- (void)deleteAllTableDataBeforeDays:(NSInteger )beforeDay {
    BYStatSqliteHandleCoordinator *share = [BYStatSqliteHandleCoordinator sharedSqliteHandleCoordinator];
    BYStatThreadForSqliteHandle *threadShare = [BYStatThreadForSqliteHandle sharedThreadForSqliteHandle];
    [share performSelector:@selector(deleteRecordOfSomeDaysAgo:) onThread:threadShare withObject:[NSNumber numberWithInteger:beforeDay] waitUntilDone:NO];
}

- (void)deleteData:(NSArray *)dataArray tableType:(BYStatInfoTableType)tableType {
    if (!dataArray && dataArray.count <= 0) {
        return;
    }
    switch (tableType) {
        case BYStatInfoTableTypeOfApplicationInfo:
            [self deleteData:dataArray selector:@selector(deleteRecordFromApplicationInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfAccountInfo:
            [self deleteData:dataArray selector:@selector(deleteRecordFromAccountInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfPageInfo:
            [self deleteData:dataArray selector:@selector(deleteRecordFromPageInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfEventInfo:
            [self deleteData:dataArray selector:@selector(deleteRecordFromEventInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfPositionInfo:
            [self deleteData:dataArray selector:@selector(deleteRecordFromPositionInfoTableWithParam:)];
            break;
        case BYStatInfoTableTypeOfNetworkInfo:
            [self deleteData:dataArray selector:@selector(deleteRecordFromNetworkInfoTableWithParam:)];
            break;
            
        default:
            break;
    }
}

- (void)deleteData:(NSArray *)array selector:(SEL)selector {
    BYStatSqliteHandleCoordinator *share = [BYStatSqliteHandleCoordinator sharedSqliteHandleCoordinator];
    BYStatThreadForSqliteHandle *threadShare = [BYStatThreadForSqliteHandle sharedThreadForSqliteHandle];
    [share performSelector:selector onThread:threadShare withObject:array waitUntilDone:NO];
}

@end

