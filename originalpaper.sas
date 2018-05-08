/* LOCAL MODIFICATIONS */

%let gpath = H:\GitHub\srosanba\sas-consort-sgplot;
ods listing gpath="&gpath";


/* BEGIN ORIGINAL PROGRAM */

/**
 * Create some vertices with x coordinate [0,100], and y [0,200].
 */
data vertices;
   input vId  vX  vY;
   datalines;
 0  30  200
 1  30  190
 2  30  180
 3  50  180
 4  30  170
 5  30  160
 6  20  150
 7  30  150
 8  40  150
 9  60  150
10  80  150
11  20  140
12  40  140
13  60  140
14  80  140
15  20  100
16  40  100
17  60  100
18  80  100
19  20   90
20  40   90
21  60   90
22  80   90
23  20   50
24  40   50
25  60   50
26  80   50
27  20   40
28  40   40
29  60   40
30  80   40
;
run;

/**
 * Define links using the above vertices. Each link is assigned a separate
 * group value.
 */
data links;
   input linkId  v1  v2  v3  v4;
   datalines;
 1   1   4   .    .
 2   2   3   .    .
 3   5   7   6   11
 4   7   8  12    .
 5   8   9  13    .
 6   9  10  14    .
 7  15  19   .    .
 8  16  20   .    .
 9  17  21   .    .
10  18  22   .    .
11  23  27   .    .
12  24  28   .    .
13  25  29   .    .
14  26  30   .    .
;
run;

/**
 * Find the coordinates for the link vertices from the vertices data set
 * and create data for a series plot.
 */
data linksCoord;
   keep linkId vX vY;
   array vertices{4} v1-v4;
   set links;

   /* Create a hash object from the vertices data set */
   if _n_ = 1 then do;
      declare hash vertCoords(dataset:'vertices');
      vertCoords.defineKey('vId');
      vertCoords.defineData('vX','vY');
      vertCoords.defineDone();
      call missing(vX, vY); /* avoid NOTE about uninitialized vars */
      end;

      /* Set vertex coordinates */
      do idx = 1 to dim(vertices); /* iterate over vertices{} */
         if vertices{idx} ne . then do;
            vId = vertices{idx};
            if vertCoords.find() eq 0 then
               output;
         end;
      end;
run;

/**
 * Empty Box Data
 */
data emptyBoxes;
   input epId xEp yEp;
   datalines;
 1  15  200
 1  45  200
 1  45  190
 1  15  190
 2  15  170
 2  45  170
 2  45  160
 2  15  160
 3  50  195
 3  80  195
 3  80  165
 3  50  165
 4  11  140
 4  29  140
 4  29  100
 4  11  100
 5  31  140
 5  49  140
 5  49  100
 5  31  100
 6  51  140
 6  69  140
 6  69  100
 6  51  100
 7  71  140
 7  89  140
 7  89  100
 7  71  100
 8  11   90
 8  29   90
 8  29   50
 8  11   50
 9  31   90
 9  49   90
 9  49   50
 9  31   50
10  51   90
10  69   90
10  69   50
10  51   50
11  71   90
11  89   90
11  89   50
11  71   50
12  11   40
12  29   40
12  29    0
12  11    0
13  31   40
13  49   40
13  49    0
13  31    0
14  51   40
14  69   40
14  69    0
14  51    0
15  71   40
15  89   40
15  89    0
15  71    0
;
run;

/**
 * Filled Box Data
 */
data filledBoxes;
   input fpId xFp yFp;
   datalines;
1   4  195
1   9  195
1   9  155
1   4  155
2   4  140
2   9  140
2   9  100
2   4  100
3   4   90
3   9   90
3   9   50
3   4   50
4   4   40
4   9   40
4   9    0
4   4    0
;
run;

/**
 * Horizontal text, center aligned.
 */
data hTextC;
   input xHtc   yHtc  htextc $10-75;
   datalines;
30  195   Assessed for Eligibility (n=445)
30  165   Randomized (n=406)
;
run;

/**
 * Horizontal text, left aligned. With help from Warren Kuhfeld.
 */
data hTextL(drop=type n1-n5 arm);
   length type $12 hTextL $125;
   input xHtl yHtl type $ arm $ 20-27 n1-n5;
   infile datalines missover;
   select (type);
      when ('Enrollment')
         hTextL = cats('Excluded (n=', n1,
            ').* Not meeting inclusion criteria (n=', n2,
            ').* Declined to participate (n=', n3,
            ').* Other reasons (n=', n4, ')'
            );
      when ('Allocation')
         hTextL = cats('Allocated to ', arm, '. (n=', n1,
            ').* Received allocated.  drug (n=', n2,
            ').* Did not receive.  allocated drug (n=', n3, ')'
            );
      when ('Follow-Up')
         hTextL = cats('Discontinued drug. (n=', n1,
            ') due to:.* Adverse events (n=', n2,
            ').* Withdrawn (n=', n3,
            ').* Death (n=', n4, 
            ').* Other (n=', n5, ')'
            );
      when ('Analysis')
         hTextL = cats('FAS (n=', n1,
            ').* Excluded from FAS. (n=', n2, 
            '). .* Safety set (n=', n3,
            ').* Excluded from SS (n=', n4, ')'
            );
      otherwise;
   end;

   datalines;
50 180 Enrollment          39 22 14 3
11 120 Allocation  Placebo 95 90 5
31 120 Allocation  ARM 1   103 103 0
51 120 Allocation  ARM 2   105 98 7
71 120 Allocation  ARM 3   102 101 1
11  70 Follow-Up           10 2 4 0 4
31  70 Follow-Up           7 3 2 1 1
51  70 Follow-Up           11 5 2 1 3
71  70 Follow-Up           16 7 6 2 1
11  20 Analysis            89 7 90 6
31  20 Analysis            100 3 103 0
51  20 Analysis            98 7 98 7
71  20 Analysis            92 10 101 1
;
run;

/**
  * Vertical text for stage labels
  */
data vText;
   input xVt yVt vtext $10-75;
   datalines;
6  175   Enrollment
6  120   Allocation
6   70   Follow-Up
6   20   Analysis
;
run;

/**
 * Combine all graph data
 */
data consort;
   merge linksCoord emptyBoxes filledBoxes hTextC hTextL vText;
run;

%let dpi=200;
ods listing image_dpi=&dpi;

/**
 * Draw the Consort Diagram
 */
ods graphics / reset width=6in height=4in imagename='originalpaper';
title 'Consort Diagram for a 4 Arm Study';

proc sgplot data=consort noborder noautolegend;
   /* lines connecting boxes, including arrows */
   series x=vX y=vY / group=linkid lineattrs=graphdatadefault
      arrowheadpos=end arrowheadshape=barbed arrowheadscale=0.4;
   /* Empty boxes */
   polygon id=epid x=xEp y=yEp;
   /* Filled boxes */
   polygon id=fpid x=xFp y=yFp / fill outline 
      fillattrs=(color=STGB) lineattrs=(color=VLIGB);
   /* horizontal text, centered */
   text x=xHtc y=yHtc text=hTextC / splitchar='.' splitpolicy =splitalways;
   /* horizontal text, left aligned */
   text x=xHtl y=yHtl text=hTextl / splitchar='.' splitpolicy=splitalways position=right;
   /* vertical text */
   text x=xVt y=yVt text=vtext / rotate=90 textattrs=(size=9 color=white);
   xaxis display=none min=0 max=90 offsetmin=0 offsetmax=0;
   yaxis display=none min=0 max=200 offsetmin=0 offsetmax=0;
run
;

ods _all_ close ;

/*** End program ***/