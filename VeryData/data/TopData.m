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
@synthesize curItem,curTrade,currentElement;


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
        [self.delegate notifyItemRefresh:YES withTag:@"BUSY"];
    
    _refreshing = YES;
    
    _get_count = 0;
    _total_count = 0;
    
    //New thread
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(getTopItem:)
                                                   object:nil];
    [myThread start];
}

-(void)refreshTrades   //异步方法
{
    if(_refreshing)
        [self.delegate notifyTradeRefresh:YES withTag:@"BUSY"];
    
    _refreshing = YES;

    _get_count = 0;
    _total_count = 0;

    //New thread
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(getTopTrade:)
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
    if ([tag isEqualToString:@"OK"] || [tag isEqualToString:@"FAIL"]) 
        [self.delegate notifyTradeRefresh:YES withTag:tag];
    else 
        [self.delegate notifyTradeRefresh:NO withTag:tag];
}


//inner
-(void)getItemInfo:(int)page_no
{
    _parseState = TAOBAO_PARSE_START;

    if (self.curItem == nil) {
        self.curItem = [[TopItemModel alloc]init];
    }

    //Get Category List
    NSString * _page_num = [[NSString alloc]initWithFormat:@"%d",page_no];
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setObject:@"num_iid,title,volume,pic_url,price" forKey:@"fields"];
    [params setObject:@"podees" forKey:@"nicks"];
    [params setObject:@"volume:desc" forKey:@"order_by"];
    [params setObject:_page_num forKey:@"page_no"];
    [params setObject:@"volume:desc" forKey:@"order_by"];
    [params setObject:@"taobao.items.get" forKey:@"method"];
    
    NSData *resultData=[Utility getResultData:params];
    NSXMLParser *xmlParser=[[NSXMLParser alloc] initWithData:resultData];
    [xmlParser setDelegate:self];
    [xmlParser parse];      
    
}

-(void)getTradeInfo:(int)page_no
{
    _parseState = TAOBAO_PARSE_START;
    
    if (self.curTrade == nil) {
        self.curTrade = [[TopTradeModel alloc]init];
    }

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
    else if([self.currentElement isEqualToString:@"orders"])
    {
        _parseState = TAOBAO_PARSE_TRADE_ORDER;
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    switch (_parseState) {
        case TAOBAO_PARSE_ITEM:
            //商品列表
            if(![self.currentElement compare:@"num_iid"])
            {
                self.curItem.id = [string intValue];
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
            /*
        case TAOBAO_PARSE_TRADE:
            //Trade信息
            if(![self.currentElement compare:@"num_iid"])
            {
                //search itemPro
                ItemProductModel * pro;
                for(int i=0;i<[self.itemAllProList count];i++)
                {
                    pro = [self.itemAllProList objectAtIndex:i];
                    if([pro.num_iid isEqualToString: string])
                        self.itemPro = pro;
                }

            }
            else if(![self.currentElement compare:@"seller_cids"])
            {
                self.itemPro.seller_cids=string;
            }
            else if(![self.currentElement compare:@"list_time"])
            {
                self.itemPro.list_time=string;
            }
            break;
        case TAOBAO_PARSE_TRADE_ORDER:
            //商品信息
            if(![self.currentElement compare:@"num"])
            {
                self.itemPro.stock_num=string;
            }
            else if(![self.currentElement compare:@"express_fee"])
            {
                self.itemPro.item_express =string;
            }
            else if(![self.currentElement compare:@"desc"])//wap_desc
            {
                NSString * _pro = [SingleModel getSingleModal].itemPro.wap_desc;
                if([_pro length] ==0)
                    _pro=string;
                else
                {
//                    _pro = @"t\n";
//                    _pro = [_pro stringByAppendingString: @"t\n"];
//                    _pro = [_pro stringByAppendingString:@"\n"];
                    _pro = [_pro stringByAppendingFormat:@"%@",string];   
                }
                
                [SingleModel getSingleModal].itemPro.wap_desc = _pro;
            }
            else if(![self.currentElement compare:@"wap_detail_url"])
            {
                self.itemPro.wap_detail_url=string;
            }
            else if(![self.currentElement compare:@"stuff_status"])
            {
                self.itemPro.item_type=string;
            }
            
            break;
            */
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

                [self performSelectorOnMainThread:@selector(notiyItemWithTag:) withObject:[[NSString alloc]initWithFormat:@"已获取 %d 件商品",_get_count] waitUntilDone:NO];
            }
            break;
            /*
        case TAOBAO_PARSE_PRO_INFO:
            break;
        case TAOBAO_PARSE_DETAIL_INFO:
            break;
             */
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
                [self getItemInfo:(_get_count/40 + 1)];
            else    
            {
                //End
                [self performSelectorOnMainThread:@selector(notiyItemWithTag:) withObject:@"OK" waitUntilDone:NO];
            }
            break;
            /*
        case TAOBAO_PARSE_PRO_INFO:
            _item_getinfo_no++;
            if(_item_getinfo_no * 20 >= [self.itemAllProList count])
            {
                _item_getinfo_no = 0;
                [self tidyData];
                NSLog(@"finishedRefreshData - start");
                [self.delegate finishedRefreshData];
            }
            else
                [self getProInfo:_item_getinfo_no];
            break;
        case TAOBAO_PARSE_DETAIL_INFO:
            [self.delegate finishedDetailData];
            break;
        case TAOBAO_PARSE_COMMENT:
            [self.delegate finishedCommentData];
            break;
             */
        default:
            break;
    }
}
@end
