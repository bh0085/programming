#import <Cocoa/Cocoa.h>

@interface TestApplication : NSObject {
    IBOutlet id TextOut;
}
- (IBAction)Button1:(id)sender;
- (IBAction)Button2:(id)sender;
- (void)awakeFromNib;
@end
