# sas-consort-sgplot

Prashant Hebbar and Sanjay Matange published a paper at PharmaSUG 2018 titled [CONSORT Diagrams with SG Procedures](https://www.lexjansen.com/pharmasug/2018/DV/PharmaSUG-2018-DV24.pdf). The result of the process they describe is an image file that looks like this:

![consort via sgplot](https://github.com/srosanba/sas-consort-sgplot/blob/master/originalpaper.png)

I liked the idea with one exception: you had to hardcode a **lot** of coordinates into the program. The box corners (x60), the link vertices (x37), the text location (x15). All of these hardcoded coordinates seemed like the kind of thing that could likely be made more efficient. Starting with the code from the paper ([originalpaper.sas](https://github.com/srosanba/sas-consort-sgplot/blob/master/originalpaper.sas)), I set about making modifications to see whether or not I could reduce the specifications burden and make the whole process more robust to inevitable changes. The end result of this quest for efficiency was the creation of three helper [macros](https://github.com/srosanba/sas-consort-sgplot/tree/master/macros). The macros allow you to:

1. Specify the box locations with a 4-number summary (center, width, top, height).
1. Specify links as boxId pairs (fromId, toId). 
1. Position text based on boxId (boxId, text-string).

The revised code ([efficiencies.sas](https://github.com/srosanba/sas-consort-sgplot/blob/master/efficiencies.sas)) is much more compact than the original program and should be more robust to resizing and repositioning of boxes and links as the need arises. 

WARNING: do not mistake this SAS code for a robust software suite. The macros were coded quickly and without ANY form of parameter checking (not even case-sensitivity). These are merely proof-of-concept macros. Use at your own risk. You have been warned.
