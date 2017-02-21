//
//  JSONManager.h
//  WrightHub
//
//  Created by ZhiXing Li on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONManagerDelegate.h"

enum RequestMethod
{
    GET, PUT, POST, DELETE
};

enum ReturnType
{
    DataType, StringType, JSONType
};

@interface JSONManager : NSObject<ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    id<JSONManagerDelegate> delegate;
    NSMutableArray* m_postReq;
@public
    BOOL            m_isAsync;
    JSONDecoder* m_jsonDecoder;
}

@property (nonatomic) enum ReturnType ResponseType;
@property (nonatomic, assign) id   delegate;
-(id)initWithAsyncOption:(BOOL)isAsync;
-(id)JSONRequest:(NSString*)strUrl params:(NSDictionary*)requestData headers:(NSMutableDictionary *)headerData requestMethod:(enum RequestMethod)method;
-(id)JSONRequest:(NSString*)strUrl params:(NSDictionary*)requestData requestMethod:(enum RequestMethod)method;
-(id)JSONRequestWithFile:(NSString*)strUrl FilePath:(NSString*)filePath keyword:(NSString *)fileKey Info:(NSDictionary *)info headers:(NSMutableDictionary *)headerData;
-(id)JSONRequestWithFiles:(NSString*)strUrl dicFiles:(NSMutableDictionary *)dicFiles Info:(NSDictionary *)info headers:(NSMutableDictionary *)headerData;

-(NSError*)UploadFile:(NSString*)url FilePath:(NSString*)filePath FileName:(NSString*)fileName;
-(NSError*)DownloadFile:(NSString*)url SavePath:(NSString*)path;
-(NSError*)DownloadFilePathByProgress:(NSString*)url SavePath:(NSString*)path;

-(void)RequestCancel;
@end
