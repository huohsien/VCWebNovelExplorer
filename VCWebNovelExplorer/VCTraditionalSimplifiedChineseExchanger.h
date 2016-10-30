//
//  VCTraditionalSimplifiedChineseExchanger.h
//  VCWebNovelExplorer
//
//  Created by victor on 10/31/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCTraditionalSimplifiedChineseExchanger : NSObject

+(NSString*) getTraditionStringFromSimpleString:(NSString*)str;
+(NSString*) getSimpleStringFromTraditionString:(NSString*)str;

@end
