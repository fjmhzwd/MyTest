//
//  ViewController.m
//  MyTest
//
//  Created by wayne on 14-11-7.
//  Copyright (c) 2014年 wayne. All rights reserved.
//

#import "ViewController.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <objc/runtime.h>
#import "HanyuPinyinOutputFormat.h"
#import "PinyinHelper.h"
#import "PinYinForObjc.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UIButton *testBtn;
    CGPoint startPoint;
    NSMutableArray *sectionTitleArray;
}

@property (weak, nonatomic) IBOutlet UILabel *labTest;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickDate;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lx;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ly;
@property (weak, nonatomic) IBOutlet UIButton *btnMove;
@property (weak, nonatomic) IBOutlet UIView *uvMove;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moveLayout;
@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

//load方法会在类第一次加载的时候被调用
//调用的时间比较靠前，适合在这个方法里做方法交换
+ (void)load{
    //方法交换应该被保证，在程序中只会执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //获得viewController的生命周期方法的selector
        SEL systemSel = @selector(viewWillAppear:);
        //自己实现的将要被交换的方法的selector
        SEL swizzSel = @selector(swiz_viewWillAppear:);
        //两个方法的Method
        Method systemMethod = class_getInstanceMethod([self class], systemSel);
        Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
        //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
        BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
        if (isAdd) {
            //如果成功，说明类中不存在这个方法的实现
            //将被交换方法的实现替换到这个并不存在的实现
            class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
        }else{
            //否则，交换两个方法的实现
            method_exchangeImplementations(systemMethod, swizzMethod);
        }
    });
}

