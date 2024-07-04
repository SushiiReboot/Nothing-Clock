import { useFonts } from "expo-font";
import { Stack } from "expo-router";

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