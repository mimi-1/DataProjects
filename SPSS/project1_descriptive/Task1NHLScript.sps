* Encoding: UTF-8.

 * Open file

GET
  FILE='C:\Humber\BIA\Data Analytics Tools\Assignment1\TO SUBMIT\MarynaKhatnyuk_Hockey Players -Salary Survey.sav'.
DATASET NAME DataSet1 WINDOW=FRONT.


 * Examin data

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=Age SalaryAdj Height Weight
  /STATISTICS=MEAN STDDEV MIN MAX.

EXAMINE VARIABLES=Age SalaryAdj Height Weight 
  /COMPARE VARIABLE
  /PLOT=BOXPLOT
  /STATISTICS=NONE
  /NOTOTAL
  /MISSING=LISTWISE.


 * trim and stipe quatation marks 

STRING Birth_County_Trimmed (A18) .
COMPUTE  Birth_County_Trimmed  = CHAR.SUBSTR(Birth_Country,CHAR.INDEX (Birth_Country,'"')+1,CHAR.RINDEX (Birth_Country,'"') - CHAR.INDEX (Birth_Country,'"') -1).
EXECUTE.


STRING Position_Trimmed (A1) .
COMPUTE  Position_Trimmed  = CHAR.SUBSTR(Position,CHAR.INDEX (Position,'"')+1,1).
EXECUTE.

 * Task1 a
 * Crearte a filter  for Canadian-born players

COMPUTE filter_$=(Birth_County_Trimmed='Canada' ).
VARIABLE LABELS filter_$ "Birth_County_Trimmed='Canada'  (FILTER)".
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


* Chart Builder. - bargraph

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Birthmonth COUNT()[name="COUNT"] MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Birthmonth=col(source(s), name("Birthmonth"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  GUIDE: axis(dim(1), label("Month of birth"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: text.title(label("Simple Bar Count of Month of birth"))
  SCALE: cat(dim(1), include("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval(position(Birthmonth*COUNT), shape.interior(shape.square))
END GPL.



FILTER OFF.
USE ALL.
EXECUTE.

 * Average salary  bar graph by position for all countries

USE ALL.
COMPUTE filter_$=(Position_Trimmed<> ".").
VARIABLE LABELS filter_$ 'Position_Trimmed<> "." (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Position_Trimmed MEANCI(SalaryAdj, 
    95)[name="MEAN_SalaryAdj" LOW="MEAN_SalaryAdj_LOW" HIGH="MEAN_SalaryAdj_HIGH"] MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Position_Trimmed=col(source(s), name("Position_Trimmed"), unit.category())
  DATA: MEAN_SalaryAdj=col(source(s), name("MEAN_SalaryAdj"))
  DATA: LOW=col(source(s), name("MEAN_SalaryAdj_LOW"))
  DATA: HIGH=col(source(s), name("MEAN_SalaryAdj_HIGH"))
  GUIDE: axis(dim(1), label("Position_Trimmed"))
  GUIDE: axis(dim(2), label("Mean Salary Adjusted"))
  GUIDE: text.title(label("Simple Bar Mean of Salary Adjusted by Position_Trimmed"))
  GUIDE: text.footnote(label("Error Bars: 95% CI"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval(position(Position_Trimmed*MEAN_SalaryAdj), shape.interior(shape.square))
  ELEMENT: interval(position(region.spread.range(Position_Trimmed*(LOW+HIGH))), 
    shape.interior(shape.ibeam))
END GPL.

 * ===============================
c)	Are Canadian born players, on average, paid higher than players born in other countries?


RECODE Birth_County_Trimmed ('Canada'=1) (ELSE=0) INTO Canadian.
EXECUTE.


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Canadian SalaryAdj MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Canadian=col(source(s), name("Canadian"), unit.category())
  DATA: SalaryAdj=col(source(s), name("SalaryAdj"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Canadian"))
  GUIDE: axis(dim(2), label("Salary Adjusted"))
  GUIDE: text.title(label("Simple Boxplot of Salary Adjusted by Canadian"))
  SCALE: cat(dim(1), include("0", "1"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Canadian*SalaryAdj)), label(id))
END GPL.

 * Calculating mean 

MEANS TABLES=SalaryAdj BY Canadian
  /CELLS=MEAN COUNT STDDEV.



* Chart Builder.- line graph of means for candain-born and not Canadian-born players.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time MEAN(SalaryAdj)[name="MEAN_SalaryAdj"] Canadian 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: MEAN_SalaryAdj=col(source(s), name("MEAN_SalaryAdj"))
  DATA: Canadian=col(source(s), name("Canadian"), unit.category())
  GUIDE: axis(dim(1), label("Year of survey"))
  GUIDE: axis(dim(2), label("Mean Salary Adjusted"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Canadian"))
  GUIDE: text.title(label("Multiple Line Mean of Salary Adjusted by Year of survey by Canadian"))
  SCALE: cat(dim(1), include("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"
, "12", "13", "14", "15", "16", "17"))
  SCALE: linear(dim(2), include(0))
  SCALE: cat(aesthetic(aesthetic.color.interior), include(
"0", "1"))
  ELEMENT: line(position(Time*MEAN_SalaryAdj), color.interior(Canadian), missing.wings())
END GPL.


* * Chart Builder.- line graph of medians for candain-born and not Canadian-born players.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time MEDIAN(SalaryAdj)[name="MEDIAN_SalaryAdj"] 
    Canadian MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: MEDIAN_SalaryAdj=col(source(s), name("MEDIAN_SalaryAdj"))
  DATA: Canadian=col(source(s), name("Canadian"), unit.category())
  GUIDE: axis(dim(1), label("Year of survey"))
  GUIDE: axis(dim(2), label("Median Salary Adjusted"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Canadian"))
  GUIDE: text.title(label("Multiple Line Median of Salary Adjusted by Year of survey by Canadian"))
  SCALE: cat(dim(1), include("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"
, "12", "13", "14", "15", "16", "17"))
  SCALE: linear(dim(2), include(0))
  SCALE: cat(aesthetic(aesthetic.color.interior), include(
"0", "1"))
  ELEMENT: line(position(Time*MEDIAN_SalaryAdj), color.interior(Canadian), missing.wings())
END GPL.


 * ==========================
NORMALITY TEST.

 * Filter for only one season 

USE ALL.
COMPUTE filter_$=(Time=17).
VARIABLE LABELS filter_$ 'Time=17 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

 * Normality test.
EXAMINE VARIABLES=SalaryAdj
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES EXTREME
  /CINTERVAL 95
  /MISSING PAIRWISE
  /NOTOTAL.







