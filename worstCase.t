#charset "us-ascii"
//
// worstCase.t
//
#include <adv3.h>
#include <en_us.h>

#include "worstCase.h"

// Module ID for the library
worstCaseModuleID: ModuleID {
        name = 'Worst Case Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class WorstCaseDoor: IndirectLockable, AutoClosingDoor 'door' 'door';

worstCase: PreinitObject
	// To hold all our randomly milling-about actors.
	worstCaseActors = perInstance(new Vector())

	// Boolean.  If true, the connections between zones are lockable
	// doors.
	useDoors = nil

	// When we add an actor to our list above we keep track of whether
	// they're a isHer or a isHim.  This is entirely to make it
	// easier to randomly assign names.
	_worstCaseActorsIsHer = 0
	_worstCaseActorsIsHim = 0

	// The total map will be this many zones by this many zones.  So
	// with zoneWidth = 2, there will be 2 x 2 zones, or 4 zones total.
	zoneWidth = 2

	// Vector to hold all the map generators we've created.
	zones = perInstance(new Vector())

	execute() {
		constructMap();
		connectMap();
		addActors();
	}

	// Create and run a bunch of map generators.  This generates
	// the random maze blocks.
	constructMap() {
		local i, z;

		for(i = 1; i <= (zoneWidth * zoneWidth); i++) {
			z = new WorstCaseMapGenerator();
			z.preinit();
			zones.append(z);
			z.zoneNumber = zones.length();
		}
	}

	// Connect the random mazes we created above.
	connectMap() {
		local i, j, n, z0, z1;

		for(j = 1; j <= zoneWidth; j++) {
			for(i = 1; i <= zoneWidth; i++) {
				// Get the "base" zone.
				n = i + ((j - 1) * zoneWidth);
				z0 = zones[n];

				// Don't connect east on the east edge.
				if(i < zoneWidth) {
					// Zone to the east of the base zone.
					z1 = zones[n + 1];
					_connectZonesEastWest(z0, z1);
				}

				// Don't connect north on the north edge.
				if(j < zoneWidth) {
					// Zone to the north of the base zone.
					z1 = zones[n + zoneWidth];
					_connectZonesNorthSouth(z0, z1);
				}
			}
		}
	}

	_createDoorPair(rm0, prop0, rm1, prop1) {
		local d0, d1;

		d0 = new WorstCaseDoor();
		d1 = new WorstCaseDoor();

		d1.masterObject = d0;

		d0.moveInto(rm0);
		d1.moveInto(rm1);

		d0.initializeThing();
		d1.initializeThing();

		d0.makeLocked(nil);

		rm0.(prop0) = d0;
		rm1.(prop1) = d1;
	}

	_connectRoomEastWest(rm0, rm1) {
		if(useDoors == true) {
			_createDoorPair(rm0, &east, rm1, &west);
		} else {
			rm0.east = rm1;
			rm1.west = rm0;
		}
	}

	_connectRoomNorthSouth(rm0, rm1) {
		if(useDoors == true) {
			_createDoorPair(rm0, &north, rm1, &south);
		} else {
			rm0.north = rm1;
			rm1.south = rm0;
		}
	}

	_connectZonesEastWest(z0, z1) {
		_connectRoomEastWest(
			z0._getRoom(z0.mapWidth),
			z1._getRoom(1)
		);
		_connectRoomEastWest(
			z0._getRoom(z0._mapSize),
			z1._getRoom(z1._mapSize - z1.mapWidth + 1)
		);
	}

	_connectZonesNorthSouth(z0, z1) {
		_connectRoomNorthSouth(
			z0._getRoom(z0._mapSize - z0.mapWidth + 1),
			z1._getRoom(1)
		);
		_connectRoomNorthSouth(
			z0._getRoom(z0._mapSize),
			z1._getRoom(z1.mapWidth)
		);
	}

	addActors() {
		zones.forEach({ x: x.addWorstCaseActors() });
	}

	getRandomZone() { return(zones[wcRand(1, zones.length())]); }

	getRandomRoom() {
		local z;

		if((z = getRandomZone()) == nil) return(nil);
		return(z._getRoom(wcRand(1, z._mapSize)));
	}

	addWorstCaseActor(a) {
		if(!isWorstCaseActor(a)) return(nil);
		worstCaseActors.appendUnique(a);
		if(a.isHer)
			_worstCaseActorsIsHer += 1;
		else
			_worstCaseActorsIsHim += 1;
		return(true);
	}

	findPath(actor, rm0, rm1) {
		return(roomPathFinder.findPath(actor, rm0, rm1));
	}
;
