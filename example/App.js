import React, { Component } from "react";
import {
  Platform,
  StyleSheet,
  Text,
  View,
  Image,
  NativeModules
} from "react-native";

const generateThumbnailAsync = () =>
  Promise.resolve(
    Image.resolveAssetSource(require("./assets/sample_thumbnail.jpg"))
  );

const instructions = Platform.select({
  ios: "Press Cmd+R to reload,\n" + "Cmd+D or shake for dev menu",
  android:
    "Double tap R on your keyboard to reload,\n" +
    "Shake or press menu button for dev menu"
});

type Props = {};
export default class App extends Component<Props> {
  state = {};

  async componentDidMount() {
    const { uri } = await generateThumbnailAsync();
    this.setState({ uri });

    NativeModules.AJVideoThumbnailer.sampleMethod(
      "Hello from JS side!",
      42,
      console.warn
    );

    const result = await NativeModules.AJVideoThumbnailer.generateThumbnailAsync(
      "uriToBe",
      {}
    );
    console.warn(result);

    // STEP 12
    // The app may warn with width == heigth == 0 or even error now!
    // This is because we didn't provide a valid URL to a movie as the first
    // argument. To grab a URI to some movie, use Image.resolveAssetSource(module).uri.
    // After reloading the JS bundle, the app should show a warning with proper width and height
    // set — 640 and 480.

    // STEP 14
    // Instead of warning the result, let's try updating the state with the new URI!

    // STEP 16
    // Now you should be able tinker around with the first argument to the
    // generateThumbnailAsync method — passing null, "imnotaurl" or
    // Image.resolveAssetSource(require("./assets/sample_thumbnail.jpg")).uri
    // should all not show an error, but rather a warning with a "Unhandled Promise rejection"
    // with a descriptive message. Hooray for clear error messages!

    // STEP 18
    // Change the second argument to the generateThumbnailAsync to an object containing
    // an object under maximumSize key that will specify some width or height constraints!
    // If you set maximum width to 20 you should notice the difference in the image.
    // If you haven't deleted the console.warn(result), you can also inspect the warning
    // to verify whether the size returned is lower in both dimensions than requested.

    // STEP 20
    // Try changing the options dictionary to include a value for `timeMs` key.
    // Does every value change produce a different image?
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to React Native!</Text>
        <Text style={styles.instructions}>To get started, edit App.js</Text>
        <Text style={styles.instructions}>{instructions}</Text>
        <Image
          source={{ uri: this.state.uri }}
          style={{ height: 300, alignSelf: "stretch" }}
        />
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
