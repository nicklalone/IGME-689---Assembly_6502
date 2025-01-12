---------------- Table of Contents ---------------- 

1. [Welcome](#welcome)
2. [Logistics](#logistics)
3. [TLDR](#tldr)
4. [Day 1](#day1)
5. [Day 2](#day2)

---------------- Table of Contents ---------------- 

Again, these can all be found: 
* `GRP0 or GRP1` - 8 bit pattern. Graphics of Player 0 or 1
* `COLUP0 or COLUP1` - 8-bit pattern. Color Luminescence Player 0 or 1
* `NUSIZ0 or NUSIZ1` - Controls the number and size of player 0,1 and missile 0,1.
	* Has a number of bits that indicate duplication, stretch, and other things.
* `REFP0, REFP1` - Reflect Player 0 or 1. 
	* Basically, which way do you want the player to face?
* `M0 or M1` - Missile 0 or Missile 1. Just 1 pixel but can be stretched 2/4/8 times.
* `BL` - Ball and it uses the Playfield Foreground color.
* ``
The basic idea of making an Atari game is that for each scanline from the top left to bottom right, we have to configure the Television Interface Adaptor or TIA registers for each object JUST before the beam reaches its intended position.