# weather-cat

☀️☁️☔️⛄️💦🌈

## v1 features: 

- [x] current apparent temp, 
- [ ] current apparent temp as statusbar icon
- [ ] weather range over the rest of the day (hidden in a menu)
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
- [ ] weather autoupdates (hourly)
- [ ] obfuscate/gitignore/change forecast api key
- [x] show sunrise or sunset(`sunRiseOrSet`) , depending on what's upcoming (ie: show sunrise after the sun has set, and vice versa)
- [ ] preference option to start app on boot (bool)
- [ ] get/borrow/steal app store dev acct
- [ ] marketing(what)/educational(why)/download(how) site (on gh-pages)
	- has faqs section at the bottom, model it after the overcast site
		- why not mac apps: culture of nondisposable, sustainable software/economy, apple neglect of the store (https://dancounsell.com/articles/not-on-the-mac-app-store)

## v1?

http://mattgemmell.com/releasing-outside-the-app-store/

- [ ] updator? sparkle? app store?
- [x] do I HAVE to have an dev certificate/pay 100$? (yup)


## v2 

- [ ] tests (at least for helper methods)

## build and compile

`pod install`
