//
//  JSONManagerDelegate.h
//  WebTest
//
//  Created by ZhiXing Li on 9/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@protocol JSONManagerDelegate <NSObject>

@optional
-(void)JSONRequestFinished:(id)response decoder:(JSONDecoder*)jsonDecoder;
-(void)JSONRequestFailed:(NSError*)error;

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength;
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes;

@end
