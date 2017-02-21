//
//  JSONManager.m
//  WrightHub
//
//  Created by ZhiXing Li on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSONManager.h"

@implementation JSONManager
@synthesize delegate;
@synthesize ResponseType;

-(id)initWithAsyncOption:(BOOL)isAsync
{
    if (self = [super init])
    {
        m_jsonDecoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionStrict];
        m_postReq = [[NSMutableArray alloc] init];
        m_isAsync = isAsync;
    }
    return self;
}

-(void)dealloc
{
    [m_jsonDecoder release];
    for (int i = 0; i < m_postReq.count; i++)
        [[m_postReq objectAtIndex:i] release];
    [m_postReq removeAllObjects];
    [m_postReq release];
    [super dealloc];
}

-(id)JSONRequest:(NSString*)strUrl params:(NSDictionary*)requestData headers:(NSMutableDictionary *)headerData requestMethod:(enum RequestMethod)method
{
    id ret = nil;
    switch (method) {
        case POST:
        {
            NSURL* url = [NSURL URLWithString:strUrl];
            ASIFormDataRequest* postReq = [ASIFormDataRequest requestWithURL:url];
            //ASIHTTPRequest * postReq = [ASIFormDataRequest requestWithURL:url];
            
            if(headerData)
            {
                [postReq setRequestMethod:@"POST"];
                
                //[postReq addRequestHeader:@"Keep-Alive" value:@"timeout=15, max=100"];
                [postReq addRequestHeader:@"Content-Type" value:@"application/json"];
                //[postReq addRequestHeader:@"Accept" value:@"application/json"];
                
                for(NSString* key in [headerData allKeys])
                {
                    [postReq addRequestHeader:key value:[headerData valueForKey:key]];
                }
                
                NSLog(@"%@", postReq.requestHeaders);
            }
            
            for(NSString* key in [requestData allKeys])
            {
                [postReq setPostValue:[requestData valueForKey:key] forKey:key];
            }
            
            if (m_isAsync)
            {
                [postReq setDelegate:self];
                [postReq setDidFailSelector:@selector(requestFailed:)];
                [postReq setDidFinishSelector:@selector(requestFinished:)];
                [postReq startAsynchronous];
            }
            else {
                [postReq startSynchronous];
                NSError* err = [postReq error];
                if (!err)
                {
                    if (ResponseType == DataType)
                        ret = [postReq responseData];
                    else if (ResponseType == StringType)
                        ret = [postReq responseString];
                }
            }
            break;
        }
        case GET:
        {
            BOOL hasParam = false;
            NSMutableString* getUrl = [NSMutableString stringWithString:strUrl];
            [getUrl appendString:@"?"];
            for(NSString* key in [requestData allKeys])
            {
                hasParam = true;
                [getUrl appendFormat:@"%@=%@&", key, [requestData valueForKey:key]];
            }
            if (hasParam)
            {
                NSRange r;
                r.location = 0;
                r.length = [getUrl length] - 1;
                [getUrl substringWithRange:r];
            }
            
            NSURL* url = [NSURL URLWithString:getUrl];
            ASIHTTPRequest* getReq = [ASIHTTPRequest requestWithURL:url];
            
            if(headerData)
            {
                [getReq setRequestMethod:@"GET"];
                
                //[getReq addRequestHeader:@"Keep-Alive" value:@"timeout=15, max=100"];
                [getReq addRequestHeader:@"Content-Type" value:@"application/json"];
                
                
                for(NSString* key in [headerData allKeys])
                {
                    [getReq addRequestHeader:key value:[headerData valueForKey:key]];
                }
            }
            
            [getReq setDelegate:self];
            if (m_isAsync)
                [getReq startAsynchronous];
            else {
                [getReq startSynchronous];
                NSError* err = [getReq error];
                if (!err)
                {
                    if (ResponseType == DataType)
                        ret = [getReq responseData];
                    else if (ResponseType == StringType)
                        ret = [getReq responseString];
                }
            }
            break;
        }
        case PUT:
        {
            break;
        }
        case DELETE:
        {
            break;
        }
        default:
            break;
    }
    
    return ret;
}

-(id)JSONRequest:(NSString*)strUrl params:(NSDictionary*)requestData requestMethod:(enum RequestMethod)method
{
    return [self JSONRequest:strUrl params:requestData headers:nil requestMethod:method];
}

-(id)JSONRequestWithFile:(NSString*)strUrl FilePath:(NSString*)filePath keyword:(NSString *)fileKey Info:(NSDictionary *)info headers:(NSMutableDictionary *)headerData
{
    id ret = nil;
    ASIFormDataRequest *postReq = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strUrl]];
    [postReq setTimeOutSeconds:600];
    
    if(headerData)
    {
        //[postReq addRequestHeader:@"Keep-Alive" value:@"timeout=15, max=100"];
        [postReq addRequestHeader:@"Content-Type" value:@"application/json"];
        //[postReq addRequestHeader:@"Accept" value:@"application/json"];
        
        for(NSString* key in [headerData allKeys])
        {
            [postReq addRequestHeader:key value:[headerData valueForKey:key]];
        }
        
        NSLog(@"%@", postReq.requestHeaders);
    }
    
    for(NSString* key in [info allKeys])
    {
        [postReq setPostValue:[info valueForKey:key] forKey:key];
    }
    
    [postReq setFile:filePath forKey:fileKey];
    NSLog(@"%@", filePath);
    
    [postReq setDelegate:self];
    [postReq setDidFailSelector:@selector(requestFailed:)];
    [postReq setDidFinishSelector:@selector(requestFinished:)];
    if (m_isAsync)
    {
        [postReq startAsynchronous];
        return nil;
    }
    else
    {
        [postReq startSynchronous];
        NSError* err = [postReq error];
        if (!err)
        {
            if (ResponseType == DataType)
                ret = [postReq responseData];
            else if (ResponseType == StringType)
                ret = [postReq responseString];
        }
    }
    
    return ret;
}

