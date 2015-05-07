
# This file reads files that are generated by the OPENCOG_ADD_ATOM_TYPES
# macro so they can be imported using:
#
# from type_constructors import *
#
# This imports all the python wrappers for atom creation.
#

from opencog.atomspace import AtomSpace, types

atomspace = None
def set_type_ctor_atomspace(new_atomspace):
    global atomspace
    atomspace = new_atomspace

# include "opencog/atomspace/core_types.pyx"
include "opencog/embodiment/AtomSpaceExtensions/embodiment_types.pyx"
include "opencog/nlp/types/nlp_types.pyx"
include "opencog/spacetime/spacetime_types.pyx"
include "opencog/dynamics/attention/attention_types.pyx"