- (void)swiz_viewWillAppear:(BOOL)animated{
    //这时候调用自己，看起来像是死循环
    //但是其实自己的实现已经被替换了
    [self swiz_viewWillAppear:animated];
    NSLog(@"swizzle");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *test = NSLocalizedString(@"aa", nil);
    NSLog(test);
    self.title = test;
//    [self.labTest systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    320*480 320*568 {375, 667}  {414, 736}
    NSLog(@"%@", NSStringFromCGRect([UIScreen mainScreen].bounds));
    self.pickDate.locale =   [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    if (self.labTest.translatesAutoresizingMaskIntoConstraints)
        NSLog(@"1");
    else
        NSLog(@"2");
//    self.extendedLayoutIncludesOpaqueBars
//    self.edgesForExtendedLayout
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.btnMove addGestureRecognizer:pan];
//    2.000000--{29, 86.5}--{{11.5, 60}, {72, 59}}
//    CGAffineTransform indent = CGAffineTransformIdentity;
//    self.uvMove.transform = CGAffineTransformTranslate(indent, 1, 0);
//    indent = CGAffineTransformIdentity;
//    self.uvMove.transform = CGAffineTransformTranslate(indent, 9.5, 0);
    
//    self.btnMove.userInteractionEnabled = NO;
    [self testBtnHugging];
    [self testBtnCompress];
    
    NSString *pin = @"z你好wd";
    HanyuPinyinOutputFormat *outputFormat = [[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    NSString *dest = [PinyinHelper getFirstHanyuPinyinStringWithChar:[pin characterAtIndex:0] withHanyuPinyinOutputFormat:outputFormat];
    NSLog(@"%@", dest);
    NSLog(@"%@", [[PinYinForObjc chineseConvertToPinYin:pin]substringToIndex:1]
          );
    NSLog(@"%@", [PinYinForObjc chineseConvertToPinYinHead:pin]);
    
    
    sectionTitleArray = [NSMutableArray arrayWithObjects:UITableViewIndexSearch,@"1-10",@"11-20",@"21-30",@"31-40",@"41-50",@"51-60",@"61-70",@"71-80",@"81-90",@"91-100", nil];
    
    
//    
//    UIView *hview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.f, 200.f)];
//    
//    hview.backgroundColor = [UIColor orangeColor];
//    
//    listTableView.tableHeaderView = hview;
//    po [[UIWindow keyWindow] _autolayoutTrace]
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [pan translationInView:self.view];
            if (translation.x <= 0) return;
            CGPoint center = self.btnMove.center;
            center.x += translation.x;
            CGFloat detalX = translation.x;
            if (detalX >100)
            {
                detalX = 100;
            }
//            self.btnMove.center = center;
//            NSLog(@"%f--%@", translation.x , NSStringFromCGRect(self.btnMove.frame));
            CGAffineTransform indent = CGAffineTransformIdentity;
            self.btnMove.transform = CGAffineTransformTranslate(indent, detalX, 0);
            if (detalX >= 100)
            {
//                pan.cancelsTouchesInView = YES;
            }
//            [pan setTranslation:CGPointZero inView:self.btnMove];
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
             CGPoint translation = [pan translationInView:self.view];
            if (translation.x < 100)
            {
                [UIView animateWithDuration:5 animations:^{
                    self.btnMove.transform = CGAffineTransformIdentity;
                }];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled: {
            [UIView animateWithDuration:5 animations:^{
                self.btnMove.transform = CGAffineTransformIdentity;
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view != self.uvMove) return;
    startPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
     UITouch *touch = [touches anyObject];
    if (touch.view != self.uvMove) return;
    CGPoint point = [touch locationInView:self.view];
    CGFloat detalX = point.x- startPoint.x;
    if (detalX <= 0) return;
    if (detalX >100)
    {
        detalX = 100;
    }
    self.moveLayout.constant =  detalX;
//    CGRect rect = self.uvMove.frame;
//    rect.origin.x = detalX + 10;
//    self.uvMove.frame = rect;
//    CGAffineTransform indent = CGAffineTransformIdentity;
//    self.uvMove.transform = CGAffineTransformTranslate(indent, detalX, 0);
    NSLog(@"%f--%@--%@", detalX, NSStringFromCGPoint(point), NSStringFromCGRect(self.uvMove.frame));
    if (detalX >= 100)
    {

    }
//    startPoint = point;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:5 animations:^{
//        self.uvMove.transform = CGAffineTransformIdentity;
        self.moveLayout.constant = 0;
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view != self.uvMove) return;
    CGPoint point = [touch locationInView:self.view];
//     CGFloat detalX = point.x- startPoint.x;
//    if (detalX < 100)
    {
        [UIView animateWithDuration:0.35 animations:^{
//            CGRect rect = self.uvMove.frame;
//            rect.origin.x = 10;
//            self.uvMove.frame = rect;
//            self.uvMove.transform = CGAffineTransformIdentity;
            self.moveLayout.constant = 0;
        } completion:^(BOOL finished) {
            NSLog(@"%@--%@", NSStringFromCGPoint(point), NSStringFromCGRect(self.uvMove.frame));
        }];
    }
}

/*
 因为涉及约束问题，因此约束模型下的所有可能出现的问题这里都会出现，具体来说包括两种：
 
 Ambiguous Layout 布局不能确定
 Unsatisfiable Constraints 无法满足约束
 
 布局不能确定指的是给出的约束条件无法唯一确定一种布局，也即约束条件不足，无法得到唯一的布局结果。这种情况一般添加一些必要的约束或者调整优先级可以解决。无法满足约束的问题来源是有约束条件互相冲突，因此无法同时满足，需要删掉一些约束。两种错误在出现时均会导致布局的不稳定和错误，Ambiguous可以被容忍并且选择一种可行布局呈现在UI上，Unsatisfiable的话会无法得到UI布局并报错。 对于不能确定的布局，可以通过调试时暂停程序，在debugger中输入
 
 po [[UIWindow keyWindow] _autolayoutTrace]
 
 来检查是否存在Ambiguous Layout以及存在的位置，来帮助添加条件。另外还有一些检查方法，来查看view的约束和约束状态：
 
 [view constraintsAffectingLayoutForAxis: NSLayoutConstraintOrientationHorizontal/Vertical]
 [view hasAmbiguousLayout]
 [view exerciseAmbiguityInLayout]

 
 兄弟 view 的 Constraint 添加到他们的 superview
 
 兄弟 view 之间添加 Constraint 到 superview
 
 两个 view 的父 view 是兄弟关系的，Constraint 添加到父 view 的 superview 上
 
 父 view 是兄弟关系的，Constraint 添加到父 view 的 superview 上
 
 如果两个 view 是 parent-child 关系，Constraint 添加到 parent view上
 
 如果两个 view 是 parent-child 关系，Constraint 添加到 parent view上
 
 ----------
 contentHugging: 抱住使其在“内容大小”的基础上不能继续变大 contentCompression: 撑住使其在在其“内容大小”的基础上不能继续变小
 
 这两个属性分别可以设置水平方向和垂直方向上的，而且一个默认优先级是250， 一个默认优先级是750. 因为这两个很有可能与其他Constraint冲突，所以优先级较低。

 Hugging priority 确定view有多大的优先级阻止自己变大。
 
 Compression Resistance priority确定有多大的优先级阻止自己变小。
 
 很抽象，其实content Hugging就是要维持当前view在它的optimal size（intrinsic content size），可以想象成给view添加了一个额外的width constraint，此constraint试图保持view的size不让其变大：
 
 view.width <= optimal size
 
 此constraint的优先级就是通过上面的方法得到和设置的，content Hugging默认为250.
 
 Content Compression Resistance就是要维持当前view在他的optimal size（intrinsic content size），可以想象成给view添加了一个额外的width constraint，此constraint试图保持view的size不让其变小：
 
 view.width >= optimal size
 
 此默认优先级为750.
*/
- (void)testBtnHugging
{
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.translatesAutoresizingMaskIntoConstraints = NO;
    button1.backgroundColor = [UIColor yellowColor];
    [button1 setTitle:@"button 1 button 2" forState:UIControlStateNormal];
    [button1 sizeToFit];
    
    [self.view addSubview:button1];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:100.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-10.0f];
    constraint.priority = 249.0f;
    [self.view addConstraint:constraint];
}

- (void)testBtnCompress
{
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.backgroundColor = [UIColor redColor];
    button1.translatesAutoresizingMaskIntoConstraints = NO;
    [button1 setTitle:@"button 1 button 2" forState:UIControlStateNormal];
    [button1 sizeToFit];
    
    [self.view addSubview:button1];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:100.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:100.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-150.0f];
    constraint.priority = 749.0f;
    [self.view addConstraint:constraint];
    testBtn = button1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"SSS=%@;UITableViewAutomaticDimension=%f",[self.view constraintsAffectingLayoutForAxis: UILayoutConstraintAxisHorizontal], UITableViewAutomaticDimension);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 
 struct CATransform3D
 {
 CGFloat     m11（x缩放）,    m12（y切变）,      m13（旋转）,     m14（）;
 
 CGFloat     m21（x切变）,    m22（y缩放）,      m23（）,             m24（）;
 
 CGFloat     m31（旋转）,      m32（ ）,               m33（）,              m34（透视效果，要操作的这个对象要有旋转的角度，否则没有效果。正直/负值都有意义）;
 
 CGFloat     m41（x平移）,     m42（y平移）,     m43（z平移）,     m44（）;
 };

*/
static inline double radians (double degrees)
{return degrees * M_PI/180;}


- (IBAction)btnClick:(id)sender {
    [UIView animateWithDuration:10.0 animations:^{
        self.img.layer.transform = CATransform3DMakeTranslation(2, 2, 1.0);
        
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(60, 140);
//        //Scale
//        transform = CGAffineTransformScale(transform, 0.5, 0.5);
//        //Rotate
//        transform = CGAffineTransformRotate(transform, radians(60));
//        self.img.transform = transform;
//        self.img.layer.transform = CATransform3DMakeScale(1.0, 2.0, 2.0);
//        self.img.layer.transform = CATransform3DMakeRotation(radians(45.0), 1.0, 0.1, 1.0);
    }];

}
- (IBAction)btnResume:(id)sender {
    self.img.layer.transform = CATransform3DIdentity;
}

- (void)test
{
    //手机序列号
    NSString* identifierForVendor = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    NSLog(@"手机序列号: %@",identifierForVendor);
    //手机别名： 用户定义的名称
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSLog(@"手机别名: %@", userPhoneName);
    //设备名称
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    NSLog(@"设备名称: %@",deviceName );
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"手机系统版本: %@", phoneVersion);
    //手机型号
    NSString* phoneModel = [[UIDevice currentDevice] model];
    NSLog(@"手机型号: %@",phoneModel );
    //地方型号  （国际化区域名称）
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
    NSLog(@"国际化区域名称: %@",localPhoneModel );
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用名称
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSLog(@"当前应用名称：%@",appCurName);
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"当前应用软件版本:%@",appCurVersion);
    // 当前应用版本号码   int类型
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSLog(@"当前应用版本号码：%@",appCurVersionNum);
    NSLog(@"%@", [self getCurrentDeviceModel]);
}

