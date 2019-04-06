# `react-native-video-thumbnailer` — DIY creating React Native library workshop

## What is it?

This repository is a **Do It Yourself** workshop teaching you step-by-step the basics of implementing a React Native library

## How does it work?

The repository has 4 main branches:

* [designing-api](https://github.com/sjchmiela/react-native-video-thumbnailer/tree/designing-api) which is going to guide you through a process of designing the library's API and researching possible implementations. No coding yet!
* [creating-library](https://github.com/sjchmiela/react-native-video-thumbnailer/tree/creating-library) which is going to guide you through a process of creating a React Native library from scratch. We will cover installing [react-native-create-library](https://github.com/frostney/react-native-create-library) tool, using it to create the project and setting the example project up for easier development (following instructions from [this article](https://medium.com/@charpeni/setting-up-an-example-app-for-your-react-native-library-d940c5cf31e4)).
* [example](https://github.com/sjchmiela/react-native-video-thumbnailer/tree/example) which is going to guide you through a process of setting up an example application using our library. Since we haven't implemented any native methods yet, we'll need to mock our native module.
* [ios-implementation](https://github.com/sjchmiela/react-native-video-thumbnailer/tree/ios-implementation) which is going to guide you through the process of adding an iOS implementation to a React Native library.
* more branches will be added soon (Android implementation, JS library, TypeScript conversion, maybe some tests).

Each branch is a starting point in a working state and the codebase is sprinkled with comments `STEP <number>`. Just "search in all" for `STEP 1` on branch `designing-api` to start the workshop, then for `STEP 2`, when you're finished with `designing-api` checkout to `creating-library` search for `STEP 1` and so on.

Branches where it's applicable have a corresponding `${branch}-finished` equivalent.

## Who has created it?

<table style="text-align: center">
  <thead>
    <tr>
      <th width="45%" style="text-align: center">Stanisław Chmiela</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align: center">
        <a href="https://twitter.com/sjchmiela/">
          <img src="https://avatars0.githubusercontent.com/u/1151041" width="250" alt="Stanisław Chmiela" />
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://swmansion.com/">
          <img src="https://sjchmiela.github.io/pokedex/swmansion.png" alt="Software Mansion" width="250" />
        </a>
      </td>
    </tr>
  </tbody>
</table>
