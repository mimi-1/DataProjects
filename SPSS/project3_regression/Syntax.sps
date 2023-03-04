* Encoding: UTF-8.
RECODE Birthmonth (1=1) (2=1) (3=1) (ELSE=0) INTO Q1.

RECODE Birthmonth (4=1) (5=1) (6=1) (ELSE=0) INTO Q2.
RECODE Birthmonth (7=1) (8=1) (9=1) (ELSE=0) INTO Q3.
RECODE Birthmonth (10=1) (11=1) (12=1) (ELSE=0) INTO Q4.


RECODE Birth_Country ('  "Canada"'=1) (ELSE=0) INTO Canadian. 
 
RECODE Position ('  "C"'=1) (ELSE=0) INTO Center. 
 
RECODE Position ('  "R"'=1) (ELSE=0) INTO Right. 
VARIABLE LABELS  Right 'Right Wing'.

RECODE Position ('  "L"'=1) (ELSE=0) INTO Left. 
VARIABLE LABELS  Left 'Left Wing'. 

RECODE Position ('  "D"'=1) (ELSE=0) INTO Defence. 

RECODE Position ('  "G"'=1) (ELSE=0) INTO Goalie.

RECODE Position ('  "F"'=1) (ELSE=0) INTO Forward.

RECODE Position ('  "W"'=1) (ELSE=0) INTO Winger.
 
Execute.

*Regression analysis base level - last quater Q1 for birthmonth
* Forward - base level category for  position 

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT SalaryAdj
  /METHOD=ENTER Time Q2 Q3 Q4 Age Height Weight Seasoninleague Captain Canadian Center Right Left
    Defense Winger Goalie
  /SCATTERPLOT=(SalaryAdj ,*ZRESID) (SalaryAdj ,*ZRESID)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).



