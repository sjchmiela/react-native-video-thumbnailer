#import "AJVideoThumbnailer.h"

#import <AVKit/AVKit.h>

@implementation AJVideoThumbnailer

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return dispatch_queue_create("edu.appjs.videothumbnailer.AJVideoThumbnailer", DISPATCH_QUEUE_CONCURRENT);
}

RCT_EXPORT_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)
{
  callback(@[@"Hello from the native side!"]);
}

RCT_EXPORT_METHOD(generateThumbnailAsync:(NSString *)urlString options:(NSDictionary *)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  NSURL *sourceURL = [[NSURL alloc] initWithString:urlString];
  AVAsset *asset = [AVAsset assetWithURL:sourceURL];
  AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
  CMTime time = CMTimeMake(1, 1);
  CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
  UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);  // CGImageRef won't be released by ARC

  resolve(@{
            @"uri": [NSNull null],
            @"width": @(0),
            @"height": @(0)
            });
}

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
