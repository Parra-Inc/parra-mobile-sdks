//
//  PARViewController.m
//  Demo
//
//  Created by Mick MacCallum on 4/12/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

#import "PARViewController.h"
@import ParraCore;
@interface PARViewController ()

@end

@implementation PARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This code is for sample purposes only. It isn't invoked from anywhere inside this sample app.

    NSString *myAppAccessToken = @"9B5CDA6B-7538-4A2A-9611-7308D56DFFA1";

    [PARParraCore setAuthenticationProviderWithCompletion:^(void (^ _Nonnull completion)(PARParraCredential * _Nullable, NSError * _Nullable)) {
        // Replace this with your Parra access token generation endpoint
        NSURL *authenticationUrl = [NSURL URLWithString:@"http://localhost:8080/v1/parra/auth/token"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authenticationUrl];
        [request setHTTPMethod:@"POST"];
        [request addValue:[NSString stringWithFormat:@"Bearer %@", myAppAccessToken] forHTTPHeaderField:@"Authorization"];
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[request copy]
                                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                completion(nil, error);
            } else {
                NSError *jsonError = nil;
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                if (jsonError) {
                    completion(nil, jsonError);
                } else {
                    PARParraCredential *credential = [PARParraCredential credentialWithToken:responseObject[@"access_token"]];
                    completion(credential, nil);
                }
            }
        }];
        
        [task resume];
    }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
