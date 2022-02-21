Stores Kennlinie

functions:
-epsilonSeparation: calculates TPR out of qP and qN (mass flow on the first transport medium)
-zetaSeparation: calculates TNR out of qP and qN (mass flow on the first transport medium)
-calcY: calculates y (mass flows on the second transport mediums) out of qP and qN by calling epsilonSeparation and zetaSeparation
-...Sym: same functions as above but can deal with symbolic inputs
