# Copycat


**Dear potential co-authors,**

I am planning to use this codebase, or the co.py.cat one, to implement a variation of Copycat that uses Entropy instead of Temperature and still preserves the parallel terraced scan in full form.  If the change is viable, I plan to write a paper on that.  For the general idea, please see pages 41 and 42 of the [*Information Sciences*](https://github.com/Alex-Linhares/FARGlexandria/blob/master/Literature/Chess-Capyblanca-2014-Linhares-Information%20Sciences.pdf) paper on [Capyblanca](https://github.com/Alex-Linhares/FARGlexandria).  **If you would like to help, please let me know!** 

---

A translation of Melanie Mitchell's original Copycat project from Lisp to
Python. To find the original information and source code for Copycat, see her
[website](http://web.cecs.pdx.edu/~mm/).

The translation of the core logic is 100% complete, and a proper GUI is in the works. For now, you can run a problem on the command line:

```
python3 Copycat.py --quiet abc abd ijk
```

![Copycat GUI](http://i.imgur.com/lHMwn.png)
