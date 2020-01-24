# libramvalues.ash
 Find the average value of summoning with a particular libram in Kingdom of Loathing, or automatically burn mana on the best librams available.

## Installation

Run this command in the graphical CLI:
<pre>
svn checkout https://github.com/soolar/libramvalues.ash/trunk/RELEASE/
</pre>
Will require [a recent build of KoLMafia](http://builds.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/).

## Usage

To get a readout of current libram summon values, simply enter `libramvalues` in the gCLI.

In order to actually use the script to burn mana on librams, I recommend creating an alias
by entering the following in the gCLI:
<pre>
alias libramburn => ashq import<libramvalue.ash> libram_burn_down_to(0.1 * my_maxmp())
</pre>
Then  you can simply enter `libramburn` in the gCLI whenever you want to burn mana on librams.

You can adjust the above alias as you see fit, it current burns down to 10% of you max mp.
If you want to burn down to a set amount of MP instead, just replace `0.1 * my_maxmp()` with
`1000`, for example.

You can also add a call to `libramburn` as an unconditional trigger in a mood to automatically
burn mp on optimal libram summoning as you adventure.