-(id)JSONRequestWithFiles:(NSString *)strUrl dicFiles:(NSMutableDictionary *)dicFiles Info:(NSDictionary *)info headers:(NSMutableDictionary *)headerData
{
    id ret = nil;
    ASIFormDataRequest *postReq = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strUrl]];
    [postReq setTimeOutSeconds:600];
    
    if(headerData)
    {
        //[postReq addRequestHeader:@"Keep-Alive" value:@"timeout=15, max=100"];
        [postReq addRequestHeader:@"Content-Type" value:@"application/json"];
        //[postReq addRequestHeader:@"Accept" value:@"application/json"];
        
        for(NSString* key in [headerData allKeys])
        {
            [postReq addRequestHeader:key value:[headerData valueForKey:key]];
        }
        
        NSLog(@"%@", postReq.requestHeaders);
    }
    
    for(NSString* key in [info allKeys])
    {
        [postReq setPostValue:[info valueForKey:key] forKey:key];
    }
    
    for(NSString* key in [dicFiles allKeys])
    {
        [postReq addFile:[dicFiles valueForKey:key] forKey:key];
    }
    
    [postReq setDelegate:self];
    [postReq setDidFailSelector:@selector(requestFailed:)];
    [postReq setDidFinishSelector:@selector(requestFinished:)];
    if (m_isAsync)
    {
        [postReq startAsynchronous];
        return nil;
    }
    else
    {
        [postReq startSynchronous];
        NSError* err = [postReq error];
        if (!err)
        {
            if (ResponseType == DataType)
                ret = [postReq responseData];
            else if (ResponseType == StringType)
                ret = [postReq responseString];
        }
    }
    
    return ret;
}

-(NSError*)UploadFile:(NSString*)url FilePath:(NSString*)filePath FileName:(NSString*)fileName
{
    ASIFormDataRequest *postReq = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [postReq setTimeOutSeconds:600];
    [postReq setPostValue:[NSString stringWithFormat:@"%@.png", fileName] forKey:@"filename"];
    [postReq setFile:filePath forKey:@"upload"];
    
    [postReq setDelegate:self];
    [postReq setDidFailSelector:@selector(requestFailed:)];
    [postReq setDidFinishSelector:@selector(requestFinished:)];
    if (m_isAsync)
    {
        [postReq startAsynchronous];
        return nil;
    }
    else
    {
        [postReq startSynchronous];
        return [postReq error];
    }
}

-(NSError*)DownloadFile:(NSString*)url SavePath:(NSString*)path
{
    ASIHTTPRequest *postReq = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [postReq setTimeOutSeconds:600];
    [postReq setDownloadDestinationPath:path];
    
    [postReq setDelegate:self];
    [postReq setDidFailSelector:@selector(requestFailed:)];
    [postReq setDidFinishSelector:@selector(requestFinished:)];
    
    [m_postReq addObject:[postReq retain]];
    if (m_isAsync)
    {
        [postReq startAsynchronous];
        return nil;
    }
    else
    {
        [postReq startSynchronous];
        return [postReq error];
    }
}

-(NSError*)DownloadFilePathByProgress:(NSString*)url SavePath:(NSString*)path
{
    ASIHTTPRequest *postReq = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [postReq setDownloadProgressDelegate:self];
    
    [postReq setTimeOutSeconds:600];
    [postReq setDownloadDestinationPath:path];
    
    [postReq setDelegate:self];
    [postReq setDidFailSelector:@selector(requestFailed:)];
    [postReq setDidFinishSelector:@selector(requestFinished:)];
    
    [m_postReq addObject:[postReq retain]];
//    if (m_isAsync)
//    {
        [postReq startAsynchronous];
        return nil;
//    }
//    else
//    {
//        [postReq startSynchronous];
//        return [postReq error];
//    }
}

-(void)DownloadFileByProgress:(NSString*)url FileName:(NSString*)fileName
{
    ASIHTTPRequest *postReq = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [postReq setDownloadProgressDelegate:self];
    
    [postReq setTimeOutSeconds:600];
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
	NSString *savePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    [postReq setDownloadDestinationPath:savePath];
    
    [postReq setDelegate:self];
    [postReq setDidFailSelector:@selector(requestFailed:)];
    [postReq setDidFinishSelector:@selector(requestFinished:)];
    
    [m_postReq addObject:[postReq retain]];
    
    [postReq startAsynchronous];
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength
{
    [delegate request:request incrementDownloadSizeBy:newLength];
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    [delegate request:request didReceiveBytes:bytes];
}

- (void)requestFinished:(ASIHTTPRequest *)request 
{
    if (delegate != nil)
    {
        switch ([self ResponseType]) {
            case DataType:
            {
                NSLog(@"%@", [request responseData]);
                
                [delegate JSONRequestFinished:[request responseData] decoder:m_jsonDecoder];
                break;
            }   
            case StringType:
            {
                [delegate JSONRequestFinished:[request responseString] decoder:m_jsonDecoder];
                break;
            }
            default:
                break;
        }
    }
}

-(void)RequestCancel
{
    for (int i = 0; i < m_postReq.count; i++)
    {
        ASIHTTPRequest* req = (ASIHTTPRequest*)[m_postReq objectAtIndex:i];
        [req clearDelegatesAndCancel];
        [req release];
    }
    [m_postReq removeAllObjects];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (delegate != nil)
        [delegate JSONRequestFailed:[request error]];
}
@end
