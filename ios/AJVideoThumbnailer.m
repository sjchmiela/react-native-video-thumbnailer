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
  imageGenerator.requestedTimeToleranceAfter = CMTimeMake(1, 10);
  imageGenerator.requestedTimeToleranceBefore = CMTimeMake(1, 10);
  if (options && [options[@"maximumSize"] isKindOfClass:[NSDictionary class]]) {
    NSNumber *width = [options[@"maximumSize"][@"width"] isKindOfClass:[NSNumber class]] ? options[@"maximumSize"][@"width"] : @(0);
    NSNumber *height = [options[@"maximumSize"][@"height"] isKindOfClass:[NSNumber class]] ? options[@"maximumSize"][@"height"] : @(0);

    CGSize maximumSize = CGSizeMake([width doubleValue], [height doubleValue]);
    imageGenerator.maximumSize = maximumSize;
  }

  CMTime time = CMTimeMake(1, 1);
  if (options && [options[@"time"] isKindOfClass:[NSNumber class]]) {
    time = CMTimeMake([options[@"time"] doubleValue], 1000);
  }

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
