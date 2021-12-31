//
//  ViewController.m
//  FTFProgressHUD
//
//  Created by 朱运 on 2021/12/23.
//

#import "ViewController.h"
#import "FTFProgressHUD.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UIView *mainView;
    
    
    
    
    UITableView *myTableView;
    NSArray *dataSource;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
//    mainView = [[UIView alloc]init];
//    mainView.frame = CGRectMake(0, 0, 300, 300);
//    mainView.center = self.view.center;
//    mainView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:mainView];
    
    
    dataSource = @[@"默认样式",@"3个白点样式",@"四方球样式",@"闪烁样式"];
    
    
    myTableView = [[UITableView alloc]init];
    myTableView.frame = CGRectMake(0, 88, self.view.bounds.size.width, self.view.bounds.size.height);
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    
//    mainView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    mainView = self.view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     
    NSUInteger code = indexPath.row;
    
    if (code == 0) {
        [FTFProgressHUD showHudInView:mainView mode:FTFHUDStyleDefault];
    }
    if (code == 1) {
        [FTFProgressHUD showHudInView:mainView mode:FTFHUDStyleSpot];
    }
    if (code == 2) {
        [FTFProgressHUD showHudInView:mainView mode:FTFHUDStyleFire];
    }
    if (code == 3) {
        [FTFProgressHUD showHudInView:mainView mode:FTFHUDStyleBlink];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [FTFProgressHUD hideHudInView:mainView];
    });

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *str = @"myStr";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    if (indexPath.row < dataSource.count) {
        cell.textLabel.text = dataSource[indexPath.row];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{


}

@end
