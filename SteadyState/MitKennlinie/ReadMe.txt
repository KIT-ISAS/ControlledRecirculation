For generating Figure 5 of the paper
List of functions:
-calcSteadyState: calculates the steady state and the TPR, TNR, J (see IV B of paper)
	-You should choose the incoming mass flow in the rows 13 and 14
	-Problem: The starting point for the fitting is chosen randomly. Hence, the fitting alorithm
	 may not always converge. If you get an error simply run the rows 71 and 72 several times (Might take
	 up to 15 tries)

-plotSteadyState: run it after calcSteadyState. Plots the results of the steady state calculations (see Fig. 5)

-plot_q: plots the approximated q_P and q_N vaules. IMPORTANT: you should always plot them since the fitting might
	might not have resulted in a valid function

-objectiveCalc_q: the objective function needed for calculating q numerically