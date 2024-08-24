#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <substrate.h>
#import <dlfcn.h>

namespace spb_UIKeyboardDeviceSupportsSplit {
    BOOL (*original)();
    BOOL custom() {
        return YES;
    }
    void hook() {
        void *handle = dlopen("/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore", RTLD_NOW);
        void *symbol = dlsym(handle, "UIKeyboardDeviceSupportsSplit");
        MSHookFunction(symbol, reinterpret_cast<void *>(&custom), reinterpret_cast<void **>(&original));
    }
}

namespace spb_UIKeyboardPreferencesController {
    namespace enableProKeyboard {
        BOOL (*original)(id, SEL);
        BOOL custom(id, SEL) {
            return YES;
        }
        void hook() {
            MSHookMessageEx(objc_lookUpClass("UIKeyboardPreferencesController"),
                            sel_registerName("enableProKeyboard"),
                            reinterpret_cast<IMP>(&custom),
                            reinterpret_cast<IMP *>(&original));
        }
    }
}

__attribute__((constructor)) static void init() {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    spb_UIKeyboardDeviceSupportsSplit::hook();
    spb_UIKeyboardPreferencesController::enableProKeyboard::hook();

    [pool release];
}
