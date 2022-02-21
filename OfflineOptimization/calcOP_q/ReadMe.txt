Calculates the optimal control values and the improvement of an objective function for different incoming mass flows 
(see Figure offlineOpt.pdf in folder figures for an example)
Needs: Folder "Kennlinie"
Functions:
-calcOP: calculates the increase of an objective function for different operation points concerning the incomming mass flow r
-displayOP: called by calcOP; displays the grid spanned by rP and rN
-nonlinconOP: stores the nonlinearity constraints given by the state dynamics
-objectiveOP: stores the two implemented objectives
