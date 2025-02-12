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

worseCasePreinit: PreinitObject
	// The total map will be this many zones by this many zones.  So
	// with zoneWidth = 2, there will be 2 x 2 zones, or 4 zones total.
	zoneWidth = 2

	zones = perInstance(new Vector())

	execute() {
		constructMap();
	}

	constructMap() {
		local i, r;

		for(i = 1; i <= (zoneWidth * zoneWidth); i++) {
			zones.append(new WorstCaseMapGenerator());
		}
	}
;

modify gameMain
	worseCaseActors = perInstance(new Vector())

	_worstCaseActorsIsHer = 0
	_worstCaseActorsIsHim = 0

	addWorseCaseActor(a) {
		if(!isWorstCaseActor(a)) return(nil);
		worseCaseActors.appendUnique(a);
		if(a.isHer)
			_worstCaseActorsIsHer += 1;
		else
			_worstCaseActorsIsHim += 1;
	}
;
