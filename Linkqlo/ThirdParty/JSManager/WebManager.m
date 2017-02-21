//
//  WebManager.m
//  WebTest
//
//  Created by ZhiXing Li on 9/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebManager.h"

@implementation WebManager
@synthesize delegate;

#define GOOGLE_KEY   @"AIzaSyD-0pmnafC909cEEgS50Rl3odLLbyMK7Jg"

-(id)initWithAsyncOption:(BOOL)isAsync
{
    if (self = [super init])
    {
        m_jsonManager = [[JSONManager alloc] initWithAsyncOption:isAsync];
        [m_jsonManager setDelegate:self];

        m_isAsync = isAsync;
        m_requestActionName = None;
        
        //m_url = @"http://dev.helpio.com/mobileapi/";
        //m_url = @"http://172.16.216.5/gobe/index.php";
        //m_url = @"http://hirechinese.com.au/test/index.php";
        
        // Remote
        m_url = @"http://54.200.24.75/api/";
        
        // Local
//        m_url = @"http://172.16.217.5/linkqlo/api/";
    }
    return self;
}

-(void)CancelRequest
{
    [m_jsonManager RequestCancel];
}

-(id)requestWithAction:(NSString *)action request:(NSDictionary *)request
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = RequestWithAction;
    
    id ret = [m_jsonManager JSONRequest:[NSString stringWithFormat:@"%@%@", m_url, action] params:request requestMethod:POST];
    
//    NSLog(@"%@", ret);
    
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }

    return nil;
}

-(id)requestWithAction:(NSString *)action request:(NSDictionary *)request header:(NSMutableDictionary *)header
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = RequestWithAction;
    
    id ret = [m_jsonManager JSONRequest:[NSString stringWithFormat:@"%@?cmd=%@", m_url, action] params:request headers:header requestMethod:POST];
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

-(id)requestGetWithAction:(NSString *)action request:(NSDictionary *)request
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = RequestWithAction;
    
    id ret = [m_jsonManager JSONRequest:[NSString stringWithFormat:@"%@", m_url] params:request requestMethod:GET];
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

-(id)requestGetWithAction:(NSString *)action request:(NSDictionary *)request header:(NSMutableDictionary *)header
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = RequestWithAction;
    
    id ret = [m_jsonManager JSONRequest:[NSString stringWithFormat:@"%@", m_url] params:request headers:header requestMethod:GET];
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

- (id) requestInstagramUserId:(NSString *)token
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = RequestWithAction;
    
    id ret = [m_jsonManager JSONRequest:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/?access_token=%@", token] params:nil headers:nil requestMethod:POST];
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

- (id) requestInstagramPhotos:(NSString *)userId token:(NSString *)token
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = RequestWithAction;
    
    id ret = [m_jsonManager JSONRequest:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?access_token=%@",userId, token] params:nil headers:nil requestMethod:POST];
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

-(id)requestUpoadFileWithAction:(NSString *)action request:(NSMutableDictionary *)info header:(NSMutableDictionary *)header file:(NSString *)filePath
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = Upload;
    
    id ret = [m_jsonManager JSONRequestWithFile:[NSString stringWithFormat:@"%@%@", m_url, action] FilePath:filePath keyword:@"userfile" Info:info headers:header];
    
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

-(id)requestUpoadFileWithAction:(NSString *)action request:(NSMutableDictionary *)info file:(NSString *)filePath
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = Upload;
    
    id ret = [m_jsonManager JSONRequestWithFile:[NSString stringWithFormat:@"%@%@", m_url, action] FilePath:filePath keyword:@"photo_url" Info:info headers:nil];
    
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

-(id)requestUpoadFilesWithAction:(NSString *)action request:(NSMutableDictionary *)info header:(NSMutableDictionary *)header files:(NSMutableDictionary *)dicFiles
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = Upload;
    
    id ret = [m_jsonManager JSONRequestWithFiles:[NSString stringWithFormat:@"%@%@", m_url, action] dicFiles:dicFiles Info:info headers:header];
    
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

-(id)requestUpoadFilesWithAction:(NSString *)action request:(NSMutableDictionary *)info files:(NSMutableDictionary *)dicFiles
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = Upload;
    
    id ret = [m_jsonManager JSONRequestWithFiles:[NSString stringWithFormat:@"%@%@", m_url, action] dicFiles:dicFiles Info:info headers:nil];
    
    if (ret)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

- (NSMutableDictionary *)getLocationInformation:(NSMutableDictionary *)dic
{
    [m_jsonManager setResponseType:DataType];
    
    id ret = [m_jsonManager JSONRequest:@"https://maps.googleapis.com/maps/api/geocode/json" params:dic requestMethod:GET];
    
    NSLog( @"%@", ret);
    
    if(ret != nil)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
    
}

- (NSMutableDictionary *)getFacebookCoverImage:(NSString *)facebookId
{
    [m_jsonManager setResponseType:DataType];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                @"cover", @"fields", nil];
    
    id ret = [m_jsonManager JSONRequest:[NSString stringWithFormat:@"http://graph.facebook.com/%@", facebookId] params:dic requestMethod:GET];
    
    NSLog( @"%@", ret);
    
    if(ret != nil)
    {
        return [m_jsonManager->m_jsonDecoder objectWithData:ret];
    }
    
    return nil;
}

-(NSError*)DownloadFile:(NSString*)fileName SavePath:(NSString*)path
{
    m_requestActionName = Download;
    //return [m_jsonManager DownloadFile:[NSString stringWithFormat:@"http://skybear521.com/ignite/%@", fileName] SavePath:path];
    return [m_jsonManager DownloadFilePathByProgress:[NSString stringWithFormat:@"https://s3.amazonaws.com/ignitevideo_resources/clips/%@", fileName] SavePath:path];
}

- (NSMutableDictionary*)getNearbyLocations:(NSString *)location radius:(NSInteger)radius
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = RequestWithAction;
    
    NSString *strRadius = [NSString stringWithFormat:@"%d", (int)radius];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         location,      @"location",
                         strRadius,     @"radius",
                         GOOGLE_KEY,    @"key",
                         @"true",       @"sensor",
                         nil];
    
    NSLog(@"%@", dic);
    id response = [m_jsonManager JSONRequest:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json" params:dic requestMethod:GET];
    NSLog(@"%@", response);
    if (response)
        return [m_jsonManager->m_jsonDecoder objectWithData:response];
    
    return nil;
}

