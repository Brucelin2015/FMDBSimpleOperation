//
//  ViewController.m
//  2_FMDB数据库中级测试
//
//  Created by 林成龙 on 16/12/30.
//  Copyright © 2016年 林成龙. All rights reserved.
//

#import "ViewController.h"
#import "fmdb/FMDatabase.h"
#import "Student.h"

@interface ViewController ()
- (IBAction)queryDataBaseBtnClick:(id)sender;
- (IBAction)deleteData:(id)sender;
- (IBAction)updateData:(id)sender;
@property (nonatomic,strong) NSMutableArray *students;
@property (nonatomic,strong) FMDatabase *db;
@end

@implementation ViewController

- (NSMutableArray *)students {
    if (_students == nil) {
        _students = [[NSMutableArray alloc]init];
    }
    return _students;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //判断是否存在数据库，如果有，就继续
    //如果没有就将工程里面的复制到Document
    //获取文档路径
    NSArray *searchPaths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [searchPaths objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"studentDB.db"];
    NSLog(@"%@",dbPath);
    
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    BOOL isExit = [fileManager fileExistsAtPath:dbPath];
    //如果不存在，讲工程里面数据库的复制到Document里面
    if (!isExit) {
        NSLog(@"原来不存在数据库");
        
        //获取工程里面的数据库路径
        NSString *studentDBPath = [[NSBundle mainBundle] pathForResource:@"studentSqlite" ofType:@"db"];
        NSLog(@"%@",studentDBPath);
        BOOL success = [fileManager copyItemAtPath:studentDBPath toPath:dbPath error:nil];
        if (success) {
            NSLog(@"数据库复制成功");
        }
        
    }
    
    
    
    //1.获得数据库文件的路径
    
    FMDatabase *database = [[FMDatabase alloc]initWithPath:dbPath];
    
    if ([database open]) {
        NSLog(@"打开数据库成功");
    }
    self.db = database;
    
    
    
}
#pragma mark - 查询数据库
- (IBAction)queryDataBaseBtnClick:(id)sender {
    [self queryData:self.db];
    NSLog(@"%@",self.students);
}

#pragma mark - 删除数据
- (IBAction)deleteData:(id)sender {
    
    NSString *deleteData = [NSString stringWithFormat:@"delete from student where number = 15 "];
    //开始一直没有删除成功， 原因是 把数据库的 名字写成了表的名字了
    BOOL success = [self.db executeUpdate:deleteData];
    if (success) {
        NSLog(@"删除成功");
    }
}


#pragma mark - 添加数据
- (IBAction)updateData:(id)sender {
    NSString *name = @"新添加的";
    NSInteger age = arc4random();
    
    BOOL success = [self.db executeUpdate:@"insert into student (name,age) values(?,?)",name,@(age)];
    if (!success) {
        NSLog(@"=====%@",[self.db lastErrorMessage]);
    }
    
}

- (void)queryData:(FMDatabase*)database {
    FMResultSet *resultSet = [database executeQuery:@"select * from student;"];
    
    while ([resultSet next]) {
        Student *stu = [[Student alloc]init];
        stu.number = [resultSet intForColumn:@"number"];
        stu.name = [resultSet objectForColumnName:@"name"];
        stu.age = [resultSet intForColumn:@"age"];
        /**一开始，数组students没有数据，而且也添加不进去数据，是因为：没有初始化，即没有内存空间放数据*/
        [self.students addObject:stu];
    }
}


@end