//获取系统版本号
- (NSString *)getCurrentDeviceModel
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

+ (UIImage *)rotate:(UIImage*)src orientation:(UIImageOrientation) orientation {
    UIGraphicsBeginImageContext(src.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    [src drawAtPoint:CGPointMake(0, 0)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)launchImage {
    NSDictionary *dOfLaunchImage = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"LaunchImage-568h@2x.png",@"568,320,2,8,p", // ios 8 - iphone 5 - portrait
                                    @"LaunchImage-568h@2x.png",@"568,320,2,8,l", // ios 8 - iphone 5 - landscape
                                    @"LaunchImage-700-568h@2x.png",@"568,320,2,7,p", // ios 7 - iphone 5 - portrait
                                    @"LaunchImage-700-568h@2x.png",@"568,320,2,7,l", // ios 7 - iphone 5 - landscape
                                    @"LaunchImage-700-Landscape@2x~ipad.png",@"1024,768,2,7,l", // ios 7 - ipad retina - landscape
                                    @"LaunchImage-700-Landscape~ipad.png",@"1024,768,1,7,l", // ios 7 - ipad regular - landscape
                                    @"LaunchImage-700-Portrait@2x~ipad.png",@"1024,768,2,7,p", // ios 7 - ipad retina - portrait
                                    @"LaunchImage-700-Portrait~ipad.png",@"1024,768,1,7,p", // ios 7 - ipad regular - portrait
                                    @"LaunchImage-700@2x.png",@"480,320,2,7,p", // ios 7 - iphone 4/4s retina - portrait
                                    @"LaunchImage-700@2x.png",@"480,320,2,7,l", // ios 7 - iphone 4/4s retina - landscape
                                    @"LaunchImage-Landscape@2x~ipad.png",@"1024,768,2,8,l", // ios 8 - ipad retina - landscape
                                    @"LaunchImage-Landscape~ipad.png",@"1024,768,1,8,l", // ios 8 - ipad regular - landscape
                                    @"LaunchImage-Portrait@2x~ipad.png",@"1024,768,2,8,p", // ios 8 - ipad retina - portrait
                                    @"LaunchImage-Portrait~ipad.png",@"1024,768,1,8,l", // ios 8 - ipad regular - portrait
                                    @"LaunchImage.png",@"480,320,1,7,p", // ios 6 - iphone 3g/3gs - portrait
                                    @"LaunchImage.png",@"480,320,1,7,l", // ios 6 - iphone 3g/3gs - landscape
                                    @"LaunchImage@2x.png",@"480,320,2,8,p", // ios 6,7,8 - iphone 4/4s - portrait
                                    @"LaunchImage@2x.png",@"480,320,2,8,l", // ios 6,7,8 - iphone 4/4s - landscape
                                    @"LaunchImage-800-667h@2x.png",@"667,375,2,8,p", // ios 8 - iphone 6 - portrait
                                    @"LaunchImage-800-667h@2x.png",@"667,375,2,8,l", // ios 8 - iphone 6 - landscape
                                    @"LaunchImage-800-Portrait-736h@3x.png",@"736,414,3,8,p", // ios 8 - iphone 6 plus - portrait
                                    @"LaunchImage-800-Landscape-736h@3x.png",@"736,414,3,8,l", // ios 8 - iphone 6 plus - landscape
                                    nil];
    NSInteger width = ([UIScreen mainScreen].bounds.size.width>[UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height;
    NSInteger height = ([UIScreen mainScreen].bounds.size.width>[UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width;
    NSInteger os = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    NSString *strOrientation = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])?@"l":@"p";
    NSString *strImageName = [NSString stringWithFormat:@"%li,%li,%li,%li,%@",width,height,(NSInteger)[UIScreen mainScreen].scale,os,strOrientation];
    UIImage *imageToReturn = [UIImage imageNamed:[dOfLaunchImage valueForKey:strImageName]];
    if([strOrientation isEqualToString:@"l"] && [strImageName rangeOfString:@"Landscape"].length==0) {
        imageToReturn = [self rotate:imageToReturn orientation:UIImageOrientationRight];
    }
    return imageToReturn;
}

+(NSString*)getLaunchImageName
{
    
    NSArray* images= @[@"LaunchImage.png", @"LaunchImage@2x.png",@"LaunchImage-700@2x.png",@"LaunchImage-568h@2x.png",@"LaunchImage-700-568h@2x.png",@"LaunchImage-700-Portrait@2x~ipad.png",@"LaunchImage-Portrait@2x~ipad.png",@"LaunchImage-700-Portrait~ipad.png",@"LaunchImage-Portrait~ipad.png",@"LaunchImage-Landscape@2x~ipad.png",@"LaunchImage-700-Landscape@2x~ipad.png",@"LaunchImage-Landscape~ipad.png",@"LaunchImage-700-Landscape~ipad.png"];
    
    UIImage *splashImage;
    
    if ([self isDeviceiPhone])
    {
        if ([self isDeviceiPhone4] && [self isDeviceRetina])
        {
            splashImage = [UIImage imageNamed:images[1]];
            if (splashImage.size.width!=0)
                return images[1];
            else
                return images[2];
        }
        else if ([self isDeviceiPhone5])
        {
            splashImage = [UIImage imageNamed:images[1]];
            if (splashImage.size.width!=0)
                return images[3];
            else
                return images[4];
        }
        else
            return images[0]; //Non-retina iPhone
    }
    else if ([[UIDevice currentDevice] orientation]==UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)//iPad Portrait
    {
        if ([self isDeviceRetina])
        {
            splashImage = [UIImage imageNamed:images[5]];
            if (splashImage.size.width!=0)
                return images[5];
            else
                return images[6];
        }
        else
        {
            splashImage = [UIImage imageNamed:images[7]];
            if (splashImage.size.width!=0)
                return images[7];
            else
                return images[8];
        }
        
    }
    else
    {
        if ([self isDeviceRetina])
        {
            splashImage = [UIImage imageNamed:images[9]];
            if (splashImage.size.width!=0)
                return images[9];
            else
                return images[10];
        }
        else
        {
            splashImage = [UIImage imageNamed:images[11]];
            if (splashImage.size.width!=0)
                return images[11];
            else
                return images[12];
        }
    }
}

+(BOOL)isDeviceiPhone
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return TRUE;
    }
    
    return FALSE;
}

+(BOOL)isDeviceiPhone4
{
    if ([[UIScreen mainScreen] bounds].size.height==480)
        return TRUE;
    
    return FALSE;
}


+(BOOL)isDeviceRetina
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0))        // Retina display
    {
        return TRUE;
    }
    else                                          // non-Retina display
    {
        return FALSE;
    }
}


