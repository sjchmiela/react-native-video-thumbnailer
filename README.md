# Setting up the example app

This branch is going to guide you through a process of setting up an example application using our library. Since we haven't implemented any native methods yet, we'll need to mock our native module.

## Instructions

Instructions are interleaved with code, just open the project in your favorite code editor and `search in all files` for `STEP` string. Then just go through them in order!

> Every step of the instructions corresponds both to a spoiler below and to a commit of `example-finished` branch, if you have any trouble with any of the steps, you can always have a look at [the list of commits of the PR](https://github.com/sjchmiela/react-native-video-thumbnailer/pull/3/commits) and see the solution or expand the spoiler!

## Spoilers

<details>
  <summary>Step 1</summary>

```diff
-/**
- * Sample React Native App
- * https://github.com/facebook/react-native
- *
- * @format
- * @flow
- */
```

</details>

<details>
  <summary>Step 2</summary>

```diff
-import { Platform, StyleSheet, Text, View } from "react-native";
+import { Platform, StyleSheet, Text, View, Image } from "react-native";
```

```js
const generateThumbnailAsync = () =>
  Promise.resolve(
    Image.resolveAssetSource(require("./assets/sample_thumbnail.jpg"))
  );
```

</details>

<details>
  <summary>Step 3</summary>

```js
export default class App extends Component<Props> {
  // ...
  async componentDidMount() {
    const { uri } = await generateThumbnailAsync();
    this.setState({ uri });
  }
```

</details>

<details>
  <summary>Step 4</summary>

```jsx
export default class App extends Component<Props> {
  state = {};

  // ...

  render() {
    return (
      <View style={styles.container}>
        {
          // ...
        }
        <Image
          source={{ uri: this.state.uri }}
          style={{ height: 300, alignSelf: "stretch" }}
        />
      </View>
    );
  }
}
```

</details>
