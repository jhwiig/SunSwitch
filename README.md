# SunSwitch

SunSwitch is an application that changes the system appearance (light or dark) of macOS. At sunrise, the appearance is set to light. At sunset, the appearance is set to dark.

## How it Works
CoreBrightness is part of macOS that uses your location to determine when sunrise and sunset is for Night Shift. By using CoreBrightness, SunSwitch does not directly need to ask your location to know when the next sunrise and sunset in your location will be.

You can test that CoreBrightness is working on your Mac by running the following command in a terminal window:

`corebrightnessdiag sunschedule`

If it works correctly, it should output something like this:

    Night Shift Sunset/Sunrise
	{
	isDaylight = 0;
	nextSunrise = "2019-05-30 10:22:37 +0000";
	nextSunset = "2019-05-30 01:11:09 +0000";
	previousSunrise = "2019-05-28 10:23:44 +0000";
	previousSunset = "2019-05-28 01:09:30 +0000";
	sunrise = "2019-05-29 10:23:10 +0000";
	sunset = "2019-05-29 01:10:20 +0000";
	}

## Setting it Up
1. git clone `https://github.com/jhwiig/SunSwitch.git`
2. Move `SunSwitch.app` to your Applications folder.
3. Double click to launch SunSwitch.
<img src="https://github.com/jhwiig/SunSwitch/raw/master/resources/loginitems.png" width="75%" height="75%">

4. Add `SunSwitch.app` to the list of startup programs.
	1. Open `System Preferences` -> `Users & Groups`
	2. Select your user and navigate to `Login Items`.
	3. Add `SunSwitch.app` as a login item.


At this point, SunSwitch will run in the background. It has no significant effect on the battery life of your computer. 

## Turning it Off

Decide you don't like SunSwitch, but don't know how to get rid of it?     	 

<img src="https://github.com/jhwiig/SunSwitch/raw/master/resources/activitymonitor.png" width="75%" height="75%">

1. First, remove the current running version.
	 1. Open Activity Monitor
	 2. Search for `SunSwitch`
	 3. Select Quit Process.

2. To keep it from running on startup, remove it from the `Login Items` list.
	1. Open `System Preferences` → `Users & Groups`
	2. Select your user and navigate to `Login Items`.
	3. Remove `SunSwitch.app` as a login item.
