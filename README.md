# sas-consort-sgplot

Prashant Hebbar and Sanjay Matange published a paper at PharmaSUG 2018 about a SGPLOT-only approach to creating CONSORT diagrams titled [CONSORT Diagrams with SG Procedures](https://www.lexjansen.com/pharmasug/2018/DV/PharmaSUG-2018-DV24.pdf).

![consort via sgplot](https://github.com/srosanba/sas-consort-sgplot/blob/master/originalpaper.png)

I liked the idea with one exception: you had to hardcode a lot of coordinates into the program. The box corners, the link vertices, the text location. It seemed like the kind of thing that could likely be made more efficient. Starting with the code from the paper, I set about making modifications to make the specifications more concise and more robust to subsequent changes. The end result of this quest for efficiency was the creation of three helper macros. These macros allow you to:

1. Specify the box locations with a 4-number summary (center, width, top, height).
1. Specify links as boxId pairs (fromId, toId). 
1. Position text based on boxId (boxId, text-string).

The original code from Prashant and Sanjay's paper can be found in [originalpaper.sas](https://github.com/srosanba/sas-consort-sgplot/blob/master/originalpaper.sas). The modified code can be found in [efficiencies.sas](https://github.com/srosanba/sas-consort-sgplot/blob/master/efficiencies.sas), with the corresponding macros in the [macros](https://github.com/srosanba/sas-consort-sgplot/tree/master/macros) folder. 

WARNING: do not mistake this SAS code for a robust software suite. The macros were coded quickly and without ANY form of parameter checking (not even case-sensitivity). These are merely proof-of-concept macros. Use at your own risk. You have been warned.
