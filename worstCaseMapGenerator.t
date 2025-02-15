#charset "us-ascii"
//
// worstCaseMapGenerator.t
//
//	SimpleRandomMapGenerator subclass.  Used to generate a square
//	random maze.
//
//
#include <adv3.h>
#include <en_us.h>

#include "worstCase.h"

#ifdef WORST_CASE

// We use the braided map generator in the theory that this is probably
// worst for pathfinding (because there are a lot of alternate paths,
// as opposed to an algorithm that produces a lot of dead ends.
class WorstCaseMapGenerator: SimpleRandomMapGeneratorBraid
	movePlayer = nil		// don't put the player in this map
	roomClass = WorstCaseRoom	// class for created room instances

	zoneNumber = nil		// internally generated zone ID

	// Method to populate the zone with actors.
	addWorstCaseActors() {
		local a, i, rm;

		// Add an actor to each room.
		for(i = 1; i <= _mapSize; i++) {
			if((rm = _getRoom(i)) == nil) return(nil);

			a = new WorstCaseActor();

			// IMPORTANT:  Needed by adv3.
			a.initializeActor();

			// Module-specific init.
			a.initializeWorstCaseActor();

			// Put the actor in the room.
			a.moveInto(rm);
		}

		return(true);
	}
;

#endif // WORST_CASE
