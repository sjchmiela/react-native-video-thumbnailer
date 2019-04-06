# Creating the library

This branch is going to guide you through a process of creating a React Native library from scratch. We will cover installing [`react-native-create-library`](https://github.com/frostney/react-native-create-library) tool, using it to create the project and setting the example project up for easier development (following instructions from [this article](https://medium.com/@charpeni/setting-up-an-example-app-for-your-react-native-library-d940c5cf31e4)).

> Every step of the instructions corresponds to a commit of `creating-library-finished` branch, if you have any trouble with any of the steps, you can always have a look at [the list of commits of the PR](https://github.com/sjchmiela/react-native-video-thumbnailer/pull/1/commits) and see the solution!

## Instructions

1. Install [`react-native-create-library`](https://github.com/frostney/react-native-create-library) tool. At the time of writing this guide (April 2019) the latest commit is [`e08c03c`](https://github.com/frostney/react-native-create-library/tree/e08c03cadf417a9fcf6a1daba0193ea58959469e) and some of the recently added improvements haven't been published to NPM yet, so we'll install this tool straight from Github.
    ```sh
    # Install NPM package from Github repository
    # frostney/react-native-create-library
    # from commit e08c03c globally.

    $ npm i -g "frostney/react-native-create-library#e08c03c"
    ```
2. Let's use this tool to create the library. First, review [available options](https://github.com/frostney/react-native-create-library/tree/e08c03cadf417a9fcf6a1daba0193ea58959469e#command-line-usage). Let's construct the command and then execute it **one directory higher in the hierarchy than this project's directory**.
    ```sh
    # 1. prefix and the package-identifier are a shameless plug,
    #    this workshop was first conducted
    #    during 2019 App.js conference, https://appjs.co
    # 2. Default value for platforms is ios,android,windows
    #    and this workshop unfortunately won't cover adding
    #    Windows implementation too
    # 3. You can use whatever author configuration you like ;)
    # 4. We want the library to generate the example project.
    # 5. VideoThumbnail will turn into video-thumbnail package name
    #    and will turn into 
    react-native-create-library \
      --prefix AJ \
      --package-identifier "edu.appjs.videothumbnailer" \
      --platforms "ios,android" \
      --github-account "dummy" \
      --author-name "Curious Learner" \
      --author-email "myemail@example.com" \
      --generate-example \
      VideoThumbnailer
    ```
3. Follow the instructions at [“Setting up an example app for your React Native library”](https://medium.com/@charpeni/setting-up-an-example-app-for-your-react-native-library-d940c5cf31e4), which will guide you through the process of setting up the example application the proper way. Some of the improvements we'll achieve:
	- Metro bundler will pick up JS code from the git-committed library, not the `example/node_modules` copy,
	- editing code inside Xcode and Android Studio projects will edit the code at the root of the library, not the `example/node_modules` git-ignored copy.

	Step by step:
	1. edit `metro.config.js` according to [the article](https://medium.com/@charpeni/setting-up-an-example-app-for-your-react-native-library-d940c5cf31e4),
	2. open `example/android/settings.gradle` with your text editor and replace `node_modules/react-native-video-thumbnailer` with `..` (these exact strings!)
	3. open `example/ios/example.xcodeproj/project.pbxproj` with your text editor and replace all `node_modules/react-native-video-thumbnailer` with `..` (these exact strings!)

		By replacing `node_modules/react-native-video-thumbnailer` with `..` we change the pointer from `node_modules`' copy to the root library code (which isn't git-ignored as opposed to any `node_modules` directory in this project).
4. Install dependencies in both projects (root and `example`), I used `yarn`.
5. Confirm that everything works all right by:
		- opening `example/ios/example.xcodeproj` project in Xcode and building the application,
		- opening `example/android` in Android Studio and building the application.

	Xcode reordered some entries in the `xcodeproj` file at least in my case (probably it identifies entries by some checksum, so after changing the path in step 3 it now updated the key).
