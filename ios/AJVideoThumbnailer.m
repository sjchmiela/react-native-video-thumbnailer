#import "AJVideoThumbnailer.h"

@implementation AJVideoThumbnailer

RCT_EXPORT_MODULE()

// STEP 2
// methodQueue is a method which defines on which queue methods should be invoked.
// This implementation specifies the main queue as the one. The code with which
// we'll generate a thumbnail doesn't need to be run on the main queue, so
// we definietely don't want to block it while generating the thumbnail.
//
// By removing the method altogether we would execute the methods on a serial
// queue shared between native modules. In fact, since access to disk may be slow,
// we would rather execute all thumbnail-generating methods on a separate queue.
// Let's change implementation of this method so it creates a new queue when called.
// (You'll need to use dispatch_queue_create method
// https://developer.apple.com/documentation/dispatch/1453030-dispatch_queue_create
// ).
//
// There is another module in React Native that utilizies this mechanism
// to execute code on a separate thread — RCTAsyncLocalStorage.
// It creates its queue like at:
// https://github.com/facebook/react-native/blob/2d8ad076feec75911f5b0a95555cc961c714d0a5/React/Modules/RCTAsyncLocalStorage.m#L128
// We can do something similar here, but
// - we should change the first argument to something more module-specific
//   like eg. "edu.appjs.videothumbnailer.AJVideoThumbnailer"
// - we could generate multiple thumbnails at the same time, so instead of
//   DISPATCH_QUEUE_SERIAL we can use DISPATCH_QUEUE_CONCURRENT.
//
// Read more on RN's threading at https://facebook.github.io/react-native/docs/native-modules-ios#threading
// More info on dispatch queues on iOS can be found at
// https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

// STEP 3
// The following couple of lines of code export a method to JS.
// RCT_EXPORT_METHOD is another C macro which takes in a method signature.
// The name of the method is the first string up to the first colon (here: sampleMethod).
//
// Another macro that one could use to expose a method to JS is RCT_REMAP_METHOD,
// which expects two arguments: a JS name of the method and then a signature.
// In our case RCT_EXPORT_METHOD(sampleMethod:…) has the same effect as if we wrote
// RCT_REMAP_METHOD(sampleMethod, sampleMethod:…).
//
// Another macro is RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD (and a corresponding RCT_REMAP_BLOCKING_…)
// which export a method that is synchronously executed on the JS thread. Probably you won't
// need this often and do note that using such methods may introduce bugs you wouldn't expect
// (see warning in RN codebase https://github.com/facebook/react-native/blob/ff66600224e78fec5d0e902f8a035b78ed31a961/React/Base/RCTBridgeModule.h#L181-L184
// ).
//
// By default, calling a native method would return undefined and the method would just run.
// To return some result to JS you would have to accept a callback as an argument and then
// call this callback with the result. (More on other types of native methods later).
//
// With all this knowledge we can see now that the method below exposes
// a `sampleMethod` function which expects three arguments: a string, a number and a function
// and will be run on the queue we specified in methodQueue function in step 2.
//
// Read more at https://github.com/facebook/react-native/blob/ff66600224e78fec5d0e902f8a035b78ed31a961/React/Base/RCTBridgeModule.h#L135-L152
RCT_EXPORT_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)
{
    // TODO: Implement
  // STEP 4
  // Add an implementation to this method that will return a "Hello from the native side!" to JS
  // with the `callback` callback. RCTResponseSenderBlock expects a single argument — an array
  // which will be used as the arguments array passed to the JS function.
  //
  // Note that in Objective-C a shorthand to create for an array is @[…elements…],
  // and to create a string you would write @"…string…".
}

// STEP 7
// Another way to share some results to JS is to create a native method which will return a Promise.
// For a native method to be Promise-based, as two last native arguments it must accept:
// RCTPromiseResolveBlock and RCTPromiseRejectBlock. As the types names suggest, the first is the block
// one would call if the JS Promise should be resolved and the second one if it should be rejected.
//
// More information on this type of native methods can be found at
// https://github.com/facebook/react-native/blob/ff66600224e78fec5d0e902f8a035b78ed31a961/React/Base/RCTBridgeModule.h#L154-L171
// Create a new exported method `generateThumbnailAsync`, which will accept two arguments: an NSString * and an NSDictionary *.

// STEP 8
// Inside the method, resolve the promise (i. e. call the resolve block) with an object { uri: null, width: 0, height: 0 }.
//
// Note that in Objective-C a shorthand to create a dictionary is @{ [key]: [value] }. Moreover,
// both keys and values put into the dictionary have to be pointers to objects, so we can't put a simple
// int as the value — it'll have to be an NSNumber *. A shorthand to creating an NSNumber out of a static value
// is @(value), eg. @(42).
//
// To pass `null` inside a dictionary, use [NSNull null] which is a pointer to a null object. More info
// on the differences between nil/null/NSNull can be found here — https://nshipster.com/nil/.

// STEP 10
// The JS-native-JS communication works, so let's actually try implementing the thumbnail generation.
// We aggregated our resources when we were designing the API, the StackOverflow answer we were going to
// inspire ourselves with was https://stackoverflow.com/questions/7501413/create-thumbnail-from-a-video-url-in-iphone-sdk/11804061#11804061.
// Copy it over the resolve call inside the method. Xcode should show multiple errors of "Use of undeclared identifier".
// This happens due to missing declarations for the classes we use. To import them, go to the top of the file
// and add import of <AVKit/AVKit.h> file.
//
// The code will still contain an error — "Use of undeclared identifier 'sourceURL'". To fix it,
// we'll need to convert the URL we get from JS to an object of class NSURL. We'll use
// initWithString:URLString initializer. Usually creating new objects in Objective-C works like:
// [[ClassName alloc] init], [[ClassName alloc] initWithSomething:…] or [[ClassName alloc] somethingNewWith:…].

