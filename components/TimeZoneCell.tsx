import { Entypo } from '@expo/vector-icons';
import React from 'react';
import { StyleSheet, View, Text, Pressable } from 'react-native'; 

interface TimeZoneCellProps {
    timeZone: string;
    name: string;
}

const TimeZoneCell: React.FC<TimeZoneCellProps> = ({ name, timeZone = "null" }) => {
    return (
        <Pressable 
            style={styles.mainContainer}
            onPress={() => alert("Pressed timezone!")}
        >
            <View style={styles.header}>
                <Entypo name="dot-single" size={30} color="red" />
                <Text style={[styles.text, styles.headerText]}>{name}</Text>
            </View>
            <Text style={[styles.text, styles.clockText]}>{timeZone}</Text>
        </Pressable>
    );
};

const styles = StyleSheet.create({
    mainContainer: {
        justifyContent: "space-between",
        flex: 1,
        aspectRatio: 1,
        borderRadius: 10,
        backgroundColor: "#1d1e20",
        margin: 10,
        padding: 20
    },
    header: {   
        flexDirection: "row",
        alignItems: "center"
    },
    headerText: {
        fontFamily: "Lettera Mono",
        textTransform: "uppercase",
        flexWrap: "wrap",
    },
    clockText: {
        fontFamily: "N Dot",
        fontSize: 30,
        letterSpacing: 2.5
    },
    text: {
        color: "#fff",
        marginRight: 30
    }
});

export default TimeZoneCell;