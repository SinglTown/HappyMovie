

#import <UIKit/UIKit.h>
#import "CommonDefine.h"
@interface AudioViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
}

@property (strong, nonatomic) NSMutableArray *allAudios;

@property (copy, nonatomic) GenericCallback seletedRowBlock;

@end
