%let pgm=utl-replicate-rows-in-a-table-based-on-a-count-column;

If a saleperson sold three watches genererate three rows each with one watch.

options validvarname=upcase;

  Three Solutions
       1. SAS
       2. R (I can understand this solution)
       3. Python (little harder to understand)
          https://tinyurl.com/a2cenh8d
          https://stackoverflow.com/questions/71293152/how-to-generate-n-rows-based-on-a-value-in-a-column-pandas-or-sql

github
https://tinyurl.com/4tvd2b7s
https://github.com/rogerjdeangelis/utl-replicate-rows-in-a-table-based-on-a-count-column

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

libname sd1 "d:/sd1";

data sd1.have;
   informat personid 2. item $8.;
   input personid item sales;
cards4;
1 WATCH  3
1 LAPTOP 1
1 LEGOS  2
2 PANTS  3
2 SHOES  1
2 HATS   1
;;;;
run;quit;

/*******************************************************************************************/
/*                                                                                         */
/* Up to 40 obs from SD1.HAVE total obs=6 02MAR2022:13:47:05                               */
/*                                                                                         */
/* Obs    PERSONID     ITEM     SALES                                                      */
/*                                                                                         */
/*  1         1       WATCH       3    ==> generate three records with 1 sale each         */
/*  2         1       LAPTOP      1                                                        */
/*  3         1       LEGOS       2                                                        */
/*  4         2       PANTS       3                                                        */
/*  5         2       SHOES       1                                                        */
/*  6         2       HATS        1                                                        */
/*                                                                                         */
/*******************************************************************************************/

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/*******************************************************************************************/
/*                                                                                         */
/* Up to 40 obs WORK.WANT_SAS total obs=11 02MAR2022:13:44:40                              */
/*                                                                                         */
/* Obs    PERSONID     ITEM     SALES                                                      */
/*                                                                                         */
/*   1        1       WATCH       1    * generated from 1st input record                   */
/*   2        1       WATCH       1                                                        */
/*   3        1       WATCH       1                                                        */
/*                                                                                         */
/*   4        1       LAPTOP      1                                                        */
/*   5        1       LEGOS       1                                                        */
/*   6        1       LEGOS       1                                                        */
/*   7        2       PANTS       1                                                        */
/*   8        2       PANTS       1                                                        */
/*   9        2       PANTS       1                                                        */
/*  10        2       SHOES       1                                                        */
/*  11        2       HATS        1                                                        */
/*                                                                                         */
/*******************************************************************************************/

/*         _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| `_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
 ___  __ _ ___
/ __|/ _` / __|
\__ \ (_| \__ \
|___/\__,_|___/

*/

data want_sas;

  retain personid item sales;

  set sd1.have;
  cnt=sales;

  do  i = 1 to cnt;
     sales=1;
     output;
  end;

  drop i cnt;
run;quit;

/*___
|  _ \
| |_) |
|  _ <
|_| \_\

*/

%utlfkil(d:/xpt/want_r.xpt);

%utl_submit_r64('
  library(haven);
  library(SASxport);
  library(data.table);
  have<-as.data.table(read_sas("d:/sd1/have.sas7bdat"));
  want_r<-have[rep(seq(1, nrow(have)), have$SALES)];
  want_r$SALES<-1;
  want_r;
  write.xport(want_r,file="d:/xpt/want_r.xpt");
  ');

libname xpt xport "d:/xpt/want_r.xpt";

proc print data=xpt.want_r;
run;quit;

/*           _   _
 _ __  _   _| |_| |__   ___  _ __
| `_ \| | | | __| `_ \ / _ \| `_ \
| |_) | |_| | |_| | | | (_) | | | |
| .__/ \__, |\__|_| |_|\___/|_| |_|
|_|    |___/
*/

%utlfkil(d:/xpt/want_py.xpt);

%utl_submit_py64_39("
import pandas as pd;
import xport;
import xport.v56;
import pyreadstat;
have, meta = pyreadstat.read_sas7bdat('d:/sd1/have.sas7bdat');
want_py = (have.loc[have.index.repeat(have['SALES'])];
.        .drop('SALES', axis=1);
.        .assign(SALES=1);
.        .reset_index(drop=True));
print (want_py);
ds = xport.Dataset(want_py, name='want_py');
with open('d:/xpt/want_py.xpt', 'wb') as f: xport.v56.dump(ds, f);
");

libname xpt xport "d:/xpt/want_py.xpt";

proc print data=xpt.want_py;
run;quit;





















