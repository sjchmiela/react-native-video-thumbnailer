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
  if (!urlString) {
    reject(@"E_EMPTY_ARG", @"You have to provide URL string from which to create a thumbnail.", nil);
    return;
  }

  NSURL *sourceURL = [[NSURL alloc] initWithString:urlString];
  if (!sourceURL) {
    reject(@"E_PARSE_ERROR", @"Provided URL string could not be parsed as a URL.", nil);
    return;
  }

  AVAsset *asset = [AVAsset assetWithURL:sourceURL];
  AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
  if (options && [options[@"maximumSize"] isKindOfClass:[NSDictionary class]]) {
    NSNumber *width = [options[@"maximumSize"][@"width"] isKindOfClass:[NSNumber class]] ? options[@"maximumSize"][@"width"] : @(0);
    NSNumber *height = [options[@"maximumSize"][@"height"] isKindOfClass:[NSNumber class]] ? options[@"maximumSize"][@"height"] : @(0);

    CGSize maximumSize = CGSizeMake([width doubleValue], [height doubleValue]);
    imageGenerator.maximumSize = maximumSize;
  }
  CMTime time = CMTimeMake(1, 1);
  NSError *error;
  CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
  if (error) {
    reject(@"E_THUM_FAIL", error.localizedFailureReason, error);
    return;
  }
  UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);  // CGImageRef won't be released by ARC

  NSData *imageData = UIImagePNGRepresentation(thumbnail);

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];

  NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]]];

  if (![imageData writeToFile:imagePath atomically:NO]) {
    reject(@"E_FS_WRITE", @"Could not save the thumbnail to the file system", nil);
    return;
  }

  resolve(@{
            @"uri": imagePath,
            @"width": @(thumbnail.size.width),
            @"height": @(thumbnail.size.height)
            });
}

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
