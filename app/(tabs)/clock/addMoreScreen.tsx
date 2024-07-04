import { View, Text, StyleSheet } from 'react-native'
import React from 'react'

const AddMoreScreen = () => {
  return (
    <View style={styles.mainContainer}>
      <Text style={styles.text}>Add More Screen</Text>
    </View>
  )
}

const styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center"
  },
  text: {
    fontFamily: "N Dot",
    color: "#fff"
  }
})

export default AddMoreScreen;