#charset "us-ascii"
//
// singleTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the worstCase library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f singleTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "worstCase.h"

versionInfo: GameID
        name = 'worstCase Library Demo Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the worstCase library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the worstCase library.
		<.p>
		Consult the README.txt document distributed with the library
		source for a quick summary of how to use the library in your
		own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;
gameMain: GameMainDef
	initialPlayerChar = me
	newGame() {
		local rm;

		rm = worstCase.getRandomRoom();
		if(rm)
			initialPlayerChar.moveInto(rm);
		inherited();
	}
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;

modify worstCase
	// Only generate one zone (a 1x1 zone map).
	zoneWidth = 1
;

modify WorstCaseMapGenerator
	// Make a 3x3 maze instead of a 10x10 one.
	mapWidth = 3
;
