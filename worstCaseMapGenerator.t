#charset "us-ascii"
//
// worstCaseMapGenerator.t
//
#include <adv3.h>
#include <en_us.h>

#include "worstCase.h"

class WorstCaseRoom: SimpleRandomMapRoom
	desc = "This is the room <<worstCaseRoomName()>>. "

	worstCaseRoomName() {
		return('room <<toString(simpleRandomMapID)>> in
			<<zoneName()>>');
	}

	// Returns the zone name as a single-quoted string.
	zoneName() {
		return('zone
			#<<toString(simpleRandomMapGenerator.zoneNumber)>>');
	}

	// Returns the connector from this room to the given room, for the
	// given actor.
	getConnectorTo(rm, actor) {
		local c, d, dst, i;

		for(i = 1; i <= Direction.allDirections.length; i++) {
			d = Direction.allDirections[i];
			if((c = getTravelConnector(d, actor)) == nil)
				continue;
			if(!c.isConnectorApparent(self, actor))
				continue;
			if((dst = c.getDestination(self, actor)) == nil)
				continue;
			if(dst != rm)
				continue;
			return(c);
		}

		return(nil);
	}
;

class WorstCaseMapGenerator: SimpleRandomMapGeneratorBraid
	movePlayer = nil
	roomClass = WorstCaseRoom

	zoneNumber = nil

	addWorstCaseActors() {
		local a, i, rm;

		for(i = 1; i <= _mapSize; i++) {
			if((rm = _getRoom(i)) == nil) return(nil);

			a = new WorstCaseActor();

			// IMPORTANT:  Needed by adv3.
			a.initializeActor();

			// Module-specific init.
			a.initializeWorstCaseActor();

			a.moveInto(rm);
		}

		return(true);
	}
;
