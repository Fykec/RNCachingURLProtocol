# RNCachingURLProtocol+HybirdApp

RNCachingURLProtocol+HybirdApp is base on [RNCachingURLProtocol](https://github.com/rnapier/RNCachingURLProtocol) and [EGOCache](https://github.com/enormego/EGOCache). Working For the situation that Hybird App cache web resources for making url load more fast.

It have three main features.

![Architecture](https://raw.githubusercontent.com/Fykec/RNCachingURLProtocol/master/Architecture/RNCachingURLProtocol%2BHybirdApp.png)

1. Cache request for html, images, js, etc.
2. Support reload no cache by adding http header key **RNCachingReloadIgnoringCacheHeader**, You can display cache to user first, and then load new rescource in background.
3. Host white list and exception rules, host list can only cache for your own hosts and CDNs, no need cache for 3rd services. exception rules that is regex can match the url string, you can use something like **xxx.com/api/** to filter out the api call.

# USAGE

1. Include by Cocoapods
`pod 'RNCachingURLProtocol+HybirdApp', :git => "git@github.com:Fykec/RNCachingURLProtocol.git"`.

2. At some point early in the program (usually `application:didFinishLaunchingWithOptions:`),
   call the following:

      ```
    [RNCachingURLProtocol setSupportedSchemes:[NSSet setWithArray:@[@"http", @"https"]]];
    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];
    [[RNCache sharedInstance] setDefaultTimeoutInterval:7 * 24 * 60 * 60];//7 days for cache a resource
    [[RNCache sharedInstance] setHostList:@[@"github.com", @"assets-cdn.github.com", @"collector-cdn.github.com"]];// host and CDNs
    [[RNCache sharedInstance] setExceptionRules:@[@"api.github.com"]];//no cache for api call
      ```

3. If you want load new web resource after load cache you can

	```
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
	```

For more details see [ViewController Code](https://github.com/Fykec/RNCachingURLProtocol/blob/master/CachedWebView/ViewController.m)
   

# EXAMPLE

See the CachedWebView project for example usage.

# LICENSE

 This code is licensed under the MIT License:
 
 Permission is hereby granted, free of charge, to any person obtaining a
 copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
