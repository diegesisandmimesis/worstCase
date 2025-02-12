#charset "us-ascii"
//
// worstCaseActor.t
//
#include <adv3.h>
#include <en_us.h>

#include "worstCase.h"

// Generic actor for our gameworld.  This all started out with 
class WorstCaseActor: Person
	desc = "{You dobj/She} look{s} like the
		<<spellIntOrdinary(actorNumber)>> person you'd turn to
		with a problem. "
	isProperName = true

	actorNumber = nil

	isHer = nil
	isHim = nil

	initializeWorstCaseActor() {
		local n;

		actorNumber = gameMain.worstCaseActors.length() + 1;
		if((rand(100) + 1) <= 50)
			isHer = true;
		else
			isHim = true;

		if(isHer)
			n = _isHerNames[_worstCaseActorsIsHer];
		else
			n = _isHimNames[_worstCaseActorsIsHim];

		name = n;
		cmdDict.addWord(self, n.toLower(), &noun);

		gameMain.addWorstCaseActor(self);
	}
;