- (NSMutableDictionary*)getLocationsByString:(NSString*)stringToSearch center:(NSString *)location radius:(NSInteger)radius
{
    [m_jsonManager setResponseType:DataType];
    m_requestActionName = RequestWithAction;
    
    NSDictionary* dic = nil;
    if (location == nil)
    {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:
               stringToSearch, @"input",
               GOOGLE_KEY,     @"key",
               @"true",       @"sensor",
               nil];
//        dic = [NSDictionary dictionaryWithObjectsAndKeys:
//               stringToSearch, @"query",
//               GOOGLE_KEY,     @"key",
//               @"true",       @"sensor",
//               nil];
    }
    else
    {
        NSString *strRadius = [NSString stringWithFormat:@"%d", (int)radius];
        dic = [NSDictionary dictionaryWithObjectsAndKeys:
               stringToSearch, @"input",
               location,      @"location",
               strRadius,     @"radius",
               GOOGLE_KEY,    @"key",
               @"true",       @"sensor",
               nil];
//        dic = [NSDictionary dictionaryWithObjectsAndKeys:
//               stringToSearch, @"query",
//               location,      @"location",
//               strRadius,     @"radius",
//               GOOGLE_KEY,    @"key",
//               @"true",       @"sensor",
//               nil];
    }
    
    NSLog(@"%@", dic);
    id response = [m_jsonManager JSONRequest:@"https://maps.googleapis.com/maps/api/place/autocomplete/json" params:dic requestMethod:GET];
//    id response = [m_jsonManager JSONRequest:@"https://maps.googleapis.com/maps/api/place/textsearch/json" params:dic requestMethod:GET];
    NSLog(@"%@", response);
    if (response)
        return [m_jsonManager->m_jsonDecoder objectWithData:response];
    
    return nil;
}

#pragma mark -JSONManagerDelegate

-(void)JSONRequestFinished:(id)response decoder:(JSONDecoder*)jsonDecoder
{
    switch (m_requestActionName)
    {
        case RequestWithAction:
            [delegate requestFinished:[jsonDecoder objectWithData:response]];
            break;
            
        case Download:
            [delegate DownloadSuccess];
            break;
            
        case Upload:
            [delegate uploadCompleted:[jsonDecoder objectWithData:response]];
            break;
            
        default:
            break;
    }
    
    m_requestActionName = None;
}

-(void)JSONRequestFailed:(NSError*)error
{
    if (delegate != nil)
    {
        [delegate WebManagerFailed:error];
    }
    m_requestActionName = None;
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength
{
    [delegate request:request incrementDownloadSizeBy:newLength];
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    [delegate request:request didReceiveBytes:bytes];
}

@end
