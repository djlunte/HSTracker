#### 0.10
- *New*: Display mana curve on the deck manager
- *New*: Import decks from txt files. The deck must have the following format : "2 Mirror Image" or "2xMirror Image" or "2 CS2_027". You can also have the card name if your hearthstone locale. Caution, make sure to have only one card per line.
- *New*: Add an option to don't display in-hand cards. As soon as you draw a card, HSTracker consider it is not anymore in your deck and fade or remove the card from tracker (if no more in deck).
- *New*: Add a button at the end of a game to save your opponent's deck. Of course, it will only save the cards your opponent played.

#### 0.9
- Better font for asian languages
- *New*: Option for card count and draw chance
- Gnomish inventor transformed card is now "discarded"
- *New*: Display card on trackers hover

#### 0.8
- Complete rewrite of the log analysis using the code base from [Hearthstone-Deck-Tracker](https://github.com/Epix37/Hearthstone-Deck-Tracker)
- HSTracker now listen for Hearthstone to be active and set its "modality" according.

#### 0.7
- Card count, draw chance are now only available on trackers, also change color is available
- Gang Up is supported, added a green frame for this kind of cards
- Cards reset when "remove" option is selected

#### 0.6
- *New* : **Full support for Blackrock Mountain**
- *New* : flash the cards on draw (color editable in prefs)
- *New* : better font for asian and cyrillic languages
- *New* : name of the windows can now be fixed
- *New* : import from [HearthArena](http://www.heartharena.com)
- Better error handling in import decks
- *New* : cardcount for current deck in the Deck Manager
- *New* : shortcut to lock/unlock windows (⌘l)
- *New* : open a deck from the menu, as well as reset trackers (⌘r)
- *New* : option to show card count on a single line
- *New* : option to reset trackers on game end
- *New* : option to change HSTracker language
- Handle correctly steal, discard, tracking
- *New* : deck manager can now be close with ⌘w
- *New* : add an option to change trackers size (small, medium or big)
- *New* : add an option to toggle card count style

#### 0.5
- Correction of the message when you save a deck
- Better end game detection
- *New* : windows can be locked in the settings
- *New* : transparency of the windows can be set in the settings
- *New* : player and opponent card count windows
- *New* : card draw chance on deck hover
- *New* : deck manager images available in de, en, es, fr, pt and ru

#### 0.4
- *New* : support for OS X 10.8
- Better start and end game detection
- *New* : support for arena decks !
- *New* : add an option to remove cards instead of fade them (when you play the last)
- *New* : export decks to text files
- Better language detection
- *New* : import from [Hearthstats](https://hearthstats.net/)
- *New* : import from [Hearthhead](http://www.hearthhead.com/) (all languages available)
- *New* : import from [Hearthnews](https://hearthnews.fr/)
- Cards import optimizations
- Remove scrollbars

#### 0.3
- *New* : deck manager ! Enjoy creating and editing deck directly from the app
- Correct a bug where the app keep asking about update
- Some corrections & optimisations
- German translation
- *New* : NetDeck import

#### 0.2
- Loading screen
- Force the language detection
- HSTracker on 10.9
- Bugfixes

#### 0.1 - Initial release (2015-03-13)
- Import decks from http://www.hearthpwn.com/decks (english)
- Import decks from http://www.hearthpwn.com/deckbuilder (english)
- Import decks from http://www.hearthstone-decks.com (french)
- Display your deck and the cards you played
- Display the cards your opponent played
- Support for all Hearthstone languages
- HSTracker available in french and english
