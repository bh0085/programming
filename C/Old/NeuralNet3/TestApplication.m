#import "TestApplication.h"

@implementation TestApplication
- (IBAction)Button1:(id)sender {
    [TextOut setIntValue:0];	// [5.7]    
}

- (IBAction)Button2:(id)sender {
    [TextOut setIntValue:5];	// [5.7]
}

- (void)awakeFromNib	// [1.15]
{
    [TextOut setIntValue:10];
}

@end
