import { Ionicons } from "@expo/vector-icons";
import { useFonts } from "expo-font";
import { Stack, Tabs } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { StyleSheet, Text } from "react-native";

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    'Lettera Mono': require("../assets/fonts/Lettera Mono LL.ttf"),
    'N Type': require("../assets/fonts/NType82Mono-Regular.otf"),
    'N Dot': require("../assets/fonts/Ndot-55.otf"),
  });

  if(!fontsLoaded) {
    return null;
  }

  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{headerShown: false}}/>
    </Stack>
  );
}