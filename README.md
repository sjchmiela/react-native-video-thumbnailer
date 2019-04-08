# Designing the API

This branch is going to guide you through a process of designing the library's API and researching possible implementations. No coding yet!

## Instructions

1. We would like our users to be able to generate a thumbnail from a video file.

    I, personally, would also not add the ability to create a thumbnail from a remote URL video — to create a thumbnail system has to download the file either way and this too can be handled better by third party libraries.
2. Let's search the Internet for some examples and instructions on how to create a thumbnail from a video resource. A simple `how to create a thumbnail from a video [platform]` search should return results like:
    - [Create thumbnail from a video URL in iPhone SDK](https://stackoverflow.com/a/11804061/1123156),
    - [Create Thumbnail From Video in Android App](http://androidsrc.net/create-thumbnail-video-android-application/) and
    - [How to create a video thumbnail from a video file path in Android?](https://stackoverflow.com/a/32517167/1123156)
    - [`android.media.ThumbnailUtils`](https://developer.android.com/reference/android/media/ThumbnailUtils.html)
    - [`AVAssetImageGenerator`](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator?language=objc)
3. Looking at the possibilities we see that we should be able to:
    - generate a thumbnail for a video URL on both platforms
    - generate a thumbnail from a specified time on both platforms
    - scale the image natively using [`maximumSize`](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1387560-maximumsize?language=objc) property on iOS and [`android.media.ThumbnailUtils`](https://developer.android.com/reference/android/media/ThumbnailUtils.html) on Android
4. Let's list all the arguments that would allow us to define such a function and then think which should be made required and which should be optional:
    - `videoUrl` — path to the video file (required)
    - `time` — time at which the thumbnail should be fetched (optional, the default could be `0`)
    - `maximumSize` — upscaling the thumbnail doesn't make much sense in this case so let's settle on `maximumSize` instead of `size` (optional, the default could be the video resolution).

    Since only `videoUrl` is required and both `time` and `maximumSize` options are optional, let's design a native function:

    ```ts
    type ThumbnailGenerationOptions = {
       // time in ms
      timeMs?: number;
      // maximum expected size for the thumbnail
      maximumSize?: {
        width?: number;
        height?: number;
      };
    };

    type ThumbnailResult = {
      // URI to the thumbnail
      uri: string;

      // Thumbnail size
      width: number;
      height: number;
    };

    generateThumbnailAsync(
      videoUrl: string,
      options?: ThumbnailGenerationOptions
    ): Promise<ThumbnailResult>
    ```

    > We could resolve with only the `uri`, but since having the image in memory when executing this function providing the `width` and `height` may be helpful for when someone needs the size.
5. This module interface should work on both client–library interface and library–native — fortunately!
    > In other circumstances we could eg. expose only one function from native and expose several helper methods from the JS library. One such example would be React Native's `AsyncStorage`, on which you could call both `set` and `multiSet` and both of those methods would in fact call to one native method `multiSet`.
