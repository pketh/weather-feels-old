# weather-cat

☀️☁️☔️⛄️💦🌈

## v1 features: 

- [x] current apparent temp, 
- [x] current apparent temp as statusbar icon
- [x] weather statusbar icons
- [x] weather range over the rest of the day (hidden in a menu)
- [x] today’s weather summary (ex ‘clear throughout the day’)
- [x] today’s sunset time
- [x] emojis to represent recommended clothes (pants, bikinis etc.)
	- hot(sunny+>70) 👙👟
	- medium(60-70) 👕👗
	- cold(>60) 👖👘

	also, (prepended)
	- ☔️ add precip warning emoji if precipProbability > .. and preceipIntensity > ..
		- 🌂 for less chance 
- [x] weather alerts
- [x] sunset icon uses correct moonphase emoji icon 🌖🌗🌘🌒 etc
- [x] weather autoupdates (hourly)
- [x] obfuscate/gitignore/change forecast api key
- [x] show sunrise or sunset(`sunRiseOrSet`) , depending on what's upcoming (ie: show sunrise after the sun has set, and vice versa)
- [ ] clean up formatting for submenu

- [ ] i think the sunrise or sunset logic is still broken? (tested at 2am, saw sunset string. expected sunrise)
- [ ] preference option to start app on boot (bool)
- [ ] get/borrow/steal app store dev acct
- [ ] marketing(what)/educational(why)/download(how) site (on gh-pages)
	- design notes: draggable randomly laid out js, letters -> emoji for weather effects at scroll positions. easter egg mystery cat.
	- has faqs section at the bottom, model it after the overcast site
		- why not mac apps: culture of nondisposable, sustainable software/economy, apple neglect of the store (https://dancounsell.com/articles/not-on-the-mac-app-store)
- [ ] remember location option pref so the app doesn't have to keep asking. (unless you ask it to update)


## v1?

http://mattgemmell.com/releasing-outside-the-app-store/

- [ ] updator? sparkle? app store?
- [x] do I HAVE to have an dev certificate/pay 100$ until I die?


## v2 

- [ ] tests (at least for helper methods)

## build and compile

`pod install`

edit using `Weather Cat.xcworkspace`
