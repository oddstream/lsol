# Minimal Polymorphic Solitaire in Lua and LÖVE

Towards a polymorphic solitaire engine in [Lua](https://lua.org/)+[LÖVE](https://love2d.org/).

![Screenshot](https://github.com/oddstream/gosol/blob/7152668f4b5053a1d438981e9d4564624616da6a/screenshots/Simple%20Simon.png)

PLay it by downlaoding/installing the LÖVE runtime and typing 'love lsol.love'. It's tested on Linux, Windows and Android.

## Variants

It currently knows how to play:

♥ Accordian ♥ Agnes Bernauer ♥ Agnes Sorel ♥ Alhambra ♥ American Toad ♥ American Westcliff ♥ Assembly ♥ Athena ♥ Australian ♥ Baker's Dozen ♥ Baker's Dozen (Wide) ♥ Baker's Game ♥ Baker's Game Relaxed ♥ Beleaguered Castle ♥ Bisley ♥ Black Hole ♥ Blockade ♥ Canfield ♥ Classic Westcliff ♥ Crimean ♥ Duchess ♥ Easthaven ♥ Eight Off ♥ Eight Off Relaxed ♥ Flat Castle ♥ Forty Thieves ♥ Forty and Eight ♥ Freecell ♥ Gate ♥ Josephine ♥ Klondike ♥ Klondike (Turn Three) ♥ Limited ♥ Little Spider ♥ Lucas ♥ Martha ♥ Penguin ♥ Rainbow Canfield ♥ Red and Black ♥ Rosamund's Bower ♥ Russian ♥ Scorpion ♥ Sea Haven Towers ♥ Simple Simon ♥ Spider ♥ Spider One Suit ♥ Spider Two Suits ♥ Storehouse Canfield ♥ Thirteens ♥ Thoughtful ♥ Tri Peaks ♥ Ukrainian ♥ Wasp ♥ Yukon ♥ Yukon Cells ♥ Yukon Relaxed

Variants are added when the whim takes me, or when some aspect of the engine needs testing/extending, or when someone asks.

Some variants have been tried and discarded as being a bit silly, or just too hard:

* Giant
* King Albert
* Raglan

Some will never make it here because they are just poor games:

* Golf
* Pyramid (or most other card matching variants)

![Screenshot](https://github.com/oddstream/gosol/blob/7152668f4b5053a1d438981e9d4564624616da6a/screenshots/Australian.png)

## Other features

* Permissive card moves. If you want to move a card from here to there, go ahead and do it. If that move is not allowed by the current rules, the game will put the cards back *and explain why that move is not allowed*.
* Unlimited undo, without penalty. Also, you can restart a deal without penalty.
* Bookmarking positions (really good for puzzle-style games like Freecell or Simple Simon).
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
changing the screen/baize background,
keeping an arbitrary score,
distracting graphics on the screen.

The user interface tries to stick to the Material Design guidelines, and so is minimal and tactile.
I looked at a lot of the other solitaire websites and apps out there, and think how distracting some of them are. Features seem to have been added because the developers thought they were cool; they never seem to have stopped to consider that just because they *could* implement a feature, that they *should*.

### Sometimes the cards are really huge or really tiny

Either resize your browser/desktop window (if using scalable cards) or change the settings to fixed size cards.

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
* 1 - one-color cards
* 2 - two-color cards (black and red)
* 4 - four-color cards (black, red, dark orange and indigo)

### What about scores?

Nope, the software doesn't keep an arbitary score. Too confusing. Just the number of wins, number of moves, the average 'completeness percentage' and your winning streak (streaks are great).
A game isn't counted until you move a card.
Thereafter, if you ask for a new deal or switch to a different variant, that counts as a loss.

You can cheat the score system by restarting a deal and then asking for a new deal.

'Completeness percentage' is calculated from the number of unsorted pairs of cards in all the piles.

### Odd features

You can restart a deal without penalty; it's not cheating, because you could just set a bookmark at the start of a game and return to that position.

You cannot move cards from a foundation pile. Most sources I've read explicity ban moves from the foundations, so I've implemented a blanket ban. There's always undo, if you've got into a bad situation.

Single-tapping a card will not send that card to an empty tableau pile. Empty piles are too precious to be so casually used up.

Movable cards are not highlighted. For the longest time, I thought that highlighting movable cards was a neat feature, but I now realize that this feature ruins the essence of most games. In trying to replicate and assist the feeling of playing with real cards, this feature is a step too far.

## What's with the discard piles?

Some games, like Spider or Simple Simon, have discard piles instead of foundations. These are optional piles for you to place completed sets of cards into, if you wish to clear some space in the tableaux.

Most other solitaire implementations just have foundation piles that fulfill this role.

### What about a timer?

Nope, there isn't one of those. Too stressful.
Solitaire is also called *patience*; it's hard to feel patient when you're pressured by a clock.

### What's with the settings?

#### Power moves

Some variants (eg Freecell or Forty Thieves) only allow you to move one card at a time. Moving several cards between piles requires you to move them, one at a time, via an empty pile or cell. Enabling power moves automates this, allowing multi-card moves between piles. The number of cards you can move is calculated from the number of empty piles and cells (if any).

#### Mirror baize

For left-handed players on mobile devices.

#### Mute sounds

So you can, for example, listen to an audio book while playing.

### Is the game rigged?

No. The cards are shuffled randomly using a Fisher-Yates shuffle
driven by a Park-Miller pseudo random number generator,
which is in itself seeded by a random number. This mechanism was tested and analysed to make sure it produced an even distribution of shuffled cards.

There are 80658175170943878571660636856403766975289505440883277824000000000000
possible deals of a pack of 52 playing cards; you're never going to play the same game twice, nor indeed play the same game
that anyone else ever has, or ever will.

### Any hints and tips?

* For games that start with face down cards (like Klondike or Yukon) the priority is to get the face down cards turned over.
* For games that start with a block of cards in the tableau and only allow single cards to be moved (like Forty Thieves), the priority is usually to open up some space (create empty tableaux piles) to allow you to juggle cards around.
* For Forty Thieves-style games, the *other* priority is to minimize the number of cards in the waste pile.
* For puzzle-type games (like Baker's Dozen, Freecell, Simple Simon), take your time and think ahead.
* For games with reshuffles (like Cruel and Perseverance) you need to anticipate the effects of the reshuffle.
* Use undo and bookmark. Undo isn't cheating; it's improvising, adapting and overcoming.

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

## TODO

* Get it working on iOS. But, I don't have a Macintosh and am reluctant to pay Apple the annual App Store fee, and jump through their hoops. If you want to do this, let me know and we'll collaborate.
* I'd like it to have an inter-user high scores table, but the Google Play games services interface and setup is inpenetrable to me at the moment.
* Give up and rewrite the whole thing in [Defold](https://www.defold.com), or Dart+Flutter, or Kotlin+Korge, or something else.

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
