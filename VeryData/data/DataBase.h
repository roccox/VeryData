//
//  DataHelper.h
//  VeryData
//
//  Created by Rock on 12-4-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface DataBase : NSObject


+(FMDatabase *)shareDB;

@end
