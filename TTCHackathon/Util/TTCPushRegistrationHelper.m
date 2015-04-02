//
//  TTCPushRegistrationHelper.m
//  TTCHackathon
//
//  Created by Rob Szumlakowski on 2014-09-23.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <MSSPush/MSSPush.h>
#import <MSSPush/MSSParameters.h>
#import "TTCPushRegistrationHelper.h"
#import "TTCSettings.h"

@implementation TTCPushRegistrationHelper

/* Registering for notifications with the Push Service */
+ (void) initialize:(NSSet*)pushTags
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [MSSPush setRegistrationParameters:[TTCPushRegistrationHelper getParameters:pushTags]];
    
    [MSSPush setCompletionBlockWithSuccess:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // iOS 8.0+
        UIUserNotificationType notificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        
    } else {
        
        // < iOS 8.0
        UIRemoteNotificationType notificationType = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [MSSPush setRemoteNotificationTypes:notificationType];
    }
    
    [MSSPush registerForPushNotifications];
}

+ (void) unregister
{
    void (^successBlock)() = ^{
        NSLog(@"Successfully unregistered from push notifications.");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    void (^failureBlock)(NSError*) = ^(NSError *error) {
        NSLog(@"Error upon unregistering from push notifications: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MSSPush setRegistrationParameters:[TTCPushRegistrationHelper getParameters:nil]];
    [MSSPush unregisterWithPushServerSuccess:successBlock failure:failureBlock];
}

+ (MSSParameters*) getParameters:(NSSet*)tags
{
    MSSParameters *parameters = [[MSSParameters alloc] init];
    [parameters setPushAPIURL:kPushBaseServerUrl];
    [parameters setDevelopmentPushVariantUUID:kPushDevelopmentVariantUuid];
    [parameters setDevelopmentPushVariantSecret:kPushDevelopmentVariantSecret];
    [parameters setProductionPushVariantUUID:kPushProductionVariantUuid];
    [parameters setProductionPushVariantSecret:kPushProductionVariantSecret];
    [parameters setPushDeviceAlias:kPushDeviceAlias];
    [parameters setPushTags:tags];
    return parameters;
}

@end
