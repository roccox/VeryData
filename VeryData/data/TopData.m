//
//  SingleModel.m
//  MyVeryLife
//
//  Created by Rock on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopData.h"

static TopData *single = nil;

//TODO
static NSString   * _session = @"6102409a2d55dee1e15e3ab47c3b28dae3c048e2894371c74943896";

@implementation TopData

@synthesize delegate = _delegate;
@synthesize curItem,curTrade,currentElement,curOrder;


+ (TopData *)getTopData {
    if (single == nil) {
        single = [[TopData alloc] init];
    }
    return single;
}


//刷新
-(void)refreshItems    //异步方法
{
    if(_refreshing)
    {
        [self.delegate notifyItemRefresh:YES withTag:@"BUSY"];
        return;
    }
    
    _refreshing = YES;
    
    _get_count = 0;
    _total_count = 0;
    
    //New thread
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(getItemInfo:)
                                                   object:nil];
    [myThread start];
}

-(void)refreshTrades   //异步方法
{
    if(_refreshing)
    {
        [self.delegate notifyTradeRefresh:YES withTag:@"BUSY"];
        return;
    }
    //check session
    if(_session == nil)
    {
        [self.delegate notifyTradeRefresh:YES withTag:@"SESSION_MISSING"];
        return;
    }
        
    
    _refreshing = YES;
    
    _get_count = 0;

    _page_count = 1;
    
    _has_next = NO;

    //New thread
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(getTradeInfo:)
                                                   object:nil];
    [myThread start];
}

//获取
-(TopItemModel *)getTopItem:(int)index;
{
}

-(void)setTopTradeMode:(TaobaoTradeMode) mode
{
    _tradeMode = mode;
}

-(TopTradeModel *)getTopTrade:(int)index
{
    
}

//更新
-(BOOL)updateItemPrice:(double)price
{
    
}

-(BOOL)updateTradeFee:(double)fee
{
    
}

+(void)putSession:(NSString *) session
{
    _session = session;
}

//inner
-(void)notiyItemWithTag:(NSString *)tag
{
    
    if ([tag isEqualToString:@"OK"] || [tag isEqualToString:@"FAIL"]) 
        [self.delegate notifyItemRefresh:YES withTag:tag];
    else 
        [self.delegate notifyItemRefresh:NO withTag:tag];
     
}

-(void)notiyTradeWithTag:(NSString *)tag
{
    
    if ([tag isEqualToString:@"OK"] || [tag isEqualToString:@"FAIL"] || [tag isEqualToString:@"SESSION_MISSING"]) 
        [self.delegate notifyTradeRefresh:YES withTag:tag];
    else 
        [self.delegate notifyTradeRefresh:NO withTag:tag];
     
}


//inner
-(void)getItemInfo:(NSString *)page_no
{
    _parseState = TAOBAO_PARSE_START;

    if (self.curItem == nil) {
        self.curItem = [[TopItemModel alloc]init];
    }
    

    if(page_no == nil)
        page_no = @"1";


    //Get Items
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setObject:@"num_iid,title,volume,pic_url,price" forKey:@"fields"];
    [params setObject:@"podees" forKey:@"nicks"];
    [params setObject:@"volume:desc" forKey:@"order_by"];
    [params setObject:page_no  forKey:@"page_no"];
    [params setObject:@"volume:desc" forKey:@"order_by"];
    [params setObject:@"taobao.items.get" forKey:@"method"];
    
    NSData *resultData=[Utility getResultData:params];
    NSXMLParser *xmlParser=[[NSXMLParser alloc] initWithData:resultData];
    [xmlParser setDelegate:self];
    [xmlParser parse];      
    
}

-(NSDate *) prepareTradeParam
{
    if(_has_next)
    {
        _has_next = NO;
        _page_count++;
    }
    else
    {
        _page_count = 1;
    }
    startTime = [NSDate dateWithTimeIntervalSinceNow: -(24 * 60 * 60)];
    endTime = [[NSDate alloc]initWithTimeInterval:(2*60*60-1) sinceDate:startTime];
    NSLog(@"Time: %@",startTime);
}

