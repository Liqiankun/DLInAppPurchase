//
//  ViewController.m
//  DLInAppPurchase
//
//  Created by FT_David on 2017/2/16.
//  Copyright © 2017年 FT_David. All rights reserved.
//

#import "DLInAppPurchase.h"
#import "DLProductCell.h"
#import "SVProgressHUD.h"
#import <StoreKit/StoreKit.h>

@interface DLInAppPurchase ()<UITableViewDelegate,UITableViewDataSource,SKProductsRequestDelegate,SKPaymentTransactionObserver>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *productIDArray;
@end

@implementation DLInAppPurchase

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"productIDS" ofType:@"plist"];
    self.productIDArray =  [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    //监听购买结果
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productIDArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productCellID"];
    cell.productID = self.productIDArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *productID = self.productIDArray[indexPath.row];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[productID]]];
    request.delegate = self;
    [request start];
    [SVProgressHUD showWithStatus:@"正在加载"];
}

#pragma mark - SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (response.invalidProductIdentifiers.count > 0) {
        [SVProgressHUD showErrorWithStatus:@"ProductID为无效ID"];
    }else{
        //取到内购产品进行购买
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:response.products.firstObject];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}


#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://购买成功
                [self dl_completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://购买失败
                [self dl_failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://恢复购买
                [self dl_restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing://正在处理
                break;
            default:
                break;
        }
    }
    
}


#pragma mark - PrivateMethod
- (void)dl_completeTransaction:(SKPaymentTransaction *)transaction {
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    if ([receipt length] > 0 && [productIdentifier length] > 0) {
        [SVProgressHUD showSuccessWithStatus:@"支付成功"];
        /** 
         可以将receipt发给服务器进行购买验证
         */
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)dl_failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        [SVProgressHUD showErrorWithStatus:@"用户取消支付"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"支付失败"];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)dl_restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)dl_validateReceiptWiththeAppStore:(NSString *)receipt
{
    NSError *error;
    NSDictionary *requestContents = @{@"receipt-data": receipt};
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    
    if (!requestData) {
    
    }else{
        
    }
    NSURL *storeURL;
#ifdef DEBUG
    storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
#else
    storeURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
#endif
    
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                  /* 处理error */
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonResponse) {
                                       /* 处理error */
                                   }else{
                                       /* 处理验证结果 */
                                   }
                               }
                           }];

}

-(void)dealloc
{
    //移除购买结果监听
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
