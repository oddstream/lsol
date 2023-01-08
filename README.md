# Minimal Polymorphic Solitaire in Lua and LÖVE

Towards a polymorphic solitaire engine in [Lua](https://lua.org/)+[LÖVE](https://love2d.org/).

![Screenshot](https://github.com/oddstream/gosol/blob/7152668f4b5053a1d438981e9d4564624616da6a/screenshots/Simple%20Simon.png)

Play it by downloading/installing the LÖVE runtime and typing 'love lsol.love'. It's tested on Linux, Windows and [Android via the Google Play Store](https://play.google.com/store/apps/details?id=com.oddstream.lovesolitaire).

## Variants

It currently knows how to play 75 variants:

♥ Accordian
♥ Agnes Bernauer
♥ Agnes Sorel
♥ Algerian
♥ Alhambra
♥ American Toad
♥ American Westcliff
♥ Assembly
♥ Athena
♥ Australian
♥ Baker's Dozen
♥ Baker's Dozen (Wide)
♥ Baker's Game
♥ Baker's Game Relaxed
♥ Beleaguered Castle
♥ Bisley
♥ Black Hole
♥ Blockade
♥ Busy Aces
♥ Canfield
♥ Chinese Freecell
♥ Classic Westcliff
♥ Crimean
♥ Cruel
♥ Double Freecell
♥ Duchess
♥ Easthaven
♥ Eight Off
♥ Eight Off Relaxed
♥ Flat Castle
♥ Forty Thieves
♥ Forty and Eight
♥ Freecell
♥ Gargantua
♥ Gate
♥ Giant
♥ Good Thirteen
♥ Josephine
♥ Klondike
♥ Klondike (Turn Three)
♥ Limited
♥ Little Spider
♥ Lucas
♥ Martha
♥ Miss Milligan
♥ Mount Olympus
♥ Penguin
♥ Pyramid
♥ Pyramid Relaxed
♥ Rainbow Canfield
♥ Red and Black
♥ Rosamund
♥ Royal Cotillion
♥ Russian
♥ Scorpion
♥ Sea Haven Towers
♥ Simple Simon
♥ Somerset
♥ Spider
♥ Spider One Suit
♥ Spider Two Suits
♥ Spiderette
♥ Spiderette One Suit
♥ Spiderette Two Suits
♥ Storehouse Canfield
♥ Thoughtful
♥ Tri Peaks
♥ Tri Peaks Open
♥ Ukrainian
♥ Usk
♥ Usk Relaxed
♥ Wasp
♥ Yukon
♥ Yukon Cells
♥ Yukon Relaxed

Variants are added when the whim takes me, or when some aspect of the engine needs testing/extending, or when someone asks.

Some variants have been tried and discarded as being a bit silly, or just too hard:

* Giant
* King Albert
* Raglan

Some games I've added reluctantly:

* Pyramid
* Tri Peaks

Some will never make it here because they are just poor games:

* Golf

![Screenshot](https://github.com/oddstream/gosol/blob/7152668f4b5053a1d438981e9d4564624616da6a/screenshots/Australian.png)

## Other features

* Permissive card moves. If you want to move a card from here to there, go ahead and do it. If that move is not allowed by the current rules, the game will put the cards back *and explain why that move is not allowed*.
* Unlimited undo, without penalty. Also, you can restart a deal without penalty.
* Bookmarking positions (really good for puzzle-style games like Penguin, Freecell or Simple Simon).
* Scalable cards; when running on a desktop, just resize the window to make the cards fit the baize.
* Simple or regular card designs.
* One-tap interface. Tapping on a card or cards tries to move them to a foundation, or to a suitable tableau pile. An empty tableau with a constraint is not considered suitable, as empty tableaux are precious.
* Cards in red and black (best for games like Klondike or Yukon where cards are sorted into alternating colors), or in four colors (for games where cards are sorted by suit, like Australian or Spider).
* Every game has a link to it's Wikipedia page.
* Statistics (including percent complete and streaks; percent is good for games that are not often won, and streaks are good for games that are).
* Cards spin and flutter when you complete a game, so you feel rewarded and happy.
* Automatic saving of game in progress.
* A dragable baize; if cards spill out of view to the bottom or right of the screen, just drag the baize to move them into view.

## Deliberate minimalism

A lot a features have been tried and discarded, in order to keep the game (and player) focused. Weniger aber besser, as [Dieter Rams](https://en.wikipedia.org/wiki/Dieter_Rams) taught us. Design is all about saying "no", as Steve Jobs preached. Just because a feature *can* be implemented, does not mean it *should* be.

Configurability is the root of all evil, someone said. Every configuration option in a program is a place where the program is too stupid to figure out for itself what the user really wants, and should be considered a failure of both the program and the programmer who implemented it.

![Screenshot](https://github.com/oddstream/gosol/blob/7152668f4b5053a1d438981e9d4564624616da6a/screenshots/American%20Toad.png)

## FAQ

### What makes this different from the other solitaire implementations?

This solitaire is all about [Flow](https://en.wikipedia.org/wiki/Flow_(psychology)).

Anything that distracts from your interaction with the flow of the game has been either been tried and removed or not included.

Crucially, the games can be played by single-clicking the card you wish to move, and the software figures out where you want the card to go (mostly to the foundation if possible, and if not, the biggest tableau). If you don't like where the card goes, just try clicking it again or dragging it.

Also, I'm trying to make games authentic, by taking the rules from reputable sources and implementing them exactly.

### Why are the graphics so basic?

Anything that distracts from your interaction with the flow of the game,
or the ability to scan a deck of cards,
has either been tried and removed, or not included.
This includes:
fancy card designs (front and back),
keeping an arbitrary score,
distracting graphics on the screen.

The user interface tries to stick to the Material Design guidelines, and so is minimal and tactile.

I looked at a lot of the other solitaire websites and apps out there, and think how distracting some of them are. Features seem to have been added because the developers thought they were cool; they never seem to have stopped to consider that just because they *could* implement a feature, that they *should*.

### Sometimes the cards are really huge or really tiny

If you're running the app on a desktop, resize the window; the cards will scale automatically.

If you're runnning on a mobile device, try rotating the device. (Solitaire apps are better suited to the larger and squarer screens of tablets, rather than phones.)

### The rules for a variation are wrong

There's no ISO or ANSI or FIDE-like governing body for solitaire; so there's no standard set of rules.
Other implementations vary in how they interpret each variant.
For example, some variants of American Toad build the tableau down by suit, some by alternate color.
So, rather than just making this stuff up, I've tried to find a well researched set of rules for each variant and stick to them, leaning heavily on Wikipedia, Jan Wolter (RIP, and thanks for all the fish), David Parlett and Thomas Warfield. Where possible, I've implemented the games from the book "The Complete Book of Solitaire and Patience Games" by Albert Morehead and Geoffrey Mott-Smith.

### Keyboard shortcuts?

* U - undo
* N - new deal (resign current game, if started)
* R - restart deal
* B - bookmark current position (LCtrl or LShift + B to go back to the bookmarked position)
* C - collect cards to the foundations

### What about scores?

Nope, the software doesn't keep an arbitary score. Too confusing. Just the number of wins, number of moves, the average 'completeness percentage' and your winning streak (streaks are great).

A game isn't counted until you move a card. Thereafter, if you ask for a new deal or switch to a different variant, that counts as a loss.

You can 'cheat' the score system by restarting a deal and then asking for a new deal.

'Completeness percentage' is calculated from the number of unsorted pairs of cards in all the piles.

### Odd features

You can restart a deal without penalty; it's not cheating, because you could just set a bookmark at the start of a game and return to that position.

You cannot move cards from a foundation pile. Most sources I've read explicity ban moves from the foundations, so I've implemented a blanket ban. There's always undo, if you've got into a bad situation.

Movable cards are not highlighted unless you ask for help by tapping the lightbulb icon. For the longest time, I thought that highlighting movable cards was a neat feature, but I now realize that this feature ruins the essence of most games. In trying to replicate and assist the feeling of playing with real cards, this feature is a step too far.

### What's with the discard piles?

Some games, like Spider or Simple Simon, have discard piles instead of foundations. These are optional piles for you to place completed sets of cards into, if you wish to clear some space in the tableaux.

Most other solitaire implementations just have foundation piles that fulfill this role.

### What about a timer?

Nope, there isn't one of those. Too stressful.
Solitaire is also called *patience*; it's hard to feel patient when you're pressured by a clock.

### What's with the settings?

#### Simple cards

Use a set of card faces that have minimal graphics, just ordinal and suit. Can be easier to 'scan', especially on small devices.

#### Colorful cards

Normally, cards are either red or black. This setting makes the cards either just black, red/black or four-colored, depending on the variant being played. In variants where the tableaux build in suit (like Forty Thieves, Penguin or Eight Off) this can be a real help.

#### Gradient shading

By default, the baize and card backgrounds have a shading effect, where the center is lighter than the edges. You can turn this off if you find it annoying or distracting. There is no performance penalty or benefit either way.

#### Compress piles

With this on, piles of cards that a long and would overshoot the screen (usually the bottom of the screen, but also the right edge) are compressed dynamically (up to a point) so that all the cards can be seen. However, this can make the cards hard to read.

In any case, the baize can be dragged up or down to make all the cards visible.

#### Power moves

Some variants (eg Freecell or Forty Thieves) only allow you to move one card at a time. Moving several cards between piles requires you to move them, one at a time, via an empty pile or cell. Enabling power moves automates this, allowing multi-card moves between piles. The number of cards you can move is calculated from the number of empty piles and cells (if any).

#### Safe collect

In games like Klondike that build tableau cards in alternating colors, you can sometimes get into trouble by moving cards to the foundations too soon. With this option turned on, the titlebar collect button will only move cards to the foundation piles when it is safe to do so.

#### Mirror baize

For left-handed players on mobile devices.

#### Mute sounds

So you can, for example, listen to an audio book while playing.

#### Allow orientation (Android only)

With this set to 'on' (the default), rotating the phone/tablet will re-orient the baize.

With this set to 'off', the orientation will be fixed to whatever it was when the app started.

### Is the game rigged?

No. The cards are shuffled randomly using a Fisher-Yates shuffle driven by a Park-Miller pseudo random number generator, which is in itself seeded by a random number. This mechanism was tested and analysed to make sure it produced an even distribution of shuffled cards.

There are [80,658,175,170,943,878,571,660,636,856,403,766,975,289,505,440,883,277,824,000,000,000,000](https://en.wikipedia.org/wiki/Shuffling) possible deals of a pack of 52 playing cards; you're never going to play the same game twice, nor indeed play the same game that anyone else ever has, or ever will.

It's possible that a deal will start with no movable cards, just like it might if you'd dealt physical cards on a physical table.

### Any hints and tips?

* For games that start with any face down cards (like Klondike or Yukon) the priority is to get the face down cards turned over.
* For games that start with a block of cards in the tableau and only allow single cards to be moved (like Forty Thieves), the priority is usually to open up some space (create empty tableaux piles) to allow you to juggle cards around.
* For Forty Thieves-style games, the *other* priority is to minimize the number of cards in the waste pile.
* For puzzle-type games (like Baker's Dozen, Freecell, Penguin, Simple Simon), take your time and think ahead.
* For games with reshuffles (like Usk, Cruel and Perseverance) you need to anticipate the effects of the reshuffle.
* Focus on sorting the cards in the tableaux, rather than moving cards to the foundations. Only move cards to the foundations when you *have* to.
* Use undo and bookmark, a lot. Undo isn't cheating; it's experimenting and learning.

## Terminology and conventions

* A PILE of cards

* A CONFORMANT series of cards in a pile is called a SEQUENCE

* A set of cards is called a PACK (not 'deck')

* Suits are listed in alphabetic order: Club, Diamond, Heart, Spade

* Cards changing between face down and face up is called FLIPPING.

* The user never moves or flips a face down card, only the dealer can

* Cards cannot be played from the foundation

* Cell, Foundation and Waste piles only hold face up cards

* Stock only has face down cards

* A game is RELAXED when some constraint (usually, which card you can place in an empty tableau) has been removed.

* A game is EASY when the deal has been 'fixed', usually by moving Aces to the foundations, or shuffling Kings or Aces in the tableaux.

![Screenshot](https://github.com/oddstream/gosol/blob/7152668f4b5053a1d438981e9d4564624616da6a/screenshots/Klondike.png)

## The seven different types of piles

### Stock

All games have a stock pile, because this is where the cards are created and start their life.

In some games, like Freecell, the stock pile is off screen (invisible). In others, like Klondike, it's on screen (usually at the top left corner) and tapping the top card will cause one card to be flipped up and moved to a waste pile. In other games, like Spider, tapping the top card will cause cards to be moved to each of the tableau piles.

All cards in the stock are always face down. You can't move a card to the stock pile. There is only ever one stock pile.

### Tableau

Tableau piles are where the main building in the game happens. The player tries to move the cards around the tableau and other piles, so that the cards in each tableau pile are sorted into some game-specific order. For example, in Klondike and Freecell, the tableau cards start in some random order, and must be sorted into increasing rank and alternating color.

Sometimes, there is a constraint on which card may be placed onto an empty tableau, for example in Klondike, and empty tableau can only contain a King.

Some cards in the tableau pile may start life face down; the game will automatically turn the cards up when they are exposed.

### Foundation

Foundation piles are where the player is trying to move the cards to, so that the game is completed.

The cards in each foundation usually start with an Ace, and build up, always the same suit. A foundation pile is full (complete) when it contains 13 cards.

Only one card at a time can be moved to a foundation.

### Discard

Discard piles aren't usually found in other solitaire implementations.

Discard piles are like foundation piles, except that only a complete set of 13 cards can be moved at once.

Moving completed sets of cards to a discard is optional, and is usally done to create space in the tableaux. You do not have to move cards to a discard pile to complete a game.

### Waste

A waste pile can store any number of cards, all face up. You can only move one card at a time to a waste pile, and that card must come from the stock pile. There is only ever one waste pile.

In some games (like Klondike) cards in the waste pile can be recycled back to the stock pile, by tapping on an empty stock pile. The game may restrict the number of times this can happen.

### Cell

A cell is either empty, or it can contain one card of any type. Cell cards are always face up, and available for play to tableau or foundation piles. Cells are used as temporary holding areas for cards.

### Reserve

A reserve pile contains a series of cards, usually all face down with only the top card face up and available for play to a foundation, tableau or cell pile.

Only one card at a time may be moved from a reserve, and cards can never be moved to a reserve pile.

## TODO

* Get it working on iOS. But, I don't have a Macintosh and am reluctant to pay Apple the annual App Store fee, and jump through their hoops. If you want to do this, let me know and we'll collaborate.
* I'd like it to have an inter-user high scores table, but the Google Play games services interface and setup is inpenetrable to me at the moment.
* Give up and rewrite the whole thing - again - in [Defold](https://www.defold.com), or Godot, or Java, or Dart+Flutter, or Kotlin+Korge, or something else.

## History

I've now written a polymorphic solitaire engine six(?) times:

First, there was a Javascript version that used SVG graphics and ran in web browsers. Game variants were configured using static lookup tables, which I thought was a good idea at the time.

Second, there was a version in Lua, using the Solar2d game engine, that made it to the Google Play store. Game variants were configured using static lookup tables, which I still thought was a good idea.

Third, there was a version in Go, using the Ebiten game engine, with help from gg/fogleman. The design was internally a mess, and the cards didn't scale, so this was abandoned. Game variants were configured using static lookup tables, which was starting to become a source of clumsiness and code smells.

Fourth, there is a version in C that uses the Raylib game engine and uses Lua to script the game variants. The design was good, but has problems with scaling cards.

Fifth, there was a rewritten version in Go, using the Ebiten game engine, with help from gg/fogleman. The design is way better than the original attempt in Go, and allows the option for scripting games.

Sixth, there is this version in Lua and LÖVE. The design is much better than the previous versions.

## Acknowledgements

Original games by Jan Wolter, David Parlett, Paul Alfille, Art Cabral, Albert Morehead, Geoffrey Mott-Smith, Zach Gage and Thomas Warfield.

Sounds by [kenney.nl](https://www.kenney.nl/assets) and Victor Vashenko.