-(void)getTradeInfo
{
    _parseState = TAOBAO_PARSE_START;
    
    if (self.curTrade == nil) {
        self.curTrade = [[TopTradeModel alloc]init];
        self.curTrade.orders = [[NSMutableArray alloc]init];
    }

    NSString * page_no = [[NSString alloc]initWithFormat:@"%d",_page_count];
    
    //get startTime and endTime, 
    [self prepareTradeParam];
    
    //Get Items
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setObject:@"tid,status,buyer_nick,receiver_name,receiver_city,discount_fee,adjust_fee,post_fee,total_fee,payment,received_payment,pay_time,created,modified,orders.num,orders.num_iid,orders.title,orders.sku_properties_name,orders.oid,orders.status,orders.pic_path,orders.price,orders.adjust_fee,orders.discount_fee,orders.total_fee,orders.payment" forKey:@"fields"];
    [params setObject:[startTime description] forKey:@"start_modified"];
    [params setObject:[endTime description] forKey:@"end_modified"];
    [params setObject:@"true" forKey:@"use_has_next"];
    [params setObject:page_no  forKey:@"page_no"];

    [params setObject:_session forKey:@"session"];
    [params setObject:@"taobao.trades.sold.increment.get" forKey:@"method"];
    
    NSData *resultData=[Utility getResultData:params];
    NSXMLParser *xmlParser=[[NSXMLParser alloc] initWithData:resultData];
    [xmlParser setDelegate:self];
    [xmlParser parse];      
    
}