+(BOOL)isDeviceiPhone5
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height>480)
    {
        return TRUE;
    }
    return FALSE;
}

- (void)viewDidLayoutSubviews
{
    
}

/*
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sadfasfd";
    NSLog(@"cellforrow=%ld", indexPath.row);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if ((indexPath.row % 2) == 0)
        cell.backgroundColor = [UIColor whiteColor];
    else
        cell.backgroundColor = [UIColor purpleColor];
    cell.textLabel.text = [NSString stringWithFormat:@"A-%d", indexPath.row + 1];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"detail-%d", indexPath.row + 1];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"estimated indexpath=%ld",indexPath.row);
    return 120.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"height indexpath=%ld",indexPath.row);
    return 30.0;
}
//- (CGFloat)autoAdjustedCellHeightAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
//    return 1.0;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [NSArray arrayWithObjects:@"1-10",@"11-20",@"21-30",@"31-40",@"41-50",@"51-60",@"61-70",@"71-80",@"81-90",@"91-100", nil];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}
*/
//右边索引 字节数(如果不实现 就不显示右侧索引)

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    
    
    return sectionTitleArray;
    
}


//section （标签）标题显示

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //改变索引的颜色
    tableView.sectionIndexColor = [UIColor redColor];
    tableView.sectionIndexBackgroundColor = [UIColor greenColor];
    //改变索引选中的背景颜色
    tableView.sectionIndexTrackingBackgroundColor = [UIColor yellowColor];
    
    
    return [sectionTitleArray objectAtIndex:section + 1];
    
}



