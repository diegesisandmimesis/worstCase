//
// worstCase.h
//

#include "simpleRandomMap.h"
#ifndef SIMPLE_RANDOM_MAP_H
#error "This module requires the simpleRandomMap module."
#error "https://github.com/diegesisandmimesis/simpleRandomMap"
#error "It should be in the same parent directory as this module.  So if"
#error "worstCase is in /home/user/tads/worstCase, then"
#error "simpleRandomMap should be in /home/user/tads/simpleRandomMap ."
#else
#endif // SIMPLE_RANDOM_MAP_H

#ifndef isType
#define isType(obj, cls) ((obj != nil) && obj.ofKind(cls))
#endif // isType

#define isWorstCaseActor(obj) (isType(obj, WorstCaseActor))

#define wcRand(min, max) (rand(max - min + 1) + min)

#define WORST_CASE_H
