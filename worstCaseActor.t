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
		<<spellIntOrdinal(actorNumber)>> person you'd turn to
		with a problem. "
	isProperName = true

	actorNumber = nil

	isHer = nil
	isHim = nil

	// Assign the actor number, pick a random pronoun.
	_initWorstCaseActor() {
		actorNumber = worstCase.worstCaseActors.length() + 1;
		if(wcRand(1, 100) <= 50)
			isHer = true;
		else
			isHim = true;
	}

	// Pick a random name based on our pronoun.
	_initWorstCaseName() {
		local n;

		if(isHer)
			n = _isHerNames[worstCase._worstCaseActorsIsHer + 1];
		else
			n = _isHimNames[worstCase._worstCaseActorsIsHim + 1];

		name = n;
		cmdDict.addWord(self, n.toLower(), &noun);
	}

	_initWorstCaseAgenda() {
		local g;

		g = new WorstCaseAgenda();
		addToAgenda(g);

		// IMPORTANT:  needed for AgendaItem.getActor().
		g.location = self;
	}

	initializeWorstCaseActor() {
		_initWorstCaseActor();
		_initWorstCaseName();
		_initWorstCaseAgenda();

		// Add ourselves to the main actor list.
		worstCase.addWorstCaseActor(self);
	}
;

class WorstCaseAgenda: AgendaItem
	initiallyActive = true
	isReady = true

	lastRoom = nil		// previous room we were in
	targetActor = nil	// actor we're looking for

	// Pick a random actor to look for.
	pickTarget() {
		local a, i;

		if((a = getActor()) == nil) return(nil);

		i = nil;

		while((i == nil) || (i == a.actorNumber))
			i = wcRand(1, worstCase.worstCaseActors.length());

		targetActor = worstCase.worstCaseActors[i];

		return(true);
	}

	getTargetRoom() {
		return(targetActor ? targetActor.getOutermostRoom()
			: nil);
	}

	invokeItem() {
		local a, d, l, rm0, rm1;

		// Base chance of doing nothing 25% of the time.
		if(wcRand(1, 100) <= 25) return;

		// Make sure we can determine where we are.
		if((a = getActor()) == nil) return;
		if((rm0 = a.getOutermostRoom()) == nil) return;

		// Pick someone to follow if we're not already following
		// someone.
		if(targetActor == nil) pickTarget();

		// Make sure we know where we want to go.
		if((rm1 = getTargetRoom()) == nil) return;

		// If we're already there, nothing to do.
		if(rm0 == rm1) return;

		// Get the path to the target room.
		l = worstCase.findPath(a, rm0, rm1);
		if((l == nil) || (l.length < 2)) return;

		// If we want to return to the room we just left there's
		// a 50/50 chance we'll stay put instead.  This is to
		// damp oscillations where everybody is chasing each other
		// back and forth between two rooms.
		if((l[2] == lastRoom) && (wcRand(1, 2) == 1))
			return;

		// Figure out which direction we need to head in.
		if((d = rm0.getConnectorTo(l[2], a)) == nil) return;

		// Remember where we were this turn.
		lastRoom = rm0;

		newActorAction(a, TravelVia, d);
	}
;
