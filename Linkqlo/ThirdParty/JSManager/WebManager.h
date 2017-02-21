//
//  WebManager.h
//  WebTest
//
//  Created by ZhiXing Li on 9/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONManager.h"

@protocol WebManagerDelegate <NSObject>
@required

-(void)requestFinished:(id)response;
-(void)DownloadSuccess;
-(void)uploadCompleted:(id)response;
-(void)WebManagerFailed:(NSError*)error;

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength;
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes;

@end

enum RequestActionName
{
    None, RequestWithAction, Upload,Download,
};

@interface WebManager : NSObject
{
    enum RequestActionName m_requestActionName;
    id<WebManagerDelegate> delegate;
    JSONManager* m_jsonManager;
    NSString* m_url;
@public
    BOOL                m_isAsync;
}

@property (nonatomic, retain) id   delegate;

-(id)initWithAsyncOption:(BOOL)isAsync;

-(void)CancelRequest;

-(NSError*)DownloadFile:(NSString*)fileName SavePath:(NSString*)path;

-(id)requestWithAction:(NSString *)action request:(NSDictionary *)request;
-(id)requestWithAction:(NSString *)action request:(NSDictionary *)request header:(NSMutableDictionary *)header;

-(id)requestUpoadFileWithAction:(NSString *)action request:(NSMutableDictionary *)info file:(NSString *)filePath;
-(id)requestUpoadFileWithAction:(NSString *)action request:(NSMutableDictionary *)info header:(NSMutableDictionary *)header file:(NSString *)filePath;

-(id)requestUpoadFilesWithAction:(NSString *)action request:(NSMutableDictionary *)info files:(NSMutableDictionary *)dicFiles;
-(id)requestUpoadFilesWithAction:(NSString *)action request:(NSMutableDictionary *)info header:(NSMutableDictionary *)header files:(NSMutableDictionary *)dicFiles;

-(id)requestGetWithAction:(NSString *)action request:(NSDictionary *)request;
-(id)requestGetWithAction:(NSString *)action request:(NSDictionary *)request header:(NSMutableDictionary *)header;

- (NSMutableDictionary *)getLocationInformation:(NSMutableDictionary *)dic;
- (NSMutableDictionary *)getFacebookCoverImage:(NSString *)facebookId;

- (NSMutableDictionary*)getNearbyLocations:(NSString*)location radius:(NSInteger)radius;
- (NSMutableDictionary*)getLocationsByString:(NSString*)stringToSearch center:(NSString *)location radius:(NSInteger)radius;

- (id) requestInstagramUserId:(NSString *)token;
- (id) requestInstagramPhotos:(NSString *)userId token:(NSString *)token;

@end
