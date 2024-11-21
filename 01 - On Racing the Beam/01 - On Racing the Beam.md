The Atari 2600 was a real mess. It's a good thing that we don't try to program machines like that anymore because it was just absurd. But it was kind of fun in a sick way if you like that kind of challenge.
	Howard Scott Warshaw, Atari 2600 game developer
	Creator of Yar's Revenge and E.T. the Extra-Terrestrial

---------------- Table of Contents ---------------- 

1. [Welcome](#welcome)
2. [The 2600 and its Legacy](#2600)
3. [Logistics](#logistics)
4. [Resources and Additional Spaces to Learn](#resources)
5. [TLDR](#tldr)
6. [Next Time](#nexttime)

---------------- Table of Contents ---------------- 

The Atari 2600 was released in 1977, 1 year before I was born. It existed as an active system up until around 1991 and just last year, 2023, it got a release for modern televisions. Or in other words, a thing from my childhood is new again.

Fortunately, there has been an active development community for the Atari 2600 since the machine was new. Learning about that enthusiast community, the company that birthed the video game console, and where all those employees went in the great crash in the 80s will teach us a lot about how we've learned to make games, but also how we've learned to develop games. 

We owe Atari a ton; in fact, we owe the 2600 for just about everything (good and bad) from developers actually being named to crunch to 3rd party developers to innumerable facets of the video game industry that exist to this day. 

We could point to Steve Jobs getting his start in software development at Atari (really it was Woz but that's a long story). We could point to Mark Cerny, the current Sony system architect, as employee 16,000 of Atari at the age of 17 where he would create Marble Madness and push the envelope of 3-D design. 

We have pornographic games, super racist games, pirated games, games that reportedly destroyed the game industry, edugames, exercise games, and much, much more. 

It's a vast, complex ecosystem that has never truly stopped learning. 

So, where do we begin? How? Why?

Over the course of the semester, i'll be bringing you through not only the history of Atari 2600 programming, but the language it used for development -- Assembly 6502. 

We will be "[racing the beam](https://www.youtube.com/embed/sJFnWZH5FXc?si=p-55AMiUwLfz8yM2)" all semester. So get ready!
# <a id = "welcome"></a>Welcome!!!!
Goal: Introduce a general history and the context of where and why we'll be creating games for this now live system. 

To begin, I think it's important to talk about the software of the console and their legacy. Some of what we tried when the video game idea was new has never been developed further. Other aspects of games have been overdeveloped. And so we're in a weird space with regard to the video game at the moment. Tech is stalling, games are stalling, everything is starting to feel stale, and so we have a reason to look backward. 

In this section, we''ll talk about the early attempts at games, early video game consoles, the legacy of the 2600, and games of note on the system. We'll even talk about a few recent games of note released within the past 5-10 years for the 2600. 
### Early Attempts at Games
The earliest video game many of us have been able to find is a game called Draughts (Checkers) in 1951 by Christopher Strachy. This game was written in 1951 but not fully run until 1952. It is a notable piece of technology because the origin of Machine Learning in the computer sciences are based in and around a Checkers playing program from Arthur Samuel in 1959. While Samuel had been working on the concept for almost a decade at that point, it was in 59 that this game playing software or new attempt at what would become Game AI would appear. In other spaces, we'd see games here and there but most of them were parlor games or weird hybrids like light games like Drive-Mobile below. 

![](/images/consoles/drivemobile.png)

#### Tennis for Two (1958)
The Manhattan Project gave us the Atomic Bomb but almost immediately after using it, the sheer magnitude of what had been done began to weigh heavily on many. Spacewar! from William Higgenbotham was born out of the guilty associated with the bomb. This was not only one of the first video games, but was also a piece of software that used graphic displays, a novelty at the time. 

![](/images/consoles/tennis42.png)
#### Spacewar! (1962)
Spacewar! has long been considered the first videogame though Higgenbotham's work is more recently being given recognition. Whereas Higgenbotham was working at Brookhaven, Spacewar!'s creators,  Steve Russell in collaboration with Martin Graetz, Wayne Wiitanen, Bob Saunders, Steve Piner, and a few others associated with the railroad club at MIT and a lab at Harvard, were all working at MIT. Much like the game Draughts, mentioned above, there were a variety of games that had been designed but had mostly been novelty games like Checkers or Tic-Tac-Toe. Notably, this game was [written in Assembly](https://www.masswerk.at/spacewar/sources/). 

![](/images/consoles/spacewar.png)
#### Pong!
### Magnavox Odyssey
This is often considered the first console. It was kind of a weird thing in that it didn't use cartridges but you could use various sheets to shift the games around. It included a number of board game pieces that could be used with the games as there wasn't any logic stored in the console. It is notable for sort of standardizing the normal collection of objects we associate with video games such as detachable controllers, paddles, and light guns. The later, light guns, is important because an older company called Nintendo had formed a partnership with Magnavox to expand their toy production capacity via their carnival light gun games. This would be how Nintendo gets involved with the video game market.

At current, Magnavox (now Phillips Magnavox after its purchase in 1974 and then later would develop the laserdisc with Sony and then even later become a part of the company Raytheon) is mostly owned by a Japanese company called Funai but that company is in trouble.

![](/images/consoles/odyssey.png)
### Fairchild Channel F
The Fairchild Channel F (F for fun!) was an important console to the history of games but one that got decimated by the popularity of the Atari 2600. It is a notable console as it contains: 
* origin of the video game cartridge.
* [first easter egg](https://www.youtube.com/watch?v=ws-ExrlbmtY)
* perhaps the first programmable game system (assembly language for the 6800 microprocessor)
* Also the first 8-bit processor but was quickly eclipsed and forgotten
If you get a chance, give the games a shot. It is a bit weird to see games with even fewer resources than a 2k game on the 2600 but it's also neat to see different computational approaches to interactive media.

Fairchild was owned by Lockheed Martin for a while until it was sold off to the Carlye Group when they were buying things before and during the tech bust in 2000. At the moment, the company doesn't really exist anymore but is considered property of BAE Systems, a defense contractor. You may wonder why so many of these companies end up in defense spaces and this is because of the origin of games from defense technologies. While they may have been born because of war and many games originating from the war gaming tabletop space via Dungeons and Dragons and Stat-o-matic games, their legacy has surprassed their violent origin. 

![](/images/consoles/channelf.png)
# <a id="2600"></a>The Atari 2600 and its Legacy
So, the Atari 2600 turns 50 this year. There's a whole lot of activity in and around the console. So much so that they sat down and re-released a new version of the console (the Atari 2600+) that can hook up to an HDMI signal. The only real tradeoffs are that instead of reading the game cart in real time, it dumps the ROM and reads it internally. It makes a more stable game experience but also makes the first failure to boot (so we gotta blow on the carts) take more time as it needs to load Stella to load the ROM it dumps. 

![](/images/consoles/2600plus.png)
You can buy one if you like! They are around $130. 

So for many of you, you might have heard some myths and legends here and there. Ready Player One is probably a source for a lot of the current nuggets in culture at the moment. However, there's a rich legacy that we'll be digging into today as we learn how to make bits move around on the console. Let's talk about how the Atari got established, establish a high level overview of how it works, and then get into some specifics like the legacy it established in the game industry as a whole. We'll finish by talking about notable games and designers.
## Not the origin but where we started


### The General Loop

Hardware: 
	Tennis for 2, Droughts, Channel F, 
	Chuck Pebble the 8080, the 6502, the 6507
	Technical development of the TIA development
	Other systems with the 6502

Functional Description: 
What makes up the 2600?
* 6507, a cost-reduced 6502 in a 28-pin package.
- 6532, with 128 bytes of RAM, 16 I/O ports, and a programmable timer 
- TIA, which generates video and audio
- a 2K or 4K ROM via cartridge slot

	Carts contain all ROM and Instructions for hardware.
	The system itself contains 3 chips (show schematic)
	The most interesting (maybe) thing about this system is how barebones it is. 
	There are no tuples for coordinates (x,y). Instead, you time drawing according to the beam's position.
	What is the beam?

Here, you won't have a system like Unity do things for you, you have to painstakingly *(and concisely)* write a game on your own (or with a team). I will be doing this with you.

And so, you may consider this system, this course, and this language old, backward, and weird but it's also withstood the test of time as the Atari 2600 is new again but unlike all new systems where we have to learn how things work and then build on it with custom libraries and development content, we here will be learning how to do *everything by hand*. And this is very unlike what these folks did. 
## Credits for Designers

## Founding of Activision

## Pipelines (and Crunch)

## Notable Games 

## Notable Designers
Mark Cerny
Howard Scott Warshaw

# <a id = "logistics"></a>Logistics
I wrote this course for 3 reasons: 
1. I grew up with the Intellivision as my first console but have always been curious about the Atari.
2. Get into Assembly and Vintage Computing because of my actual work.
3. Teach another programming course that isn't python. 
The course will be an intense dungeon but we'll try and structure it so it's not so time consuming. 

The general loop of the course is this: 
11 weeks: 
1. Read something - Usually chasing the beam, your textbook, and something else.
2. Watch something - Usually a post mortem
3. Annotate a source file - from the 2600's past.
4. Write something - typically it'll be a brief response, a design doc, or a coding exercise. 

5 weeks: 
1. Make a game.
2. Check in with me.
## <a id = "resources"></a>Resources and Additional Spaces to Learn
Assembly has been around for nearly 50 years now and it's been active for ages. You've probably used something that was written in Assembly and for the 6502 over the years if you've ever: 
* Touched an NES
* Touched a Commodore product
* Played with a tomogatchi
* Played with the Atari Lynx.
The chip (MOS 6502) is also in the [hall of fame of chips](https://spectrum.ieee.org/chip-hall-of-fame-mos-technology-6502-microprocessor/particle-7#:~:text=6502%20Micro%2Dprocessor&text=The%20chip%2C%20and%20its%20variants,known%20as%20the%20Atari%20VCS)).

I've used and collected a number of resources for this course. I'll put a bunch here and a bunch more in the MyCourses instance.

**Courses:** 
* [Pikuma 6502 course](https://pikuma.com/courses/learn-assembly-language-programming-atari-2600-games)

**Self-Study**
* [8-Bit Workshop](https://8bitworkshop.com/)
	* this is where our textbook comes from and our in-class IDE. I'll provide some instructions on other ways to develop as needed. 
	* There is a [neat amount of documentation on 8bit workshop as well](https://8bitworkshop.com/docs/platforms/vcs/index.html)
* [Visual 6502](http://www.visual6502.org/)
	* Note in the above that the Atari uses the 6507 chip but still can use pretty much everything here. 
* [Easy 6502](https://skilldrick.github.io/easy6502/#first-program)
	* This is a super neat visualization engine of Assembly. It's sort of like Python Anywhere but for Assembly and will be useful at times. 
* [8Blit Atari 2600 Programming](https://www.youtube.com/@8Blit/playlists)
	* 8Blit is simply amazing. So many easy to understand tutorials and approaches to the work.

**Ephemera and Atari Stuff**
* https://www.atarimania.com/list_ads_atari_page-_1-_2.html
	* Ephemera and collected wisdom about the Atari over time. It's neat to see ads and things from when it was new.x`

**Sample Code and Alt Projects**
* Snake in Assembly: https://gist.github.com/wkjagt/9043907

**Videos**
* [28c3: The Atari 2600 Video Computer System: The Ultimate Talk](https://www.youtube.com/watch?v=qvpwf50a48E&ab_channel=28c3)
* [27c3: Reverse Engineering the MOS 6502 CPU (en)](https://www.youtube.com/watch?v=fWqBmmPQP40&t=1926s&ab_channel=Christiaan008)
* [Atari 2600 Programming is a Nightmare](https://www.youtube.com/watch?v=-l18Rwbinp8&ab_channel=Truttle1)
* [Making Labels for 2600 Games](https://www.youtube.com/watch?v=-bbGbGVC6FY&ab_channel=MarkFixesStuff)
* [Burning EEPROMS for the 2600](https://www.youtube.com/watch?v=77PMlBhEHFw&t=1183s&ab_channel=ArtifactElectronics)
* [Hello World on an Atari? Not Easy!](https://www.youtube.com/watch?v=iyzehlHJZ7w&t=877s&ab_channel=TheRetroDesk)
	* This video gets a bit into Batari Basic so it won't be covered in class but if this is something you're interested in, have at it.
* [Racing the Beam Explained - Atari 2600 CPU vs. CRT Television](https://www.youtube.com/watch?v=sJFnWZH5FXc&t=441s&ab_channel=RetroGameMechanicsExplained)
# <a id = "tldr"></a>TLDR
Old machine is old, but it contains all the building blocks we still use in the industry to this day. While it has extreme limitations (4k bytes of memory total (which can be augmented with memory banking but we'll not cover that in this course)), that limitation is reinforced by being able to interact with the hardware as directly as possible. As such, programming for this newly re-released system can show you on a very intimate level how your code and the hardware interact.

Another reason this is useful is that the video game industry had to learn how to make games, D&D existed but was not incorporated immediately into the world of games in the home arcades because of the limitations. 

Over the course, we will learn about the games, their history, and more.
# <a id = "nexttime"></a>Next Time
We'll talk about the technical nature of the Atari 2600 and just how ~~little~~ much you'll be working with. Be prepared to be amazed!!!
