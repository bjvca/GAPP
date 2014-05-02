* Filename: 195a_spat_temp_consistent.gms

* Using stata input files representing CBS poverty lines etc.,
* this gams file adjusts these poverty lines such that they are
* consistent across space and over time (spatial domains and years)

$ontext
This file uses:
         work\product_flex.inc
         in\price_t1.inc
         in\povline_t1_cc.inc
         work\povline_food_fix.inc
         work\price_unit_flex.inc
         work\quan_flex.inc

This file creates:
         work\qent.csv
         work\povline_food_ent.csv
         work\povline_rp_inout.csv

$offtext

SETS
 cod        year t2 (e.g. 2002) codes for products used in basket
/
$include work\product_flex.inc
/

 reg        12 spatial domains /1*12/
 r(reg)     dynamic set on spatial regions

 ptit       price table titles
/
  count      number of observations making up the price average
  price_uw5  average price
/

 qtit       quantity table titles
/
  calperg          calories per gram
  quan5            quantities in grams
  calpp            calories per person by region
  povline_f_flex5  value of flexible food bundle
/


  posquan(cod,reg)  mark positive quantities in each region
  posprice(cod,reg) mark the existence of acceptable price info in each region
  pmiss_t1(cod,reg) mark year t1 (e.g. 1996) missing prices
  chkprice(cod,reg) ensure that prices exist once all estimated
;

*****************************************************
*Work first on all regions
*********************************************************

 r(reg)=yes;

alias(reg,regq);
alias(r,rq);

SCALAR
   caltarg single level of calories to target across regions /2150/
 ;

PARAMETERS
  price_t1(cod,reg)     price information and poverty line for year t1 (e.g. 1996)
/
$include in\2001\price_t1.inc
/
  foodpov_t1(reg)       food pov line P_t1*Q_t1 ADJUSTED to hit 2150 calories
/
$include in\2001\povline_t1_cc.inc
/
  shr(cod,reg)           shares in each basket by region
  chkshr(reg)            check that the calculated shares sum to .9
  shrmiss(regq,reg)      shares missing in each region pair
  povline_food(reg)      food poverty line
  perc_chng(reg)         percent change in line
  origmiss(reg)          original share of items without price obs in year t1 (e.g. 1996)
  finmiss(reg)           final missing shares post optimization procedure
  povline_food_fix(reg)  food pov line Q_t1*P_t2 NOT adjusted to 2150 calories
 /
$include in\2001\povline_food_fix.inc
 /
 ;

Table  price(cod,reg,ptit)  price and related information
                        count   price_uw5
$include work\price_unit_flex.inc
;

Table   quan(cod,reg,qtit)   quantity and related information
                           calperg          quan5           calpp      povline_f_flex5
$include work\quan_flex.inc
;

*CA March 2009 - adjust fixed bundle line to hit 2150 calories
  loop(cod$(ord(cod) eq 1),
    povline_food_fix(reg)= povline_food_fix(reg)*2150/quan(cod,reg,'calpp');
  );

  shr(cod,reg)$quan(cod,reg,'povline_f_flex5')
                      =price(cod,reg,'price_uw5')*quan(cod,reg,'quan5')/
                       quan(cod,reg,'povline_f_flex5');

  chkshr(reg)=sum(cod,shr(cod,reg));

loop(reg,
  abort$(abs(chkshr(reg)-.9) gt .0001) "share does not sum to .9", chkshr ;
);


*turn on dynamic sets to indicate positive quantities and existence of
*price info for each region

 posprice(cod,reg)$(price(cod,reg,'price_uw5')
                      AND price(cod,reg,'count') gt 4) = yes;

 posquan(cod,reg)$quan(cod,reg,'quan5')=yes;

 pmiss_t1(cod,reg)$(NOT price_t1(cod,reg) AND posquan(cod,reg))=yes;

 display pmiss_t1;

  loop(reg,
       abort$(foodpov_t1(reg) eq 0) "missing a food poverty line", foodpov_t1;
 );

 shrmiss(regq,reg)=sum(cod$(NOT posprice(cod,reg)), shr(cod,regq));
 display shrmiss;

 origmiss(reg)=sum(cod$pmiss_t1(cod,reg), shr(cod,reg));
 display origmiss;

  povline_food(reg)=sum(cod$posquan(cod,reg),price(cod,reg,'price_uw5')*
                                           quan(cod,reg,'quan5'))/.9;

  display povline_food;


*boost values so shares sum to one;
shr(cod,reg)=shr(cod,reg)/chkshr(reg);

*fill out price matrix with maximum observed price outside of Maputo
 r(reg)=no;
 r(reg)$(ord(reg) le 10)=yes;
loop((cod,r)$(NOT posprice(cod,r) AND posquan(cod,r)),
         loop(rq,
                 price(cod,r,'price_uw5')=max(price(cod,r,'price_uw5'),
                                              price(cod,rq,'price_uw5'));
         );
);

*fill out price matrix with maximum observed price within Maputo
 r(reg)=no;
 r(reg)$(ord(reg) gt 10)=yes;
loop((cod,r)$(NOT posprice(cod,r) AND posquan(cod,r)),
         loop(rq,
                 price(cod,r,'price_uw5')=max(price(cod,r,'price_uw5'),
                                              price(cod,rq,'price_uw5'));
         );
);

*Back to r indexing all regions
 r(reg)=yes;

chkprice(cod,reg)$(NOT price(cod,reg,'price_uw5') AND posquan(cod,reg))=yes;

display 'should be an empty set', chkprice;

Variables
   z                 objective value
   q(cod,reg)        revised maximum entropy quanties in grams
   s(cod,reg)        derived maximum entropy shares
   povline(regq,reg) estimated revealed preference matrix
   povline_t1(regq)  value of estimated bundle at year t1 (e.g. 1996) prices
