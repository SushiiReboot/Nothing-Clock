import { NavigationContainer } from "@react-navigation/native";
import { useFonts } from "expo-font";
import { Stack } from "expo-router";
import * as SystemUI from 'expo-system-ui';
import {ThemeProvider, Theme } from "@react-navigation/native";
const DarkTheme: Theme = {
  dark: true,
  colors: {
    primary: 'rgb(10, 132, 255)',
    background: '#0a0a0a',
    card: 'rgb(18, 18, 18)',
    text: '#fff',
    border: 'rgb(39, 39, 41)',
    notification: 'rgb(255, 69, 58)',
  },
};

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
    <ThemeProvider value={DarkTheme}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{headerShown: false}}/>
      </Stack>
    </ThemeProvider>
  );
}

SystemUI.setBackgroundColorAsync("#0a0a0a");