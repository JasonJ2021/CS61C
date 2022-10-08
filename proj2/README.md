# 61C Spring 2022 Project 2: CS61Classify

Spec: [https://cs61c.org/sp22/projects/proj2/](https://cs61c.org/sp22/projects/proj2/)

```bash
 proj2/src/abs.s          |  10 +--
 proj2/src/argmax.s       |  36 +++++++--
 proj2/src/classify.s     | 188 ++++++++++++++++++++++++++++++++++++++++++++---
 proj2/src/dot.s          |  55 ++++++++++----
 proj2/src/matmul.s       |  96 +++++++++++++++++-------
 proj2/src/read_matrix.s  |  92 +++++++++++++++++++++--
 proj2/src/relu.s         |  49 ++++++++----
 proj2/src/write_matrix.s |  73 +++++++++++++++++-
 proj2/studenttests.py    | 184 ++++++++++++++++++++++++++++++++++++++--------
 9 files changed, 663 insertions(+), 120 deletions(-)
```

This project helps me gain a deeper understanding about risc-V assembly language. I have written about 400~ lines assembly code , which is a definitely painful but enlightening journey.

This project took me about ~6 hours to finish.

The most frequent bug I've encountered is memory bug, especially  loading variable/ptr.

Thanks to UCB for kindly sharing this learning source to us！
