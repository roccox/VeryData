//
//  SingleModel.m
//  MyVeryLife
//
//  Created by Rock on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopData.h"
#import "AppDelegate.h"
static TopData *single = nil;

//TODO
static NSString   * _session = @"";

@interface TopData ()
-(void)getItemInfo:(NSString *)page_no;
-(void)getTradeInfo;
-(void)notifyItemWithTag:(NSString *)tag;
-(void)notifyTradeWithTag:(NSString *)tag;

-(void)getItemByIID;
@end

@implementation TopData

@synthesize delegate = _delegate;
@synthesize curItem,curTrade,currentElement,curOrder,errList;


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
    //check session
    AppConstant * constant = [AppConstant shareObject];
    if ([constant.session length] < 10 ||
        [constant.session_time timeIntervalSinceNow] < -(10*24*60*60) ) 
    {
        //need to get session
        _refreshing = NO;
        AppDelegate * del = [UIApplication sharedApplication].delegate;
        [del refreshSession];
        return;
    }
    _session = constant.session;
        
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
                                                 selector:@selector(getTradeInfo)
                                                   object:nil];
    [myThread start];
}

-(void)valifiedItems
{
    //get missing Items IIDs
    if(_refreshing)
    {
        [self.delegate notifyItemValidRefresh:YES withTag:@"BUSY"];
        return;
    }
    
    _get_count = 0;
    _refreshing = YES;
    
    FMDatabase * db = [DataBase shareDB];
	
    [db open];
    FMResultSet *rs = [db executeQuery:@"select distinct iid from orders where iid not in (select distinct iid from items)"];
    
    NSString * iid;
    if(self.errList == nil)
        self.errList = [[NSMutableArray alloc]init];
    else {
        [self.errList removeAllObjects];
    }
    
    while ([rs next]) {
        iid = [rs stringForColumn:@"iid"];
        
        [self.errList addObject: iid];
    }            
    
    [db close];
    //start thread to read data

    //New thread
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(getItemByIID)
                                                   object:nil];
    [myThread start];
    
}

-(void)getItemByIID
{
    _parseState = TAOBAO_PARSE_START;
    
    if (self.curItem == nil) {
        self.curItem = [[TopItemModel alloc]init];
    }
    //chekc error counts
    if([self.errList count] == 0)
    {
        //
        _refreshing = NO;
        [self performSelectorOnMainThread:@selector(notifyItemValidWithTag:) withObject:@"OK" waitUntilDone:NO];
        return;
    }
    
    //getting iids, 10 per groups
    NSString * iids = @"";
    NSString * iid = @"";
    for(int i=0,k=0;i<[self.errList count] && k<10;i++,k++)
    {
        iid = [self.errList objectAtIndex:i];
        if ([iids isEqualToString: @""])
            iids = [iids stringByAppendingString:iid];
        else
            iids = [iids stringByAppendingFormat:@",%@",iid];
        
        [self.errList removeObjectAtIndex:i];
        i--;
    }

    NSLog(@"%@",iids);
    
    //Get Items
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setObject:@"num_iid,title,volume,pic_url,price" forKey:@"fields"];
    [params setObject:iids forKey:@"num_iids"];
    [params setObject:@"taobao.items.list.get" forKey:@"method"];
    
    NSData *resultData=[Utility getResultData:params];
    NSXMLParser *xmlParser=[[NSXMLParser alloc] initWithData:resultData];
    [xmlParser setDelegate:self];
    [xmlParser parse];      

}

//获取
-(NSMutableArray *)getItems
{
    FMDatabase * db = [DataBase shareDB];
	
    [db open];
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM Items"];
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    TopItemModel * item;
    
    while ([rs next]) {
        item = [[TopItemModel alloc]init];
        item.num_iid = [rs longLongIntForColumn:@"iid"];
        item.title = [rs stringForColumn:@"title"];
        item.pic_url = [rs stringForColumn:@"pic_url"];
        item.price = [rs doubleForColumn:@"price"];
        item.volume = [rs intForColumn:@"volume"];
        item.import_price = [rs doubleForColumn:@"import_price"];
            
        [array addObject: item];
    }            
        
    [db close];
    return array;
}

