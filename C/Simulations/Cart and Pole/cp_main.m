#include "CPSimulation.h"
#include "GLISimController.h"

//NOTE!! HAVE DELETED PATH TO LINKMAP FILE:
//$(TARGET_TEMP_DIR)/$(PRODUCT_NAME)-LinkMap-$(CURRENT_VARIANT)-$(CURRENT_ARCH).txt
//and lib search path:
///Users/bh0085/Programming/PhysicsEngines/Box2D_v2.0.1/Box2D/Source/Gen/float/
//and lib search path in target:
//$(inherited) "$(SRCROOT)/../../C++/Box2DHelloWorld" /opt/local/lib "$(SRCROOT)/../../PhysicsEngines/Box2D_v2.0.1/Box2D/Source/Gen/fixed" "$(SRCROOT)/../../gcclib" "$(SRCROOT)/../../usr/local/lib" "$(SRCROOT)/../../gcclib/Algorithms" "$(SRCROOT)/../../PhysicsEngines/Box2D_v2.0.1/Box2D/Source/Gen/float"


//..../Users/bh0085/Programming/PhysicsEngines/Box2D_v2.0.1/Box2D/Source/Gen/float/
int main(int argc, char *argv[])
{
	srand ( (unsigned)time ( NULL ) );
	NSAutoreleasePool  * pool = [[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];
	GLISimController * controller = [GLISimController new];
	[NSApp setDelegate: controller];
	[pool release];
    return NSApplicationMain(argc,  (const char **) argv);	
}
