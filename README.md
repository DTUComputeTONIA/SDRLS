# Stagnation Detection with Randomized Local Search

by
Amirhossein Rajabi,
Carsten Witt


This paper has been submitted for publication in Evolutionary Computation Journal (ECJ).


## Abstract

Recently a mechanism called stagnation detection was proposed that
automatically adjusts the mutation rate of evolutionary algorithms when 
they encounter local optima. The so-called SD-(1+1)EA introduced by
Rajabi and Witt (GECCO~2020) adds stagnation detection to the classical 
(1+1)EA with standard bit mutation. This 
algorithm flips each bit independently 
with some mutation rate, and stagnation 
detection raises the rate when the 
algorithm is likely to have encountered a local optimum.

In this paper, 
we investigate stagnation detection in the context of the k-bit flip
operator of randomized local search that flips k bits chosen uniformly
at random and let stagnation detection adjust the parameter k. We obtain 
improved runtime results compared to the SD-(1+1)EA amounting to a speedup of at least (1-o(1))\sqrt{2\pi m}, where m is the so-called 
gap size, i.e., the distance to the next improvement. Moreover, we propose additional schemes that prevent infinite 
optimization times even if the algorithm misses a working choice of k due 
to unlucky events. Finally, we present an example where standard bit mutation 
still outperforms the k-bit flip operator with stagnation detection.

## Software implementation

> Briefly describe the software that was written to produce the results of this
> paper.
The code of each experiment is placed in a different folder.


## Getting the code

You can download a copy of all the files in this repository by cloning the
[git](https://git-scm.com/) repository:

    git clone https://github.com/DTUComputeTONIA/SDRLS.git



## Dependencies and Reproducing the results

You'll need a working Julia environment to run the code of Estimation and Experiment 2. The code of Experiment 1 is written in C.


## License

All source code is made available under a BSD 3-clause license. You can freely
use and modify the code, without warranty, so long as you provide attribution
to the authors. See `LICENSE.md` for the full license text.

The manuscript text is not open source. The authors reserve the rights to the
article content, which is currently submitted for publication in the
ECJ.