-(NSMutableArray *)getUnSentTrades;
{
    FMDatabase * db = [DataBase shareDB];
	
    [db open];
    //按照拍下时间计算,按照付款时间排序
#if 1    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM Trades where status='WAIT_SELLER_SEND_GOODS' order by payment_time desc"];
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    TopTradeModel * trade;
    NSMutableArray * orders;
    TopOrderModel * order;
    
    while ([rs next]) {
        trade = [[TopTradeModel alloc]init];
        
        trade.tid = [rs longLongIntForColumn:@"tid"];
        trade.status = [rs stringForColumn:@"status"];
        trade.createdTime = [rs dateForColumn:@"created"];
        trade.modifiedTime = [rs dateForColumn:@"modified"];
        trade.buyer_nick = [rs stringForColumn:@"buyer"];
        
        trade.receiver_city = [rs stringForColumn:@"receiver_city"];
        trade.receiver_name = [rs stringForColumn:@"receiver_name"];
        trade.discount_fee = [rs doubleForColumn:@"discount_fee"];
        trade.adjust_fee = [rs doubleForColumn:@"adjust_fee"];
        trade.post_fee = [rs doubleForColumn:@"post_fee"];
        
        
        trade.total_fee = [rs doubleForColumn:@"total_fee"];
        trade.payment = [rs doubleForColumn:@"payment"];
        trade.paymentTime = [rs dateForColumn:@"payment_time"];
        trade.service_fee = [rs doubleForColumn:@"service_fee"];
        trade.note = [rs stringForColumn:@"note"];
        
        [array addObject: trade];
#endif
            
        //search orders
        orders = [[NSMutableArray alloc]init];
        FMResultSet *rs2 = [db executeQuery:@"select a.*, b.import_price from orders as a , items as b where a.status='WAIT_SELLER_SEND_GOODS' and a.tid = ? and b.iid = a.iid",[NSNumber numberWithLongLong: trade.tid]];
        while ([rs2 next]) {
            order = [[TopOrderModel alloc]init];
                
            order.oid = [rs2 longLongIntForColumn:@"oid"];
            order.num = [rs2 intForColumn:@"num"];
            order.num_iid = [rs2 longLongIntForColumn:@"iid"];
            order.title = [rs2 stringForColumn:@"title"];
            order.sku_name = [rs2 stringForColumn:@"sku"];
                
            order.pic_url = [rs2 stringForColumn:@"pic_url"];
            order.price = [rs2 doubleForColumn:@"price"];
            order.import_price = [rs2 doubleForColumn:@"import_price"];
            order.status = [rs2 stringForColumn:@"status"];
            order.discount_fee = [rs2 doubleForColumn:@"discount_fee"];
            order.adjust_fee = [rs2 doubleForColumn:@"adjust_fee"];
                
            order.total_fee = [rs2 doubleForColumn:@"total_fee"];
            order.payment = [rs2 doubleForColumn:@"payment"];
            order.tid = [rs2 longLongIntForColumn:@"tid"];
                
            order.refund_num = [rs2 intForColumn:@"refund_num"];
                
            [orders addObject: order];
        }
            
        trade.orders = orders;
    }            
        
    [db close];
    return array;
}


