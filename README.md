# sas-consort-sgplot

Prashant Hebbar and Sanjay Matange published a paper at PharmaSUG 2018 titled [CONSORT Diagrams with SG Procedures](https://www.lexjansen.com/pharmasug/2018/DV/PharmaSUG-2018-DV24.pdf). The result of the process they describe is an image file that looks like this:

![consort via sgplot](https://github.com/srosanba/sas-consort-sgplot/blob/master/img/originalpaper.png)

I liked the idea with one exception: you had to hardcode a **lot** of coordinates into the program. 

* The box corners (x60)
* The link vertices (x37)
* The text location (x15)

All of these hardcoded coordinates seemed like the kind of thing that could be made more efficient. Starting with the code from the paper ([originalpaper.sas](https://github.com/srosanba/sas-consort-sgplot/blob/master/originalpaper.sas)), I set about making modifications to see whether or not I could:

* reduce the specifications burden 
* make the whole process more robust to future changes in the diagram layout. 

The end result of this quest for efficiency was the creation of three helper [macros](https://github.com/srosanba/sas-consort-sgplot/tree/master/macros). The macros allow you to:

1. **Specify the box locations with a 4-number summary (center, top, width, height).**  
  a. The original method was an 8-number summary in which the coordinates for each corner of the box was specified.  
  b. The 4-number summary is going to take less time to type.  
  c. The 4-number summary also makes it significantly easier to resize and reposition a box.  
1. **Specify links as boxId pairs (fromId, toId).**  
  a. The original method was to specify the coordinates of every link vertex (origins, insertions, elbows).  
  b. The boxId pairs approach is clearly going to be faster to spec.  
  c. Using the boxId pairs approach also means that the links automatically adjust themselves when boxes are resized or repositioned.
1. **Position text based on boxId (boxId, text-string).**  
  a. The original method was to specify the coordinates of the text associated with each box.  
  b. The boxId approach is slightly faster during the initial specification.  
  c. Using the boxID approach means that the text automatically repositions itself when boxes are resized or repositioned.

Here is a side-by-side of the box creation code (original on the left, efficiencies on the right). Each dataline has 4 numbers instead of 2, but there are one quarter the number of datalines. Additionally, resizing and repositioning boxes is easier.

<kbd>![boxes efficiencies](https://github.com/srosanba/sas-consort-sgplot/blob/master/img/boxesempty.png)</kbd>

Here is a side-by-side of the links creation code (original on the left, efficiencies on the right). As you can see in the screen shot, my 23" vertically-oriented monitor wasn't tall enough to capture all of the original link creation code. If the boxes dataset was somewhat efficient, then the links dataset is supremely efficient.

<kbd>![links efficiencies](https://github.com/srosanba/sas-consort-sgplot/blob/master/img/links.png)</kbd>

Here is a side-by-side of the centered horizontal text creation code (original on the left, efficiencies on the right). This is the one place where using the "efficient" macros actually requires more typing. The data steps are the same length, but you have to add the macro call. It's more work up front to use the macro here, but it's robust to repositioning of boxes once you've set it up. 

<kbd>![text efficiencies](https://github.com/srosanba/sas-consort-sgplot/blob/master/img/texthc.png)</kbd>

**Conclusion**: The revised code ([efficiencies.sas](https://github.com/srosanba/sas-consort-sgplot/blob/master/efficiencies.sas)) is much more compact than the original program and should be more robust to resizing and repositioning of boxes and links should the need arise. 

**WARNING**: Do not mistake this SAS code for a robust software suite. The macros were coded quickly and without ANY form of parameter checking (not even case-sensitivity). These are merely proof-of-concept macros. Use at your own risk. You have been warned.

**Post-script**: Subsequent to the creation of the above helper macros, further efficiencies were explored in the repo [sas-consort-experimental](https://github.com/srosanba/sas-consort-experimental). This repository provides a shortcut for the creation of the emptyBoxes dataset. Combining the two approaches might make you so efficient that you'll put yourself out of work. 
