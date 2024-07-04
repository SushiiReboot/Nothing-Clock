import React from 'react';
import DottedMap from 'dotted-map/without-countries';
import ComputedDottedMap from "./data/map_dotted.json"
import GeoData from "./data/countries.json"
import CountryCoords from "./data/countries.geo.json"
import { StyleSheet, View, Animated, StyleProp, ViewStyle } from 'react-native';
import { SvgXml } from 'react-native-svg';

interface MapRendererProps {
    style: StyleProp<ViewStyle>
    pins: string[]
}

function findCoordinates(pin: string | null): number[] | null {
    const jsonGeo = JSON.stringify(GeoData);
    const geoData = JSON.parse(jsonGeo);

    console.log(geoData.ref_country_codes);

    if(pin == null) {
        return null;
    }

    const countryData = parseJsonGeoData(pin, geoData);

    if(countryData == null) {
        const countryByCity = findCountryByCityName(pin);
        return parseJsonGeoData(countryByCity, geoData);
    }

    return countryData;
}

function parseJsonGeoData(country: string | null, geoJson: any): number[] | null {
    if (!geoJson || !CountryCoords.ref_country_codes) {
        console.error("GeoJson is undefined");
        return null; // Ensure geoJson and ref_country_codes are defined
    }

    for (const data of CountryCoords.ref_country_codes) {
        if (data.country === country) {
            let coords: number[] = [];
            coords[0] = data.latitude;
            coords[1] = data.longitude;
            return coords;
        }
    }

    return null;
}

function findCountryByCityName(cityName: string): string | null {
    const geoData = GeoData as { [key: string]: string[] };
    for (const country in geoData) {
        if (geoData.hasOwnProperty(country) && geoData[country].includes(cityName))
            return country;
    }

    return null;
}

const MapRenderer: React.FC<MapRendererProps> = (props) => { //52X29 map
    if (!ComputedDottedMap) {
        // Handle the case where ComputedDottedMap is undefined
        console.error("ComputedDottedMap is undefined");
        return null; // Or some other error handling
    }

    const computedData = JSON.stringify(ComputedDottedMap);
    const map = new DottedMap({ map: JSON.parse(computedData) });

    for (const pin of props.pins) {
        const coords = findCoordinates(pin);
        if (coords != null) {
            map.addPin({
                lat: coords[0],
                lng: coords[1],
                svgOptions: { color: 'red', radius: 0.4 },
            });
        }
    }

    const svgMap = map.getSVG({
        radius: 0.4,
        color: '#423B38',
        shape: 'circle',
        backgroundColor: '#0a0a0a',
    });

    return (
        <Animated.View style={[styles.mainContainer, props.style]}>
            <SvgXml xml={svgMap} />
        </Animated.View>
    );
};

const styles = StyleSheet.create({  
    mainContainer: {
        marginHorizontal: 10,
        flex: 1,
        flexWrap: "wrap",
        flexDirection: "row",
        display: "flex",
        justifyContent: 'center', 
        alignItems: 'center'
    }
});

export default MapRenderer;