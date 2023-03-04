* Encoding: UTF-8.

DATASET ACTIVATE DataSet3.
RECODE pplquit quitting stressfu (1=5) (2=4) (3=3) (4=2) (5=1) (9=Copy) INTO pplquit_r quitting_r 
    stressfu_r.
VARIABLE LABELS  pplquit_r 'People on the MBA dont think often about quitting' /quitting_r 'I '+
    'dont think about quitting' /stressfu_r 'MBA stress is managemble'.
EXECUTE.


COMPUTE ssupport=pplquit_r+quitting_r+enjoy+relsfac+support+stressfu_r+interfer.
VARIABLE LABELS  ssupport 'Summated Social support '.
EXECUTE.


RELIABILITY
  /VARIABLES=stressfu_r quitting_r pplquit_r interfer support relsfac enjoy
  /SCALE('Sotial Support Scale') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL CORR.

RELIABILITY
  /VARIABLES=quitting_r pplquit_r enjoy relsfac support stressfu_r interfer
  /SCALE('Sotial Support Scale') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL CORR.
