# Implementing thumbnail generation on iOS

This branch is going to guide you through the process of adding an iOS implementation to a React Native library.

## Instructions

Instructions are interleaved with code, just open the project in your favorite code editor and `search in all files` for `STEP` string. Then just go through them in order!

> Every step of the instructions corresponds both to a spoiler below and to a commit of `ios-implementation-finished` branch, if you have any trouble with any of the steps, you can always have a look at [the list of commits of the PR](https://github.com/sjchmiela/react-native-video-thumbnailer/pull/4/commits) and see the solution or expand the spoiler!

## Spoilers

<details>
  <summary>Step 2</summary>

```diff
-return dispatch_get_main_queue();
+return dispatch_queue_create("edu.appjs.videothumbnailer.AJVideoThumbnailer", DISPATCH_QUEUE_CONCURRENT);
```

</details>

<details>
  <summary>Step 4</summary>

```objc 
callback(@[@"Hello from the native side!"]);
```

</details>

<details>
  <summary>Step 5</summary>

```diff
-import { Platform, StyleSheet, Text, View, Image } from "react-native";
+import { Platform, StyleSheet, Text, View, Image, NativeModules } from "react-native";
```

</details>

<details>
  <summary>Step 6</summary>

```js
NativeModules.AJVideoThumbnailer.sampleMethod("Hello from JS side", 42, console.warn);
```

</details>

<details>
  <summary>Step 7</summary>

```objc
RCT_EXPORT_METHOD(generateThumbnailAsync:(NSString *)urlString options:(NSDictionary *)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{

}
```

</details>
<details>
  <summary>Step 8</summary>

```objc
RCT_EXPORT_METHOD(generateThumbnailAsync:(NSString *)urlString options:(NSDictionary *)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  resolve(@{
          @"uri": [NSNull null],
          @"width": @(0),
          @"height": @(0)
          });
}
```

</details>
<details>
  <summary>Step 9</summary>

```js
const result = await NativeModules.AJVideoThumbnailer.generateThumbnailAsync(
  "uriToBe",
  {}
);
console.warn(result);
```

</details>
<details>
  <summary>Step 10</summary>

```objc
NSURL *sourceURL = [[NSURL alloc] initWithString:urlString];
AVAsset *asset = [AVAsset assetWithURL:sourceURL];
AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
CMTime time = CMTimeMake(1, 1);
CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
```

at the top of the file

```objc
#import <AVKit/AVKit.h> 
```

</details>

<details>
  <summary>Step 11</summary>

```diff
 resolve(@{
         @"uri": [NSNull null],
-        @"width": @(0),
-        @"height": @(0)
+        @"width": @(thumbnail.size.width),
+        @"height": @(thumbnail.size.height)
         });
```

</details>

<details>
  <summary>Step 12</summary>

```diff
 const result = await NativeModules.AJVideoThumbnailer.generateThumbnailAsync(
-  "uriToBe",
+  Image.resolveAssetSource(require("./assets/sample.mov")).uri,
   {}
 );
 console.warn(result);
```
</details>


<details>
  <summary>Step 13</summary>

```objc
//                                           💅
NSData *imageData = UIImagePNGRepresentation(thumbnail);

//                                                   💅
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];

//                                                                                                            💅
NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]]];

NSLog(@"pre writing to file");
if (![imageData writeToFile:imagePath atomically:NO])
{
  NSLog(@"Failed to cache image data to disk");
}
else
{
  NSLog(@"the cachedImagedPath is %@",imagePath);
}

resolve(@{
//                💅
          @"uri": imagePath,
          @"width": @(thumbnail.size.width),
          @"height": @(thumbnail.size.height)
          });
```
</details>

<details>
  <summary>Step 14</summary>

```js
const result = await NativeModules.AJVideoThumbnailer.generateThumbnailAsync(
  Image.resolveAssetSource(require("./assets/sample.mov")).uri,
  {}
);
this.setState({ uri: result.uri });
```
</details>

<details>
  <summary>Step 15</summary>

```objc
RCT_EXPORT_METHOD(generateThumbnailAsync:(NSString *)urlString options:(NSDictionary *)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  if (!urlString) {
    reject(@"E_EMPTY_ARG", @"You have to provide URL string from which to create a thumbnail.", nil);
    return;
  }
  // ...
```

```objc
  // ...
  NSURL *sourceURL = [[NSURL alloc] initWithString:urlString];
  if (!sourceURL) {
    reject(@"E_PARSE_ERROR", @"Provided URL string could not be parsed as a URL.", nil);
    return;
  }
  // ...
```

```objc
  NSError *error;
  CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
  if (error) {
    reject(@"E_THUM_FAIL", error.localizedFailureReason, error);
    return;
  }
```

```objc
  NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]]];

  if (![imageData writeToFile:imagePath atomically:NO]) {
    reject(@"E_FS_WRITE", @"Could not save the thumbnail to the file system", nil);
    return;
  }
```
</details>

<details>
  <summary>Step 17</summary>

```objc
if (options && [options[@"maximumSize"] isKindOfClass:[NSDictionary class]]) {
  NSNumber *width = [options[@"maximumSize"][@"width"] isKindOfClass:[NSNumber class]] ? options[@"maximumSize"][@"width"] : @(0);
  NSNumber *height = [options[@"maximumSize"][@"height"] isKindOfClass:[NSNumber class]] ? options[@"maximumSize"][@"height"] : @(0);

  CGSize maximumSize = CGSizeMake([width doubleValue], [height doubleValue]);
  imageGenerator.maximumSize = maximumSize;
}
```
</details>
<details>
  <summary>Step 18</summary>

```js
const result = await NativeModules.AJVideoThumbnailer.generateThumbnailAsync(
  Image.resolveAssetSource(require("./assets/sample.mov")).uri,
  { maximumSize: { width: 20 } }
);
```
</details>
<details>
  <summary>Step 19</summary>

```objc
if (options && [options[@"time"] isKindOfClass:[NSNumber class]]) {
  time = CMTimeMake([options[@"time"] doubleValue], 1000);
}
```
</details>
<details>
  <summary>Step 20</summary>

```js
const result = await NativeModules.AJVideoThumbnailer.generateThumbnailAsync(
  Image.resolveAssetSource(require("./assets/sample.mov")).uri,
  { timeMs: 18000 }
);
```
</details>
<details>
  <summary>Step 21</summary>

```objc
imageGenerator.requestedTimeToleranceAfter = CMTimeMake(1, 10);
imageGenerator.requestedTimeToleranceBefore = CMTimeMake(1, 10);
```
</details>
<details>
  <summary>Step 22</summary>

```diff
   CMTime time = CMTimeMake(0, 1);
   if (options && [options[@"timeMs"] isKindOfClass:[NSNumber class]]) {
     time = CMTimeMake([options[@"timeMs"] doubleValue], 1000);
+    time = CMTimeClampToRange(time, CMTimeRangeMake(kCMTimeZero, asset.duration));
   }
```
</details>
