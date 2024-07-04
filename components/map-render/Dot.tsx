import React from 'react';
import { StyleSheet, View } from 'react-native';

interface DotProps {
    isActive: boolean,
    isVisible: boolean
}

const Dot: React.FC<DotProps> = (props) => {
    return (
        <View style={[styles.dot, {backgroundColor: props.isActive ? "red" : "grey"}, {opacity: props.isVisible ? 1 : 0}]}/>
    );
};

const styles = StyleSheet.create({
    dot: {
        width: "1.923%",
        aspectRatio: 1,
        backgroundColor: "red",
        borderRadius: 50
    }
});

export default Dot;