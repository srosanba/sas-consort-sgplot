%let gpath = H:\GitHub\srosanba\sas-consort-sgplot;
ods listing gpath="&gpath";

%include "&gpath/macros/makeboxes.sas";
%include "&gpath/macros/makelinks.sas";
%include "&gpath/macros/positiontext.sas";

/*
This modification involves the use of 3 macros designed to lessen the
burden of specifying so many coordinates throughout the program. It would
be only slightly more efficient if you got everything perfect the first 
time. But if you ever needed to resize or reposition a box, this approach
should prove to be much more robust to such changes.

%makeboxes
   Specify box data as center (x), top (y), width, height. The macro
then calculates the coordinates of the 4 corners for you and creates an
emptyBoxes (or filledBoxes) dataset. Not only is there half as much typing
involved in the initial specification, but repositioning or resizing boxes
should be much simpler with this approach.

%makelinks
   Specify which box pairs should be connected as fromId, toId. The macro
then calculates where the link vertices should be located and creates a 
linksCoord dataset. This approach adapts automatically to the subsequent 
resizing or repositioning of boxes. There's even an option to all for links
to insert into the sides of boxes.

%positiontext
   Specify the boxId that a given text string goes with. The macro then
calculates the appropriate coordinates for the text and creates the 
appropriate dataset: hTextC, hTextL, vText. This approach adapts auto-
matically to the subsequent repositioning of boxes. You do have to write
slightly more code when using this macro as compared to the hardcoded
coordinates approach. But it's probabely worth it if you are in the draft
phase with your layout.
*/


*--------------------------------------------------------------------------------;
*---------- empty boxes creation ----------;
*--------------------------------------------------------------------------------;

data emptyInfo;
   infile datalines dsd;
   input boxId center top width height;
   datalines;
 1, 30,200, 30,10
 2, 30,170, 30,10
 3, 65,195, 30,30
11, 20,140, 18,40
12, 40,140, 18,40
13, 60,140, 18,40
14, 80,140, 18,40
21, 20, 90, 18,40
22, 40, 90, 18,40
23, 60, 90, 18,40
24, 80, 90, 18,40
31, 20, 40, 18,40
32, 40, 40, 18,40
33, 60, 40, 18,40
34, 80, 40, 18,40
;
run;

%makeboxes(data=emptyInfo,type=empty);


*--------------------------------------------------------------------------------;
*---------- filled boxes creation ----------;
*--------------------------------------------------------------------------------;

data filledInfo;
   infile datalines dsd;
   input boxId center top width height;
   datalines;
 0, 6,195, 5,40
10, 6,140, 5,40
20, 6, 90, 5,40
30, 6, 40, 5,40
;
run;

%makeboxes(data=filledInfo,type=filled);


*--------------------------------------------------------------------------------;
*---------- links creation ----------;
*--------------------------------------------------------------------------------;

data linksInfo;
   infile datalines dsd;
   length fromId toId 8 toEdge $6;
   input fromId toId toEdge $;
   datalines;
 1, 2,
 1, 3,left
 2,11,
 2,12,
 2,13,
 2,14,
11,21,
12,22,
13,23,
14,24,
21,31,
22,32,
23,33,
24,34,
;
run;

%makelinks(dataBoxes=emptyInfo,dataLinks=linksInfo);


*--------------------------------------------------------------------------------;
*---------- position centered horizontal text ----------;
*--------------------------------------------------------------------------------;

data hTextCInfo;
   infile datalines dsd;
   length boxId 8 htextc $50;
   input boxId htextc $;
   datalines;
01,Assessed for Eligibility (n=445)
02,Randomized (n=406)
;
run;

%positiontext
   (dataText=hTextCInfo
   ,dataBoxes=emptyInfo
   ,out=hTextC
   ,justify=c
   );


*--------------------------------------------------------------------------------;
*---------- position left-justfied horizontal text ----------;
*--------------------------------------------------------------------------------;

data hTextLInfo(drop=type n1-n5 arm);
   length type $12 hTextL $125;
   input boxId type $ arm $ 20-27 n1-n5;
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
03     Enrollment          39 22 14 3
11     Allocation  Placebo 95 90 5
12     Allocation  ARM 1   103 103 0
13     Allocation  ARM 2   105 98 7
14     Allocation  ARM 3   102 101 1
21     Follow-Up           10 2 4 0 4
22     Follow-Up           7 3 2 1 1
23     Follow-Up           11 5 2 1 3
24     Follow-Up           16 7 6 2 1
31     Analysis            89 7 90 6
32     Analysis            100 3 103 0
33     Analysis            98 7 98 7
34     Analysis            92 10 101 1
;
run;

%positiontext
   (dataText=hTextLInfo
   ,dataBoxes=emptyInfo
   ,out=hTextL
   ,justify=l
   );


*--------------------------------------------------------------------------------;
*---------- position vertical text ----------;
*--------------------------------------------------------------------------------;

data vTextInfo;
   input boxId vtext $10-75;
   datalines;
00       Enrollment
10       Allocation
20       Follow-Up
30       Analysis
;
run;

%positiontext
   (dataText=vTextInfo
   ,dataBoxes=filledInfo
   ,out=vText
   ,rotate=90
   );


*--------------------------------------------------------------------------------;
*---------- back to regularly scheduled programming ----------;
*--------------------------------------------------------------------------------;

/**
 * Combine all graph data
 */
data consort;
   set 
      linksCoord 
      emptyBoxes
      filledBoxes 
      hTextC 
      hTextL 
      vText
      ;
run;

%let dpi=200;
ods listing image_dpi=&dpi;

/**
 * Draw the Consort Diagram
 */
ods graphics / reset width=6in height=4in imagename='efficiencies';
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
   /* layout preview */
   *text x=xLayout y=yLayout text=tLayout;
   /* configure axes */
   xaxis display=none min=0 max=90 offsetmin=0 offsetmax=0;
   yaxis display=none min=0 max=200 offsetmin=0 offsetmax=0;
run
;

ods _all_ close ;

/*** End program ***/