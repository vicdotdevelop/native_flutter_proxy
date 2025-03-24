#import "FlutterProxyPlugin.h"
#if __has_include(<native_flutter_proxy/native_flutter_proxy-Swift.h>)
#import <native_flutter_proxy/native_flutter_proxy-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_flutter_proxy-Swift.h"
#endif

/**
 * @class FlutterProxyPlugin
 * @brief An Objective-C wrapper for the Swift Flutter plugin.
 *
 * This class registers the Swift implementation of the plugin with the Flutter engine.
 */
@implementation FlutterProxyPlugin

/**
 * Registers the plugin with the Flutter plugin registrar.
 *
 * @param registrar The Flutter plugin registrar.
 */
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterProxyPlugin registerWithRegistrar:registrar];
}

@end