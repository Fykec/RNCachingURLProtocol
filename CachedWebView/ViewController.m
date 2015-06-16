//
//  ViewController.m
//  CachedWebView
//
//  Created by Robert Napier on 1/29/12.
//  Copyright (c) 2012 Rob Napier.
//
//  This code is licensed under the MIT License:
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "ViewController.h"
#import "Aspects.h"
#import "RNCachingURLProtocol.h"

@interface ViewController () <UIWebViewDelegate> {
    id<AspectToken> _loadFinishHook;

    id<AspectToken> _loadFailedHook;
}

@end

@implementation ViewController
@synthesize webView = webView_;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/Fykec/RNCachingURLProtocol"]]];

    [self clearReloadIgnoringCacheHook];
    [self addReloadIgnoringCacheHook];
}

- (void)addReloadIgnoringCacheHook {
    typedef void (^ ReloadIgnoringCacheBlock) (id<AspectInfo> info, UIWebView *webView);

    ReloadIgnoringCacheBlock reloadBlock = ^ (id<AspectInfo> info, UIWebView *webView) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webView.request.URL
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:600.0];
        [request setValue:@"" forHTTPHeaderField:RNCachingReloadIgnoringCacheHeader];
        __weak typeof(self)weakSelf = self;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSURLResponse *response = nil;
            NSData *data = nil;
            NSError *error = nil;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [weakSelf updateData:data response:response];
            });
        });
    };

    _loadFinishHook = [self aspect_hookSelector:@selector(webViewDidFinishLoad:) withOptions:AspectPositionAfter | AspectOptionAutomaticRemoval usingBlock:reloadBlock error:nil];
    _loadFailedHook =[self aspect_hookSelector:@selector(webView:didFailLoadWithError:) withOptions:AspectPositionAfter | AspectOptionAutomaticRemoval usingBlock:reloadBlock error:nil];

}

- (void)clearReloadIgnoringCacheHook {
    [_loadFinishHook remove];
    [_loadFailedHook remove];
}

- (void)updateData:(NSData *)data response:(NSURLResponse *)response {
    if ([self.webView.request.URL.absoluteString isEqualToString:response.URL.absoluteString]) {
        [self.webView loadData:data MIMEType:response.MIMEType textEncodingName:response.textEncodingName baseURL:response.URL];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"[%@|%@|%d] %@", NSStringFromClass([self class]) , NSStringFromSelector(_cmd) , __LINE__ ,@"");

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"[%@|%@|%d] %@", NSStringFromClass([self class]) , NSStringFromSelector(_cmd) , __LINE__ ,error);
}


@end
