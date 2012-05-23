//
//  SingleModel.h
//  MyVeryLife
//
//  Created by Rock on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopItemModel.h"
#import "TopOrderModel.h"
#import "TopTradeModel.h"

#import "Utility.h"
#import "AppConstant.h"

#import "DataBase.h"

typedef enum{
    TAOBAO_PARSE_START,
    TAOBAO_PARSE_ITEM,
    TAOBAO_PARSE_TRADE,
    TAOBAO_PARSE_TRADE_ORDER,
    TAOBAO_PARSE_ITEM_VAL,
    TAOBAO_PARSE_END
}TaobaoPraseState;

typedef enum{
    TAOBAO_TRADE_TODAY,
    TAOBAO_TRADE_YESTERDAY,
    TAOBAO_TRADE_WEEK,
    TAOBAO_TRADE_MONTH,
    TAOBAO_TRADE_PERIOD
}TaobaoTradeMode;

@protocol TaobaoDataDelegate;
@interface TopData : NSObject <NSXMLParserDelegate> {
    __unsafe_unretained id _delegate;
    TopItemModel * curItem;                 //当前商品
    TopTradeModel * curTrade;                  //当前交易
    TopOrderModel * curOrder;               //当前订单

    TaobaoPraseState _parseState;      //XML
    TaobaoTradeMode _tradeMode;         //Trade
    
    BOOL            _refreshing;        //
    int             _total_count;       
    int             _get_count;
    
    int             _page_count;
    NSDate *        startTime;
    NSDate *        endTime;
    BOOL            _has_next;
    
}

@property(nonatomic,unsafe_unretained)id<TaobaoDataDelegate> delegate;
@property(nonatomic,retain)TopItemModel * curItem;
@property(nonatomic,retain)TopTradeModel * curTrade;
@property(nonatomic,strong)TopOrderModel * curOrder;

@property(nonatomic,strong)NSString * currentElement;

@property(nonatomic,strong)NSMutableArray * errList;

+ (TopData *)getTopData;

//刷新
-(void)putSession:(NSString *) session;      //
-(void)refreshItems;    //异步方法
-(void)refreshTrades;   //异步方法
-(void)valifiedItems;   //

//获取
-(NSMutableArray *)getItems;

-(NSMutableArray *)getTradesFrom:(NSDate *)start to:(NSDate *)end;

-(NSMutableArray *)getUnSentTrades;


//inner
@end

@protocol TaobaoDataDelegate
@optional
-(void) notifyItemRefresh:(BOOL)isFinished withTag:(NSString*) tag;
-(void) notifyItemValidRefresh:(BOOL)isFinished withTag:(NSString*) tag;
-(void) notifyTradeRefresh:(BOOL)isFinished withTag:(NSString*) tag;
@end
