#import "FlutterSensorsPlugin.h"
#import <flutter_sensors/flutter_sensors-Swift.h>

@implementation FlutterSensorsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterSensorsPlugin registerWithRegistrar:registrar];
}
@end
