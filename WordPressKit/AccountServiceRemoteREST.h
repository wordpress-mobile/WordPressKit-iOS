#import <Foundation/Foundation.h>
#import "AccountServiceRemote.h"
#import "ServiceRemoteWordPressComREST.h"

static NSString * const AccountServiceRemoteErrorDomain = @"AccountServiceErrorDomain";

typedef NS_ERROR_ENUM(AccountServiceRemoteErrorDomain, AccountServiceRemoteError) {
    AccountServiceRemoteCantReadServerResponse,
    AccountServiceRemoteEmailAddressInvalid,
    AccountServiceRemoteEmailAddressTaken,
};

@interface AccountServiceRemoteREST : ServiceRemoteWordPressComREST <AccountServiceRemote>

@end
