import { Ionicons } from "@expo/vector-icons";
import { Tabs } from "expo-router";
import { StyleSheet, Text } from "react-native";

export default function TabLayout() {
  return (
    <Tabs
      initialRouteName="clock"
      screenOptions={{
        headerStyle: {
          backgroundColor: "#0a0a0a",
          elevation: 0,
          shadowOpacity: 0
        },
        tabBarStyle: {
          backgroundColor: "#0a0a0a",
          paddingHorizontal: 15,
          height: 60,
          borderTopWidth: 0
        },
        tabBarActiveTintColor: "red",
        tabBarInactiveTintColor: "#fff",
        tabBarIconStyle: {
          display: "none"
        },
        tabBarLabelStyle: {
          fontSize: 11,
          marginBottom: 23,
          fontFamily: "Lettera Mono",
          textTransform: "uppercase"
        },
        headerTitleAlign: "center",
        headerLeft: () => <Ionicons name="add" size={20} color="#fff" style={{paddingHorizontal: 25}}/>,
        headerRight: () => <Ionicons name="settings-outline" size={20} color="#fff" style={{paddingHorizontal: 25}}/>
      }}
    >
      <Tabs.Screen 
        redirect
        name="index" 
        options={{
          headerTitle: (props: any) => <Text {...props} style={styles.text}>Timer</Text>,
          tabBarShowLabel: false,
          tabBarButton: () => null
        }}
      />
      <Tabs.Screen 
        name="clock"
        options={{
          headerTitle: (props: any) => <Text {...props} style={styles.text}>Clock</Text>,
          tabBarLabel: "Clock"
        }}
      />
      <Tabs.Screen 
        name="alarmsScreen" 
        options={{
          headerTitle: (props: any) => <Text {...props} style={styles.text}>Alarms</Text>,
          tabBarLabel: "Alarms"
        }}
      />
      <Tabs.Screen 
        name="stopWatchScreen" 
        options={{
          headerTitle: (props: any) => <Text {...props} style={styles.text}>Stop Watch</Text>,
          tabBarLabel: "Stop Watch"
        }}
      />
      <Tabs.Screen 
        name="timerScreen" 
        options={{
          headerTitle: (props: any) => <Text {...props} style={styles.text}>Timer</Text>,
          tabBarLabel: "Timer"
        }}
      />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  text: {
    fontFamily: "Lettera Mono",
    color: "#fff",
    textTransform: "uppercase"
  },
  mainContainer: {
    backgroundColor: "#0a0a0a"
  }
});