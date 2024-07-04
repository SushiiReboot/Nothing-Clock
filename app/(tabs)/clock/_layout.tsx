import React from 'react'
import { Stack } from 'expo-router'

const ClockLayout = () => {
  return (
    <Stack>
        <Stack.Screen options={{headerShown: false}} name="index"/>
        <Stack.Screen name="addMoreScreen" options={{headerShown: false}}/>
    </Stack>
  )
}

export default ClockLayout