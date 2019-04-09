import React, { Component } from "react";
import { Platform, StyleSheet, Text, View } from "react-native";

// STEP 2
// Create a mock generateThumbnailAsync function that will return a Promise
// resolving to { uri, width, height } of `./assets/sample_thumbnail.jpg`.
// To get such an object, use Image.resolveAssetSource method.
// https://facebook.github.io/react-native/docs/image#resolveassetsource

const instructions = Platform.select({
  ios: "Press Cmd+R to reload,\n" + "Cmd+D or shake for dev menu",
  android:
    "Double tap R on your keyboard to reload,\n" +
    "Shake or press menu button for dev menu"
});

type Props = {};
export default class App extends Component<Props> {
  // STEP 3
  // Create a function that will get called every time the app restarts
  // (I like to use componentDidMount lifecycle method for this)
  // which will call the generateThumbnailAsync method, await for its result
  // and then save the result.uri to state.

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to React Native!</Text>
        <Text style={styles.instructions}>To get started, edit App.js</Text>
        <Text style={styles.instructions}>{instructions}</Text>
        {
          // STEP 4
          // Use this component's state to show an image from the URI saved in state
          // in step 3.
          //
          // Remember that Image component without styles will collapse by default
          // so you'll need to add some at least static width and height, better yet some static height
          // and `alignSelf: 'stretch'`.
          //
          // You may also need to deal with `null is not an object (evaluating this.state…)`. It will happen
          // because the default initial value for state is null. To set an initial value for state
          // either add a constructor (https://reactjs.org/docs/state-and-lifecycle.html#adding-local-state-to-a-class)
          // or add `state = {}` in class scope (Babel configuration includes transform-class-properties plugin,
          // https://babeljs.io/docs/en/next/babel-plugin-proposal-class-properties).
        }
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF"
  },
  welcome: {
    fontSize: 20,
    textAlign: "center",
    margin: 10
  },
  instructions: {
    textAlign: "center",
    color: "#333333",
    marginBottom: 5
  }
});
