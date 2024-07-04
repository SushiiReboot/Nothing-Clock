import TimeZoneCell from "@/components/TimeZoneCell";
import MapRenderer from "@/components/map-render/MapRenderer";
import { transform } from "@babel/core";
import { Ionicons } from "@expo/vector-icons";
import { StatusBar } from "expo-status-bar";
import { useEffect, useRef } from "react";
import { FlatList, Pressable, StyleSheet, Text, View, ScrollView, Animated, Easing } from "react-native";

const data_test = [
  {
    "name": "Los Angeles",
    "timeZone": "03:45"
  },
  {
    "name": "Tokyo",
    "timeZone": "16:20"
  },
  {
    "name": "Paris",
    "timeZone": "09:15"
  },
  {
    "name": "London",
    "timeZone": "13:50"
  },
  {
    "name": "Sydney",
    "timeZone": "22:30"
  },
  {
    "name": "Berlin",
    "timeZone": "11:05"
  },
  {
    "name": "Rio de Janeiro",
    "timeZone": "08:40"
  },
  {
    "name": "Moscow",
    "timeZone": "19:55"
  },
  {
    "name": "Ravenna",
    "timeZone": "14:07"
  }
]

const date = new Date();
const month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const day = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const year = date.getFullYear().toString().slice(-2);
const currentDateString = `${day[date.getDay()]}, ${month[date.getMonth()]} ${year}`

function extractPinsFromDataSet() : string[] {
  let pins : string[] = [];
  for (const data of data_test) {
    pins.push(data.name);
  }
  return pins;
}


export default function ClockScreen() {
  const scrollY = useRef(new Animated.Value(0)).current;
  const thresholdScroll = 10;
  const targetPositionMapDisabled = 290;
  const targetPositionMapEnabled = 0;
  const scrollViewRef = useRef<ScrollView>(null);
  let initialDragPosition = useRef<number>(0);

  const scale = scrollY.interpolate({
    inputRange: [0, 300],
    outputRange: [1, 0],
    extrapolate: 'clamp',
  });

  // Function to animate scroll to a specific position
  const animateScrollTo = (toValue: number) => {
    if (scrollViewRef.current) {
      scrollViewRef.current.scrollTo({
        y: toValue,
        animated: true,
      });
    }
  };

  // Function to handle scroll events
  const handleScroll = Animated.event(
    [{ nativeEvent: { contentOffset: { y: scrollY } } }],
    { useNativeDriver: false }
  );

  // Trigger scroll animation based on conditions
  const onScrollEndDrag = (event: { nativeEvent: { contentOffset: { y: any; }; }; }) => {
    const offsetY = event.nativeEvent.contentOffset.y;
    console.log(offsetY);
    if (offsetY >= thresholdScroll && offsetY < targetPositionMapDisabled) {
      if(initialDragPosition > offsetY) { //The user is trying to scroll up back to the map
        animateScrollTo(targetPositionMapEnabled);
        return;
      }
      
      animateScrollTo(targetPositionMapDisabled);
    }
  };

  const setInitalDragPosition = (event: { nativeEvent: { contentOffset: { y: any; }; }; }) => {
    initialDragPosition = event.nativeEvent.contentOffset.y;
  }

  return (
    <View style={styles.mainContainer}>
      <View style={styles.addMoreBtnContainer}>
        <Pressable 
          style={styles.addMoreBtn}
          onPress={() => {alert("Add More pressed!")}}
        >
          <Text style={[styles.letteraMonoTxt, styles.addMoreBtnText]}>Add More</Text>
        </Pressable>
      </View>
      <Animated.ScrollView
        ref={scrollViewRef}
        style={styles.mainContainer}
        contentContainerStyle={{
          marginTop: 10,
          paddingBottom: 100,
        }}
        onScroll={handleScroll}
        onScrollEndDrag={onScrollEndDrag} // Add onScrollEndDrag event
        onScrollBeginDrag={setInitalDragPosition}
        scrollEventThrottle={16}
      >
        <View style={styles.mapContainer}>
          <MapRenderer style={{ transform: [{ scale: scale }] }} pins={extractPinsFromDataSet()} />
        </View>
        <View style={styles.belowMapContainer}>
          <Pressable style={[styles.clockDataPressable, { backgroundColor: "#1d1e20" }]}>
            <Text style={[styles.letteraMonoTxt, styles.clockDataPressableTxt, { color: "#fff" }]}>{currentDateString}</Text>
          </Pressable>
          <Pressable style={[styles.clockDataPressable, { backgroundColor: "#fff", flexDirection: "row", gap: 15 }]}>
            <Text style={[styles.letteraMonoTxt, styles.clockDataPressableTxt]}>1 Alarm</Text>
            <Ionicons name="chevron-forward-outline" size={15} color="black" />
          </Pressable>
        </View>
        <View style={styles.timeZoneContainer}>
          <FlatList
            data={data_test}
            renderItem={({ item }) => <TimeZoneCell name={item.name} timeZone={item.timeZone} />}
            numColumns={2}
            scrollEnabled={false}
          />
        </View>
      </Animated.ScrollView>
      <StatusBar backgroundColor="#0a0a0a" translucent={true}/>
    </View>
  );
}

const styles = StyleSheet.create({
  mainContainer: {
    backgroundColor: "#0a0a0a",
    flex: 1,
    paddingHorizontal: 10,
  },
  mapContainer: {
    width: "100%",
    height: 300,
    flex: 0.5,
    paddingVertical: 10
  },
  belowMapContainer: {
    flexDirection: "row",
    justifyContent: "center",
    gap: 20,
    marginBottom: 10
  },
  clockDataPressable: {
    borderRadius: 50,
    flex: 1,
    aspectRatio: 2,
    justifyContent: "center",
    alignItems: "center"
  },
  clockDataPressableTxt: {
    textTransform: "uppercase",
  },
  mpData: {
    flex: 1
  },
  tmZoneRow: {
    flex: 1,
    flexDirection: "row"
  },
  timeZoneContainer: {
    width: "100%",
    flex: 0.5,
    paddingVertical: 10
  },
  addMoreBtnContainer: {
    width: "100%",
    position: "absolute",
    bottom: 20,
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    zIndex: 1
  },
  addMoreBtn: {
    backgroundColor: "red",
    paddingHorizontal: 30,
    paddingVertical: 20,
    borderRadius: 50,
  },
  addMoreBtnText: {
    color: "#fff",
    textTransform: "uppercase"
  },
  letteraMonoTxt: {
    fontFamily: "Lettera Mono",
  }
});