//标签数

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 10;
    
}


// 设置section的高度

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        
        return 80;
        
    }
    
    return 20;
    
}


//点击右侧索引表项时调用

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    
    
    NSString *key = [sectionTitleArray objectAtIndex:index];
    
    NSLog(@"sectionForSectionIndexTitle key=%@",key);
    
    if (key == UITableViewIndexSearch) {
        //index是索引条的序号。从0开始，所以第0 个是放大镜。如果是放大镜坐标就移动到搜索框处
//        [tableView scrollRectToVisible:_searchBar.frame animated:NO];
        
        [tableView setContentOffset:CGPointZero animated:NO];
        
        return NSNotFound;
        
    }
    
    
    
    return index-1;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    UIView *v = nil;
    
    if (section == 0) {
        
        v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        
        [v setBackgroundColor:[UIColor grayColor]];
        
        
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 10.0f, 200.0f, 30.0f)];
        
        [labelTitle setBackgroundColor:[UIColor clearColor]];
        
        labelTitle.textAlignment = NSTextAlignmentCenter;
        
        labelTitle.text = @"第一个section 定制页面";
        
        [v addSubview:labelTitle];
        
    }
    
    
    
    return v;
    
}


// 设置cell的高度

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return 44;
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    
    return 10;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *detailIndicated = @"tableCell";
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailIndicated];
    
    
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailIndicated];
        
        cell.tag = indexPath.row;
        
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d",10*indexPath.section + indexPath.row + 1];
    
    
    
    return cell;
    
}

