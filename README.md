# GModCrossfades
[For Mappers] Easily switch between songs with linear crossfades

## Video demo
Click to watch:

[![Click here to watch](https://img.youtube.com/vi/2memnhMLox0/0.jpg)](https://www.youtube.com/watch?v=2memnhMLox0)

The sounds in this video are from Human: Fall Flat OST. Laboratory Theme, Lumber Theme & Forest Theme. You can download the pack of songs [here](https://drive.google.com/file/d/1TeFknD5lEM4rZQEFfdKAB3WMaDwJNHUr/view).

## Config

Here's how default `lua/autorun/config.lua` looks like:

```lua
Crossfades = Crossfades or {}

Crossfades.debug = false
Crossfades.config = {
	example = {
		track1 = {
			{'sound/mytracks/track1.ogg', 252.262},
		},
		track2 = {
			{'sound/mytracks/track2.ogg', 252.258},
		},
		track3 = {
			{'sound/mytracks/track3.ogg', 252.260},
		},
	},
}
```

The first line is what you shouldn't touch.

### Crossfades.debug
Change `false` to `true`, and you will:
* see all active crossfades in the top left corner;
* be able to emulate Lua function calls in the text chat (like in video demonstration)

### Crossfades.config
In this table, you should specify all available crossfades. You'll get an error if you try to create a crossfade not defined in this table. In the example above, there's only one crossfade called "example".
* The name should be placed before the equality sign;
* The name should only contain English letters (small and/or capital), numbers, and underscores;
* The name shouldn't start with a number;
* The name should be unique.

After the crossfade name, place an equality sign and open curly braces. Here you need to specify all tracks in this crossfade.

Each track is a table with the same conventions (name, equality sign & braces) as the crossfade table. The track name should be unique across all the tracks of its crossfade. Inside a track, you may specify one or more sounds, which are played inside a track. Let's look at, for example, `{'sound/mytracks/track1.ogg', 252.262},`.

As you can see, the sound is wrapped inside curly braces, starts with a path to sound (single- or double-quoted), followed by a comma and a decimal number, meaning the length of this sound in seconds (as precise as possible, up to milliseconds). When that number of seconds passes, the sounds immediately stop (if still playing), and the next sound in the track starts. If that was the last sound, the first one doesn't start again.

* All sound tables are divided by a comma;
* All track tables are divided by a comma;
* All crossfade tables are divided by a comma. You may place a trailing comma if you want to.

## Usage

In Hammer, create a `lua_run` entity. Add a `Code` property to it, and specify a value depending on what you want to do:

### Start a crossfade
Code: `Crossfades.Start(crossfadeName, trackName, fadein)`
* `crossfadeName`: **(required)** the name of the crossfade, defined in the config. Should be single- or double-quoted. For example, `'example'`, `"myCrossfade"`.
* `trackName`: *(optional)* the name of the track (defined in the config), which should start playing (become dominating) right after crossfade creation. It should be single- or double-quoted. For example, `'exampleTrack1'`, `"firstTrack"`. If not specified, all the tracks will start at 0 volume.
* `fadein`: *(optional)* how fast or slow should the first track increase its volume, in seconds. It should be a decimal number. For example, `2` or `10`. If not specified, the track will start at 100% volume immediately.

### Change the dominating track
Code: `Crossfades.Redominate(crossfadeName, trackName, length)`
* `crossfadeName`: **(required)** the name of the crossfade, defined in the config. Should be single- or double-quoted. For example, `'example'`, `"myCrossfade"`.
* `trackName`: *(optional)* the name of the new dominating track (defined in the config). Should be single- or double-quoted, or *nil*. For example, `'exampleTrack1'`, `"firstTrack"`, `nil`. If not specified (or is *nil*), the dominating track gets silent, but all the tracks will keep playing.
* `fadein`: *(optional)* how fast or slow should the redomination happen, in seconds. It should be a decimal number. For example, `2` or `10`. If not specified, redomination will happen instantly.

### Stop the crossfade
Code: `Crossfades.Stop(crossfadeName, fadeout)`
* `crossfadeName`: **(required)** the name of the crossfade, defined in the config. Should be single- or double-quoted. For example, `'example'`, `"myCrossfade"`.
* `fadeout`: *(optional)* how fast or slow should the dominating track get silent, in seconds. It should be a decimal number. For example, `2` or `10`. If not specified, the dominating track will get silent immediately.
