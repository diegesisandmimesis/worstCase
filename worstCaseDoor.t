#charset "us-ascii"
//
// worstCaseDoor.t
//
//	Class for the doors when we use doors instead of bare travel
//	connectors.
//
//
#include <adv3.h>
#include <en_us.h>

#include "worstCase.h"

#ifdef WORST_CASE

class WorstCaseDoor: IndirectLockable, AutoClosingDoor 'door' 'door';

#endif // WORST_CASE