// STEP 11
// Although our project would compile now, the thumbnail we generated is ignored (as Xcode suggests).
// A simple test it works will be returning the thumbnail's size to JS.
//
// Instead of @(0), return the actual size of the thumbnail to JS. The size can be obtained
// from .size property of the UIImage (so, thumbnail.size.width or thumbnail.size.height).

// STEP 13
// Width and height are set, now let's take care of the last piece — the uri.
// To be able to provide the developer with some URI we first have to save the image to the filesystem.
// Searching on how to do this, eg. "save image to file system ios" renders eg. this result:
// https://stackoverflow.com/a/14532028/1123156
// This is a good piece of code, but we'll need to modify it a little bit.
// 1. We won't save the image to documents directory, but to caches directory — the developer is responsible
//    for moving the image from the cache to some other place.
//    (Instead of NSDocumentDirectory, we'll use NSCachesDirectory)
// 2. We'll use UUID for filenames so that we can handle a case where a user generates thumbnails in batches.
//    (Instead of @"cached" we'll use [[NSUUID UUID] UUIDString])
// After applying these changes to the copied code, make sure to return the imagePath as the value under @"uri"
// in the resolve call. After rebuilding native code the app should show some non-null URL in the warning.

// STEP 15
// If we'd pass an invalid URI to the method call the app would show an error (which would crash the app
// in production). What if we could handle these errors and reject the Promise so the developer can somehow
// act on it?
//
// There are several places where we could use some assertions.
// 1. Provided URL string may be nil (null).
// 2. Provided URL string may not be convertible to NSURL.
// 3. Generating the thumbnail may fail.
// 4. Saving the image to the file system may fail.
// Cases 1, 2 and 4 are more-or-less safe to handle. We just have to check whether a value is truthy
// and reject-and-return otherwise. (Note that reject block expects three arguments:
// the error code, the error message and an optional NSError *).
// For example a check for 2. would look like:
// if (!sourceUrl) {
//   reject(@"E_PARSE_ERROR", @"Provided URL string could not be parsed as a URL", nil);
//   return;
// }
//
// To know about an error in case 3, we'll have to first pass a pointer to a pointer to NSError
// so it can be filled with a pointer to the error if an error occurs.
//
// If in doubt, always remember you've got spoilers in the README!

// STEP 17
// Let's handle maximumSize now. It will be passed as an NSDictionary under @"maximumSize" key
// in options argument. We should only set the maximum size if the object is present in the dictionary.
// 1. Write an if statement that will only succeed if there's a non-nil value under @"maximumSize" key
//    in the options dictionary.
// 2. Use CGSizeMake function to create a CGSize struct out of values under width and height keys.
//    Note that since there are no primitive values allowed in NSDictionary, you'll need to
//    first fetch the value (which hopefully will be an NSNumber) and then cast it to double (aka CGFloat)
//    using doubleValue method.
// 3. Bonus points for checking whether the value under given key is an NSNumber and otherwise using 0.

// STEP 19
// Last thing missing is the time. It would be passed in the options dictionary, under @"timeMs" key.
// Similarly to width and height, it will be an NSNumber and we'll need to convert it, but this time to CMTime.
// CMTime is a wrapper type that allows iOS to represent a fraction of a second. You can create it with more than one function,
// here I would use CMTimeMake(value, timescale). To represent a number of milliseconds, we'll use
// CMTimeMake(numberOfMs, howManyMsAreInASecond).
//
// Similarly to maximumSize, write an if and then an implementation that will update the time variable, if applicable.

// STEP 21
// It looks like for similar values, generateThumbnailAsync returns exactly the same image.
// (For example there's no noticable difference for timeMs === 4000 and timeMs === 5000, while the image
// in the video changes.)
//
// This is due to the way in which AVAssetImageGenerator optimizes work it has to do. When we request for an image
// the generator has to scan the video file and decode an image (which for some formats may take some time
// due to the way the video file is compressed). To make this processing time smaller,
// the generator by default may use a frame from different video time.
//
// Fortunately, we can configure the tolerance with imageGenerator.requestedTimeTolerance{Before,After}.
// We can set them to kCMTimeZero (as the documentation suggests
// https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1387751-requestedtimetoleranceafter?language=objc
// ), to always generate exactly the frame the user requested us to, but then
// a call with timeMs == 0 will fail to generate a thumbnail (at time 0 there's no frame yet, frames
// start at timeMs == 1/framerate. To handle this case easily (but not fully) we can set the tolerance
// to some reasonably small value, like one tenth of a second. To handle this fully we would probably either:
// - check the video track of the asset and set the tolerance to (1/framerate)
// - ensure that the requested time passed to AVAssetImageGenerator is (1/framerate) at minimum.

// STEP 22
// We can do even better than this! Notice how if you provide a negative value for the timeMs
// or a too big value (30000 for our sample movie) the promise rejects with some cryptic
// "This media cannot be used" error? Let's fix this.
//
// We could either throw an error if the requested time is invalid or try to use the best
// available time for the given parameter. The former is more verbose, but the latter
// is more fail-resistant and allows for some logic herusitics, like eg. using some big timeMS
// to always get the last frame of the video. I would prefer the latter approach.
//
// CoreMedia, which is the media framework on iOS, contains a really nice functions
// that will help us ensure that the time will make sense. In this step, try using CMTimeRangeMake
// and CMTimeClampToRange functions to ensure that the time for which we'll try to generate
// a thumbnail is between 0 and asset.duration.
@end
