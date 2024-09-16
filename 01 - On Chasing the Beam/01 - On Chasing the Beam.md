---------------- Table of Contents ---------------- 

1. [Welcome](#welcome)
2. [Logistics](#logistics)
3. [TLDR](#tldr)
4. [Day 1](#day1)
5. [Day 2](#day2)

---------------- Table of Contents ---------------- 

The Atari 2600 was released in 1977, 1 year before I was born. It existed as an active system up until around 1991 and just last year, 2023, it got a release for modern televisions. There has been an active development community for the Atari 2600 since the machine was new and, in fact, we owe the 2600 for just about everything from developers actually being named to crunch to innumerable facets of the video game industry that exist to this day. 

In fact, we could point to Steve Jobs getting his start in software development at Atari. We could point to Mark Cerny, the current Sony system architect, as employee 16,000 of Atari at the age of 17 where he would create Marble Madness and push the envelope of 3-D design. 

We have pornographic games, pirated games, games that reportedly destroyed the game industry, and much, much more. 

So, where do we begin? How? Why?

Over the course of the semester, i'll be bringing you through not only the history of Atari 2600 programming, but the language it used for development -- Assembly 6502. We will be "chasing the beam" all semester. So get ready!
# <a id = "welcome"></a>Welcome!!!!

Goal: Introduce a general history and tech spec we'll be working with. 

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

Let's take a little journey across Pac Man ports for the 2600.
Mark Cerny
Howard Scott Warshaw

(Sources):
https://spectrum.ieee.org/atari-2600


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
## Resources and Additional Spaces to Learn
Assembly has been around for nearly 50 years now and it's been active for ages. You've probably used something that was written in Assembly and for the 6502 over the years if you've ever: 
* Touched an NES
* Touched a Commodore product
* Played with a tomogatchi
* Played with the Atari Lynx.
The chip (MOS 6502) is also in the hall of fame of chips: https://spectrum.ieee.org/chip-hall-of-fame-mos-technology-6502-microprocessor/particle-7#:~:text=6502%20Micro%2Dprocessor&text=The%20chip%2C%20and%20its%20variants,known%20as%20the%20Atari%20VCS).

I've used and collected a huge number of resources for this course. I'll put a bunch here and a bunch more in the MyCourses instance: 
* Pikuma 6502 course: https://pikuma.com/courses/learn-assembly-language-programming-atari-2600-games
* 8-Bit Workshop: https://8bitworkshop.com/ this is where our textbook comes from and our in-class IDE. I'll provide some instructions on other ways to develop as needed. 
* There is a neat amount of documentation on 8bit workshop as well: https://8bitworkshop.com/docs/platforms/vcs/index.html
* 6502 documentation: http://www.visual6502.org/
	* Note in the above that the Atari uses the 6507 chip and as such, has a variety of commands that are not available. 
* https://www.atarimania.com/list_ads_atari_page-_1-_2.html
	* Ephemera and collected wisdom about the Atari over time. It's neat to see ads and things from when it was new.
* https://skilldrick.github.io/easy6502/#first-program
	* This is a super neat visualization engine of Assembly. It's sort of like Python Anywhere but for Assembly and will be useful at times. 
* Snake in Assembly: https://gist.github.com/wkjagt/9043907
# <a id = "tldr"></a>TLDR
Old machine is old, but it contains all the building blocks we still use. While it has extreme limitations (4k bytes of memory total), that limitation is reinforced by being able to interact with the hardware as directly as possible.

The video game industry had to learn how to make games, D&D existed but was not incorporated immediately into the world of games in the home arcades because of the limitations. 

Over the course, we will learn about the games, their history, and more.

# <a id = "day1"></a>Day 1
History of the machine and its legacy

# <a id = "today"></a>Day 2
Chipset and hardware

Next week: The elements of the screen, IDEs, and Getting Started - pipeline and experimentation, other places to practice.

Week 03 - Hello World