-(NSMutableArray *)getTradesFrom:(NSDate *)start to:(NSDate *)end
{
    FMDatabase * db = [DataBase shareDB];
	
    [db open];
    //按照拍下时间计算,按照付款时间排序
#if 1    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM Trades where created >= ? and created <=? order by payment_time desc",start,end];
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    TopTradeModel * trade;
    NSMutableArray * orders;
    TopOrderModel * order;
    
    while ([rs next]) {
        trade = [[TopTradeModel alloc]init];
        
        trade.tid = [rs longLongIntForColumn:@"tid"];
        trade.status = [rs stringForColumn:@"status"];
        trade.createdTime = [rs dateForColumn:@"created"];
        trade.modifiedTime = [rs dateForColumn:@"modified"];
        trade.buyer_nick = [rs stringForColumn:@"buyer"];
        
        trade.receiver_city = [rs stringForColumn:@"receiver_city"];
        trade.receiver_name = [rs stringForColumn:@"receiver_name"];
        trade.discount_fee = [rs doubleForColumn:@"discount_fee"];
        trade.adjust_fee = [rs doubleForColumn:@"adjust_fee"];
        trade.post_fee = [rs doubleForColumn:@"post_fee"];
        
        
        trade.total_fee = [rs doubleForColumn:@"total_fee"];
        trade.payment = [rs doubleForColumn:@"payment"];
        trade.paymentTime = [rs dateForColumn:@"payment_time"];
        trade.service_fee = [rs doubleForColumn:@"service_fee"];
        trade.note = [rs stringForColumn:@"note"];
        
        [array addObject: trade];
#else
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Trades where payment_time >= ? and payment_time <=? order by payment_time",start,end];
        
        NSMutableArray * array = [[NSMutableArray alloc]init];
        TopTradeModel * trade;
        NSMutableArray * orders;
        TopOrderModel * order;
        
        while ([rs next]) {
            trade = [[TopTradeModel alloc]init];
            
            trade.tid = [rs longLongIntForColumn:@"tid"];
            trade.status = [rs stringForColumn:@"status"];
            trade.createdTime = [rs dateForColumn:@"created"];
            trade.modifiedTime = [rs dateForColumn:@"modified"];
            trade.buyer_nick = [rs stringForColumn:@"buyer"];
            
            trade.receiver_city = [rs stringForColumn:@"receiver_city"];
            trade.receiver_name = [rs stringForColumn:@"receiver_name"];
            trade.discount_fee = [rs doubleForColumn:@"discount_fee"];
            trade.adjust_fee = [rs doubleForColumn:@"adjust_fee"];
            trade.post_fee = [rs doubleForColumn:@"post_fee"];
            
            
            trade.total_fee = [rs doubleForColumn:@"total_fee"];
            trade.payment = [rs doubleForColumn:@"payment"];
            trade.paymentTime = [rs dateForColumn:@"payment_time"];
            trade.service_fee = [rs doubleForColumn:@"service_fee"];
            trade.note = [rs stringForColumn:@"note"];
            
            [array addObject: trade];
        
#endif
        
        //search orders
        orders = [[NSMutableArray alloc]init];
        FMResultSet *rs2 = [db executeQuery:@"select a.*, b.import_price from orders as a , items as b where a.tid = ? and b.iid = a.iid",[NSNumber numberWithLongLong: trade.tid]];
        while ([rs2 next]) {
            order = [[TopOrderModel alloc]init];
            
            order.oid = [rs2 longLongIntForColumn:@"oid"];
            order.num = [rs2 intForColumn:@"num"];
            order.num_iid = [rs2 longLongIntForColumn:@"iid"];
            order.title = [rs2 stringForColumn:@"title"];
            order.sku_name = [rs2 stringForColumn:@"sku"];
            
            order.pic_url = [rs2 stringForColumn:@"pic_url"];
            order.price = [rs2 doubleForColumn:@"price"];
            order.import_price = [rs2 doubleForColumn:@"import_price"];
            order.status = [rs2 stringForColumn:@"status"];
            order.discount_fee = [rs2 doubleForColumn:@"discount_fee"];
            order.adjust_fee = [rs2 doubleForColumn:@"adjust_fee"];
            
            order.total_fee = [rs2 doubleForColumn:@"total_fee"];
            order.payment = [rs2 doubleForColumn:@"payment"];
            order.tid = [rs2 longLongIntForColumn:@"tid"];

            order.refund_num = [rs2 intForColumn:@"refund_num"];

            [orders addObject: order];
        }
        
        trade.orders = orders;
    }            
    
    [db close];
    return array;
}

//更新
-(void)putSession:(NSString *) session
{
    NSLog(@"Session-%@",session);
    AppConstant * constant = [AppConstant shareObject];
    constant.session = session;
    constant.session_time = [[NSDate alloc]initWithTimeIntervalSinceNow:(8*60*60)];
    [constant save];
    //start to refresh trade
    _session = session;
    [self refreshTrades];
}

//inner
-(void)notifyItemWithTag:(NSString *)tag
{
    
    if ([tag isEqualToString:@"OK"] || [tag isEqualToString:@"FAIL"]) 
    {
        _refreshing = NO;
        [self.delegate notifyItemRefresh:YES withTag:tag];
    }
    else 
        [self.delegate notifyItemRefresh:NO withTag:tag];
     
}

-(void)notifyTradeWithTag:(NSString *)tag
{
    
    if ([tag isEqualToString:@"OK"] || [tag isEqualToString:@"FAIL"] || [tag isEqualToString:@"SESSION_MISSING"]) 
    {
        _refreshing = NO;
        [self.delegate notifyTradeRefresh:YES withTag:tag];
    }
    else 
        [self.delegate notifyTradeRefresh:NO withTag:tag];
     
}


-(void)notifyItemValidWithTag:(NSString *)tag
{
    
    if ([tag isEqualToString:@"OK"] || [tag isEqualToString:@"FAIL"]) 
    {
        _refreshing = NO;
        [self.delegate notifyItemValidRefresh:YES withTag:tag];
    }
    else 
        [self.delegate notifyItemValidRefresh:NO withTag:tag];
    
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

-(void) prepareTradeParam
{
    static BOOL _fetch_will_end_next = NO;
    if(_has_next)
    {
        _has_next = NO;
        _page_count++;
    }
    else
    {
        if(_fetch_will_end_next)
        {
            _fetch_will_end_next = NO;
            _page_count = -1;   //Do not fetch data
            return;
        }
        
        _page_count = 1;
        startTime = [AppConstant shareObject].last_fetch;
        
        endTime = [[NSDate alloc]initWithTimeInterval:(4*60*60) sinceDate:startTime];
        NSDate * now = [[NSDate alloc]initWithTimeIntervalSinceNow:(8*60*60)];
        
        if([now timeIntervalSince1970]< [endTime timeIntervalSince1970])    //
        {
            endTime = now;
            _fetch_will_end_next = YES;
        }
        else {
            _fetch_will_end_next = NO;
        }
    }
    
    NSLog(@"Start-: %@",startTime);
    NSLog(@"End  -: %@",endTime);
}

-(void)getTradeInfo
{
    _parseState = TAOBAO_PARSE_START;
    
    if (self.curTrade == nil) {
        self.curTrade = [[TopTradeModel alloc]init];
        self.curTrade.orders = [[NSMutableArray alloc]init];
    }

    
    //get startTime and endTime, 
    [self prepareTradeParam];

    NSString * page_no = [[NSString alloc]initWithFormat:@"%d",_page_count];

    //check end
    if(_page_count == -1)
    {
        _refreshing = NO;
        _page_count = 1;
        [self performSelectorOnMainThread:@selector(notifyTradeWithTag:) withObject:@"OK" waitUntilDone:NO];
        return;
    }
    //Get Items
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setObject:@"taobao.trades.sold.increment.get" forKey:@"method"];
    [params setObject:@"tid,status,buyer_nick,receiver_name,receiver_city,discount_fee,adjust_fee,post_fee,total_fee,payment,received_payment,pay_time,created,modified,orders.num,orders.num_iid,orders.title,orders.sku_properties_name,orders.oid,orders.status,orders.pic_path,orders.price,orders.adjust_fee,orders.discount_fee,orders.total_fee,orders.payment,orders.refund_status" forKey:@"fields"];
    [params setObject:[[startTime description] substringToIndex:19] forKey:@"start_modified"];
    [params setObject:[[endTime description] substringToIndex:19] forKey:@"end_modified"];
    [params setObject:@"true" forKey:@"use_has_next"];
    [params setObject:page_no  forKey:@"page_no"];

    
    [params setObject:_session forKey:@"session"];
    
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
    else if ([self.currentElement isEqualToString:@"items_list_get_response"]) {
        _parseState = TAOBAO_PARSE_ITEM_VAL;
    }
}
-(NSDate *) getDateFromString:(NSString*)string
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date = [formatter dateFromString:string];
    date =  [[NSDate alloc]initWithTimeInterval:(8*60*60) sinceDate:date];
    return date;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    switch (_parseState) {
        case TAOBAO_PARSE_ITEM:
        case TAOBAO_PARSE_ITEM_VAL:
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
                self.curTrade.buyer_nick = [self.curTrade.buyer_nick stringByAppendingString:string];
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
            else if(![self.currentElement compare:@"refund_status"])
            {
                self.curOrder.refund = string;
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
                [self.curItem save];
                
                [self performSelectorOnMainThread:@selector(notifyItemWithTag:) withObject:[[NSString alloc]initWithFormat:@"已获取 %d 件商品",_get_count] waitUntilDone:NO];
            }
            break;
        case TAOBAO_PARSE_ITEM_VAL:
            if([elementName isEqualToString:@"item"])
            {
                _get_count++;
                //TODO: save item to sqlite
                [self.curItem save];
                
                [self.curItem print];
                
                [self performSelectorOnMainThread:@selector(notifyItemValidWithTag:) withObject:[[NSString alloc]initWithFormat:@"已获取 %d 件商品",_get_count] waitUntilDone:NO];
            }
            break;
            
        case TAOBAO_PARSE_TRADE:
            if([elementName isEqualToString:@"trade"])
            {
                _get_count++;
                if(self.curTrade.paymentTime == nil)
                    self.curTrade.paymentTime = [[NSDate alloc]initWithTimeInterval:0 sinceDate:self.curTrade.createdTime];
                //TODO: save to sqlite
                for (TopOrderModel * order in self.curTrade.orders) {
                    order.tid = self.curTrade.tid;
                }
                [self.curTrade save];
                
                self.curTrade.buyer_nick = @"";
                self.curTrade.paymentTime = nil;

                [self.curTrade.orders removeAllObjects];

                [self performSelectorOnMainThread:@selector(notifyTradeWithTag:) withObject:[[NSString alloc]initWithFormat:@"已获取 %d 订单",_get_count] waitUntilDone:NO];
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
                [self performSelectorOnMainThread:@selector(notifyItemWithTag:) withObject:@"OK" waitUntilDone:NO];
            }
            break;
        case TAOBAO_PARSE_ITEM_VAL:
            [self performSelector:@selector(getItemByIID)];
            break;
            
        case TAOBAO_PARSE_TRADE:
            [AppConstant shareObject].last_fetch = endTime;
            NSLog(@"last_fetch is- %@",[AppConstant shareObject].last_fetch);
            [[AppConstant shareObject] saveFetchTime];
            [self performSelector:@selector(getTradeInfo)];
            break;
        default:
            break;
    }
}
@end