;


Equations
   obj              objective equation
   rev(regq,reg)    revealed preference tests
   deflin(regq,reg) define revealed preference matrix
   defshr(cod,regq) define the endogenous budget shares
   deflin_t1(reg)   define the value of the bundle at year t1 (e.g. 1996) prices
   cals(regq)       ensure that each bundle hits the calorie

;

   obj ..  z=e= sum((cod,rq)$posquan(cod,rq),
                   s(cod,rq)*log(s(cod,rq)/shr(cod,rq)));

   deflin(rq,r) .. povline(rq,r) =e= sum(cod$posquan(cod,rq),
                          q(cod,rq)*price(cod,r,'price_uw5'));

   rev(rq,r) ..    povline(r,rq)=g=povline(rq,rq);

   defshr(cod,rq)$posquan(cod,rq) ..
             povline(rq,rq)*s(cod,rq)=e= q(cod,rq)*price(cod,rq,'price_uw5');

   deflin_t1(rq) .. povline_t1(rq)*(.9-sum(cod$pmiss_t1(cod,rq),s(cod,rq))) =e=
                       sum(cod$(posquan(cod,rq) AND NOT pmiss_t1(cod,rq)),
                         q(cod,rq)*price_t1(cod,rq));

   cals(rq) .. sum(cod$posquan(cod,rq),
                    q(cod,rq)*quan(cod,rq,'calperg'))=e=.95*caltarg;

*set bounds and starting values for variables

  q.lo(cod,reg)=.00001;
  q.up(cod,reg)=inf;
  q.l(cod,reg)=quan(cod,reg,'quan5');
  q.fx(cod,reg)$(NOT posquan(cod,reg))=0;

  povline.l(regq,reg)= sum(cod$posquan(cod,regq),
                          q.l(cod,regq)*price(cod,reg,'price_uw5'));

  povline.up(regq,regq)=povline_food_fix(regq)*.9;

  display povline.l;

*print the revealed preference matrix prior to optimisation;
file povline_rp /work\povline_rp_inout.csv/;
put povline_rp;
povline_rp.pc=5;
povline_rp.nd=0;
put " ";
loop(reg,
      put reg.tl;
);
put /;
loop(regq,
     put regq.tl;
     loop(reg,
         put povline.l(regq,reg);
     );
     put /;
);
put /; put /; put /;

   s.l(cod,regq)= q.l(cod,regq)*price(cod,regq,'price_uw5')/povline.l(regq,regq);
   s.lo(cod,regq)=.0001;
   s.fx(cod,regq)$(NOT posquan(cod,regq))=0;

   povline_t1.l(reg)=1.2*foodpov_t1(reg);
   povline_t1.lo(reg)=foodpov_t1(reg);

   model revpref /obj, deflin, rev, defshr, deflin_t1, cals/;
   model revprefnotemp /obj, deflin, rev, defshr, cals/;

   revpref.holdfixed=1;

   option limrow=100;

   option nlp=conopt;

*run procedure on all regions
   r(reg)=yes;

*CAtemp
*Check without temporal conditions  ***NEED TO UNDO THIS!!!!!!!!!!!!!!!!!!!!

*   solve revpref using nlp minimizing z;

  povline.up(regq,regq)=inf;

   solve revpref using nlp minimizing z;


   abort$(revpref.modelstat ne 2) "Model did not solve properly";

   povline.l(regq,reg)$(NOT rq(regq) OR NOT r(reg))=0;
   display "this is without adjustment for calorie target or 90%", povline.l;

put /;
loop(rq,
     put rq.tl;
     loop(r,
         put povline.l(rq,r);
     );
     put /;
);
put /;


   finmiss(r)=sum(cod$pmiss_t1(cod,r),s.l(cod,r));
   display finmiss;

PARAMETERS
   qent(cod,reg)  entropy quantities with all adjustments accounted for
   povline_ent(reg) entropy line that hits calorie targets (100% food expen)
  ;
*readjust quantities to hit regional calorie target and calculate line;
   qent(cod,r)=q.l(cod,r)*quan(cod,r,'calpp')/caltarg;

   povline_ent(r)=sum(cod$posquan(cod,r),price(cod,r,'price_uw5')*
                                           qent(cod,r))/.9;

   perc_chng(r)=100*(povline_ent(r)/povline_food(r)-1);

*CA March 2009 - adjust fixed bundle line to hit 2150 calories
  loop(cod$(ord(cod) eq 1),
     povline_food_fix(reg)= povline_food_fix(reg)*quan(cod,reg,'calpp')/2150;
  );
   display perc_chng, povline_ent, povline_food;

   file res /work\qent.csv/;

   put res;
   res.pc=5;
   res.nd=6;

*recall that the basket reflects 90% of expenditure and 95% of calories";
   put "spdomain" ;
   put "product" ;
   put "quan5";
   put "qent";
   put "price";
   put "calperg";

   put /;

   loop(reg,
       loop(cod,
           put reg.tl;
           put cod.tl;
           put quan(cod,reg,'quan5');
           put qent(cod,reg);
           put price(cod,reg,'price_uw5')
           put quan(cod,reg,'calperg');
           put /;
       );
   );

   file lin /work\povline_food_ent.csv/;

   put lin;
   lin.pc=5;
*Flexible, entropy, and fixed food pov lines at 100% expenditure

   put "spdomain";
   put "flex";
   put "ent";
   put "fix";
   put /;

   loop(reg,
         put reg.tl;
         put povline_food(reg);
         put povline_ent(reg);
         put povline_food_fix(reg);
         put /;
   );