/*
 IOS7 SIZE CLASSES 早期版本支持
 
 https://developer.apple.com/library/prerelease/ios/recipes/xcode_help-IB_adaptive_sizes/chapters/DeployingSizeClassesonEarlieriOSVersions.html#//apple_ref/doc/uid/TP40014436-CH13-SW1
 Deploying an App with Size Classes on Earlier iOS Versions
 
 For apps supporting versions of iOS earlier than iOS 8, most size classes are backward compatible.
 
 Size classes are backward compatible when:
 
 The app is built using Xcode version 6 or later
 
 The deployment target of the app is earlier than iOS 8
 
 Size classes are specified in a storyboard or xib file
 
 The value of the height component is not compact
 
 
 创建一个AutoLayout需要七个参数，他们分别是（1）WithItem：被约束对象  （2）第一个attribute：被约束对象的关系   （3）relatedBy:约束描述  （4）toItem:约束源   （5）第二个attribute：约束源的关系  （6）multiplier：约束系数  （7）constant：约束常数
*/
/*
 1.edgesForExtendedLayout：这个属性属于UIExtendedEdge类型，它可以单独指定矩形的四条边，也可以单独指定、指定全部、全部不指定。
 
 使用edgesForExtendedLayout指定视图的哪条边需要扩展，不用理会操作栏的透明度。这个属性的默认值是UIRectEdgeAll。
 
 2.extendedLayoutIncludesOpaqueBars：
 如果你使用了不透明的操作栏，设置edgesForExtendedLayout的时候也请将 extendedLayoutIncludesOpaqueBars的值设置为No（默认值是YES）。
 
 3.automaticallyAdjustsScrollViewInsets：如果你不想让scroll view的内容自动调整，将这个属性设为NO（默认值YES）。
 
 armv6：iPhone 2G/3G，iPod 1G/2G
 armv7：iPhone 3GS/4/4s，iPod 3G/4G，iPad 1G/2G/3G ,iPad Mini 1
 armv7s：iPhone5 ,iPhone5C ,iPad4
 armv8：iPhone5S ,iPad5(iPad Air), iPad Mini 2(iPad Mini Retina)
 */

/*
   unsigned int count;
     //获取属性列表
     objc_property_t *propertyList = class_copyPropertyList([self class], &count);
     for (unsigned int i=0; i<count; i++) {         const char *propertyname =" property_getName(propertyList[i]);"         nslog(@"property----="">%@", [NSString stringWithUTF8String:propertyName]);
     }
     //获取方法列表
     Method *methodList = class_copyMethodList([self class], &count);
     for (unsigned int i; i<count; i++) {         method method =" methodList[i];"         nslog(@"method----="">%@", NSStringFromSelector(method_getName(method)));
     }
     //获取成员变量列表
     Ivar *ivarList = class_copyIvarList([self class], &count);
     for (unsigned int i; i<count; i++) {         ivar myivar =" ivarList[i];"         const char *ivarname =" ivar_getName(myIvar);"         nslog(@"ivar----="">%@", [NSString stringWithUTF8String:ivarName]);
     }
     //获取协议列表
     __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
     for (unsigned int i; i<count; i++) {         protocol *myprotocal =" protocolList[i];"         const char *protocolname =" protocol_getName(myProtocal);"         nslog(@"protocol----="">%@", [NSString stringWithUTF8String:protocolName]);
     }</count; i++) {></count; i++) {></count; i++) {></count; i++) {>
 在Xcode上跑一下看看输出吧，需要给你当前的类写几个属性，成员变量，方法和协议，不然获取的列表是没有东西的。
 
 

*/

@end