#pragma mark - XML Parser
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.currentElement=elementName;

    if([self.currentElement isEqualToString:@"items_get_response"])
    {
        _parseState = TAOBAO_PARSE_ITEM;
        [self.curTrade.orders removeAllObjects];
    }
    else if([self.currentElement isEqualToString:@"trades_sold_increment_get_response"])
    {
        _parseState = TAOBAO_PARSE_TRADE;
    }
    else if([self.currentElement isEqualToString:@"order"])
    {
        _parseState = TAOBAO_PARSE_TRADE_ORDER;
        self.curOrder = [[TopOrderModel alloc]init];
    }
}
-(NSDate *) getDateFromString:(NSString*)string
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:string];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    switch (_parseState) {
        case TAOBAO_PARSE_ITEM:
            //商品列表
            if(![self.currentElement compare:@"num_iid"])
            {
                self.curItem.num_iid = [string longLongValue];
            }
            else if(![self.currentElement compare:@"title"])
            {
                self.curItem.title = string;
            }
            else if(![self.currentElement compare:@"volume"])
            {
                self.curItem.volume = [string intValue];
            }
            else if(![self.currentElement compare:@"pic_url"])
            {
                self.curItem.pic_url = string;
            }
            else if(![self.currentElement compare:@"price"])
            {
                self.curItem.price = [string intValue];
            }
            else if(![self.currentElement compare:@"total_results"])
            {
                _total_count=[string intValue];
            }
            break;
        case TAOBAO_PARSE_TRADE:
            //Trade信息
            if(![self.currentElement compare:@"has_next"])
            {
                _has_next = [string boolValue];
            }
            else if(![self.currentElement compare:@"tid"])
            {
                self.curTrade.tid = [string longLongValue];
            }
            else if(![self.currentElement compare:@"status"])
            {
                self.curTrade.status = string;
            }
            else if(![self.currentElement compare:@"buyer_nick"])
            {
                self.curTrade.buyer_nick = string;
            }
            else if(![self.currentElement compare:@"receiver_name"])
            {
                self.curTrade.receiver_name = string;
            }
            else if(![self.currentElement compare:@"receiver_city"])
            {
                self.curTrade.receiver_city = string;
            }
            else if(![self.currentElement compare:@"discount_fee"])
            {
                self.curTrade.discount_fee = [string doubleValue];
            }
            else if(![self.currentElement compare:@"adjust_fee"])
            {
                self.curTrade.adjust_fee = [string doubleValue];
            }
            else if(![self.currentElement compare:@"post_fee"])
            {
                self.curTrade.post_fee = [string doubleValue];
            }
            else if(![self.currentElement compare:@"total_fee"])
            {
                self.curTrade.total_fee = [string doubleValue];
            }
            else if(![self.currentElement compare:@"payment"])
            {
                self.curTrade.payment = [string doubleValue];
            }
            else if(![self.currentElement compare:@"pay_time"])
            {
                self.curTrade.paymentTime = [self getDateFromString:string];
            }
            else if(![self.currentElement compare:@"created"])
            {
                self.curTrade.createdTime = [self getDateFromString:string];
            }
            else if(![self.currentElement compare:@"modified"])
            {
                self.curTrade.modifiedTime = [self getDateFromString:string];
            }
            break;
        case TAOBAO_PARSE_TRADE_ORDER:
            //商品信息
            if(![self.currentElement compare:@"num"])
            {
                self.curOrder.num =[string intValue];
            }
            else if(![self.currentElement compare:@"num_iid"])
            {
                self.curOrder.num_iid =[string longLongValue];
            }
            else if(![self.currentElement compare:@"title"])
            {
                self.curOrder.title = string;
            }
            else if(![self.currentElement compare:@"sku_properties_name"])
            {
                self.curOrder.sku_name = string;
            }
            else if(![self.currentElement compare:@"oid"])
            {
                self.curOrder.oid = [string longLongValue];
            }
            else if(![self.currentElement compare:@"status"])
            {
                self.curOrder.status = string;
            }
            else if(![self.currentElement compare:@"pic_path"])
            {
                self.curOrder.pic_url = string;
            }
            else if(![self.currentElement compare:@"price"])
            {
                self.curOrder.price = [string intValue];
            }
            else if(![self.currentElement compare:@"adjust_fee"])
            {
                self.curOrder.adjust_fee = [string doubleValue];
            }
            else if(![self.currentElement compare:@"discount_fee"])
            {
                self.curOrder.discount_fee = [string doubleValue];
            }
            else if(![self.currentElement compare:@"total_fee"])
            {
                self.curOrder.total_fee = [string doubleValue];
            }
            else if(![self.currentElement compare:@"payment"])
            {
                self.curOrder.payment = [string doubleValue];
            }
            break;
        default:
            break;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    switch (_parseState) {
        case TAOBAO_PARSE_ITEM:
            if([elementName isEqualToString:@"item"])
            {
                _get_count++;
                //TODO: save item to sqlite
                [self.curItem print];
                
                [self performSelectorOnMainThread:@selector(notiyItemWithTag:) withObject:[[NSString alloc]initWithFormat:@"已获取 %d 件商品",_get_count] waitUntilDone:NO];
            }
            break;
            
        case TAOBAO_PARSE_TRADE:
            if([elementName isEqualToString:@"trade"])
            {
                _get_count++;
                //TODO: save to sqlite

                [self performSelectorOnMainThread:@selector(notiyItemWithTag:) withObject:[[NSString alloc]initWithFormat:@"已获取 %d 订单",_get_count] waitUntilDone:NO];
            }
            
            break;
        case TAOBAO_PARSE_TRADE_ORDER:
            if([elementName isEqualToString:@"order"])
            {
                [self.curTrade.orders addObject:curOrder];
                _parseState = TAOBAO_PARSE_TRADE;
            }
            break;
             
        default:
            break;
    }

}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    //Pase Ended, start to tidy and sord
    switch (_parseState) {
        case TAOBAO_PARSE_ITEM:
            if(_get_count < _total_count)
                [self getItemInfo:[[NSString alloc]initWithFormat:@"%d", (_get_count/40 + 1)] ];
            else    
            {
                //End
                [self performSelectorOnMainThread:@selector(notiyItemWithTag:) withObject:@"OK" waitUntilDone:NO];
            }
            break;
        case TAOBAO_PARSE_TRADE:
            [self getTradeInfo];    //recur here
            break;
        default:
            break;
    }
}
@end
