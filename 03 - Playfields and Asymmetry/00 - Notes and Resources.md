These files are mostly for me as I go around and look for good resources. While a lot of this stuff will be tangential, it's mostly for folks who want a lot more in depth information. It's also help for me because i'll be teaching this stuff and so I have to learn a new thing in order to teach it and that's a very different level of learning to just do stuff.

I really enjoyed learning what games used how many scanlines: https://www.digitpress.com/library/techdocs/vcs_scanlines.htm

https://forums.atariage.com/topic/169128-what-is-the-atari-2600-screen-resolution/
	This is an excellent question, but a complicated one to answer, because the answer can vary, and it can also depend on the terminology used. I'll keep my explanations as simple as I can while still being reasonably accurate and complete! [![:)](https://forums.atariage.com/uploads/emoticons/atariage_icon_smile.gif)](https://forums.atariage.com/uploads/emoticons/atariage_icon_smile.gif "Enlarge image")
	
	The Atari 2600 was created within the analog TV universe, and analog TV has no specific horizontal resolution per se, due to the analog nature of the signal. However, the vertical resolution for American analog NTSC TV is 525 lines, but some of those lines are devoted to the vertical blank period and the vertical sync. The lines that carry actual picture information are called "active" lines, and different sources give different numbers of active lines, ranging from 480 to (if I remember correctly) 485. The actual number is a little bit irrelevant, because some of the active lines are typically cropped, or "displayed" beyond the top and bottom edges of the screen. In modern times, the vertical resolution is usually given as "480i," or 480 lines displayed with interlacing.
	
	By default, the Atari 2600's picture isn't interlaced, so the vertical resolution would be given as "240p," or 240 lines displayed progressively, without interlacing. Yet it *is* possible to create an interlaced display on the Atari 2600, so it *is* capable (through special programming) of displaying 480 active lines.
	
	Most games limit the number of active lines to about 192, partly (and primarily) because with anything higher than that, you run the risk of some lines getting cropped at the top and bottom of the screen-- especially in the corners on older TV sets that have "rounded" corners. Another (secondary) consideration is that having fewer active lines lets you increase the length of the vertical blank period, thereby giving you more time to do all the processing that the game needs to do.
	
	With interlacing, this could be doubled to 384 active lines or more, but we'll focus on a non-interlaced display (or 240p).
	
	Although the horizontal resolution of analog NTSC TV is essentially undefined (since there are no "pixels" per se in an analog signal), in practice there's a limit to the effective horizontal resolution. However, this has no real bearing on the Atari 2600, because the 2600's signal is tied to the "color clocks" on each line. A "color clock" is often thought of as a "pixel," although they aren't really the same thing. Nevertheless, the smallest dot of color that the 2600 can draw is 1 color clock wide. NTSC TV has 227.5 color clocks per line, but the 2600 outputs 228 color clocks per line. However, 68 of these color clocks are devoted to the horizontal blank period and horizontal sync, so that leaves 160 active color clocks per line-- hence, the statement that the 2600 has a horizontal resolution of 160 pixels (228 - 68 = 160).
	
	So that's where the "160x192" resolution comes from. However, that's a simplified answer, and the 2600 doesn't really have 160x192 *pixels* on its screen display.
	
	It's possible (through special programming) to reduce the number of active color clocks on each line by increasing the length of the horizontal blank period, but I won't get into that, because my answer is already getting complicated enough.
	
	Rather, let's talk about pixels, because that's what we're *really* interested in. For the sake of argument, we'll stick with the 160x192 resolution. Those aren't pixels, they're really color clocks and scan lines. The term "pixel" is rather complicated on the 2600, because the 2600 has different kinds of graphical objects that can make up its display, as follows:
	
	- the background
	- the playfield
	- the player0 sprite
	- the player1 sprite
	- the ball sprite
	- the missile0 sprite
	- the missile1 sprite
	
	The background has no "pixels" per se, because it has no bits that can be turned on and off-- it's really just one huge pixel that fills up the active portion of the screen. However, the other graphical objects are displayed on top (or in front) of the background, such that the background shows through wherever the pixels of the other objects are turned off. That means you can refer to "background pixels" wherever the background is showing through the empty spots in the other objects. In that sense, there can be many background pixels on the screen, and the smallest possible background pixel would be 1 color clock wide and 1 scan line tall (or "1x1").
	
	The playfield is 40 pixels across, and each pixel is 4 color clocks wide. You can vary the vertical resolution of the playfield depending on how often you update the three playfield registers-- every line, every 2 lines, every 3 lines, every 4 lines, etc. So the vertical resolution of a single playfield pixel can vary from 1 line to 192 lines (or a resolution from "4x1" to "4x192"). You can even vary the playfield's vertical resolution on different lines of the screen, but we won't go there. [![;)](https://forums.atariage.com/uploads/emoticons/atariage_icon_wink.gif)](https://forums.atariage.com/uploads/emoticons/atariage_icon_wink.gif "Enlarge image")
	
	The two players each have 8 bits, or are 8 pixels wide. However, the players can be displayed at single-width, double-width, or quadruple-width, so their pixels can be 1 color clock wide, 2 color clocks wide, or 4 color clocks wide. The vertical size of each player pixel can vary, just as with the playfield, so a single player pixel can have a resolution ranging from "1x1" to "1x192," or from "2x1" to "2x192," or from "4x1" to "4x192" (depending on the width of the player).
	
	The other three sprites-- the ball and the two missiles-- each have only 1 bit, or are 1 pixel wide. However, they can be displayed at single-width, double-width, quadruple-width, or octuple-width, so the pixel can be 1 color clock wide, 2 color clocks wide, 4 color clocks wide, or 8 color clocks wide. As with the playfield and players, the vertical size of each pixel can vary, from 1 line tall to 192 lines tall.
	
	As if all of that weren't complicated enough, you can change the color of a pixel as it's being drawn, and you can change its color from line to line. To the 2600 (in terms of turning a pixel on or off), it's still just a single pixel. But to your eye, that single pixel appears to be two or more pixels, since it's being drawn with two or more colors. So that means we have "logical" pixels that are controlled by turning their bits on or off, but we also have "virtual" pixels as defined by the dots of unique colors that are being displayed. In that sense, a virtual pixel can be smaller than a logical pixel (by splitting it up with color changes), or a virtual pixel can be larger than a logical pixel (by displaying two or more pixels of the same color side-by-side so they appear to be one block of color).
	
	Given the complexity of this topic, it's no wonder people just simplify things by saying the Atari 2600 has a screen resolution of 160x192. But you can't actually display 160x192 pixels (or dots of unique color) on the screen at once, due to the limitations of the 2600's graphical objects. Still, the 160x192 resolution "works" in the sense that there are 160x192 specific locations on the screen that can have a unique color. For example, if you draw an 8x8 checkerboard pattern with a player sprite, where each player pixel is 1 color clock wide and 1 scan line tall, and if you then move the little 8x8 checkerboard (or player) around on the screen such that it passes over every possible location, each of the 160x192 locations can be one color or another at one time or another-- just not at the same time.
	
	Sorry for overwhelming you with such a complicated answer, and I hope I didn't make your head spin too much! [![:D](https://forums.atariage.com/uploads/emoticons/atariage_icon_mrgreen.gif)](https://forums.atariage.com/uploads/emoticons/atariage_icon_mrgreen.gif "Enlarge image")

https://alienbill.com/2600/playerpalnext.html