# Overview

This is a C implementation of the Brew algorithm.  This is derived from the
Java implementation in hmsCommon/util, which in turn was derived from the Perl
module Text::Brew.

 http://www.ling.ohio-state.edu/~cbrew/795M/string-distance.html
 http://search.cpan.org/dist/Text-Brew/

To build/test, using bake run:

```
$ bake build && bake run
```


20060620: Interestingly enough after creating the initial
implementation of this module, I discovered a bug in the Perl version
(Text::Brew) in the way in which it initializes the comparison matrix.
It ended up initializing the base insertion and deletion costs (first
row and first column) with a constant plus the configuration value.
It should have been initializing with the trace back cell's best cost
plus the configuration value.
