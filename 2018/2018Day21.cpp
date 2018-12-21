// Note: This is not a general solution to the problem
// The general solution is to run the transpiler located at
// https://github.com/tellowkrinkle/AdventOfCode/blob/5b67ae18cc891df0c4a30f202c8e8d6411316c97/Extra/2018Day19_CTranspiler.swift
// on your input and then add the code between comments in this one to it

#include <stdlib.h>
#include <stdio.h>
// Code added to transpiled input starts here
#include <unordered_set>
// Code added to transpiled input ends here
#define badJump(line, reg) if (1) { fprintf(stderr, "Made a jump at l%d with an unsupported offset of %ld.  Transpile with -allJumps to enable full jump support.\n", (line), (reg)); abort(); }
void printRegs(long *r) {
	printf("%ld %ld %ld %ld %ld %ld\n", r[0], r[1], r[2], r[3], r[4], r[5]);
}
int main(int argc, char **argv) {
	long r[6] = {0};
	for (int i = 0; i < (argc > 6 ? 6 : argc - 1); i++) {
		r[i] = atoi(argv[i+1]);
	}
	// Code added to transpiled input starts here
	std::unordered_set<long> numbers;
	long last = -1;
	// Code added to transpiled input ends here
	l0: r[5] = 123;
	l1: r[5] = r[5] & 456;
	l2: r[5] = r[5] == 72 ? 1 : 0;
	l3: if (r[5] == 0) { goto l4; } else if (r[5] == 1) { goto l5; } else { badJump(3, r[5]); }
	l4: goto l1;
	l5: r[5] = 0;
	l6: r[3] = r[5] | 65536;
	l7: r[5] = 9010242;
	l8: r[1] = r[3] & 255;
	l9: r[5] = r[5] + r[1];
	l10: r[5] = r[5] & 16777215;
	l11: r[5] = r[5] * 65899;
	l12: r[5] = r[5] & 16777215;
	l13: r[1] = 256 > r[3] ? 1 : 0; // r3 <= 256
	l14: if (r[1] == 0) { goto l15; } else if (r[1] == 1) { goto l16; } else { badJump(14, r[1]); } // r3 <= 256
	l15: goto l17;
	l16: goto l28; // r5 == r0
	l17: r[1] = 0;
	l18: r[4] = r[1] + 1;
	l19: r[4] = r[4] * 256;
	l20: r[4] = r[4] > r[3] ? 1 : 0;
	l21: if (r[4] == 0) { goto l22; } else if (r[4] == 1) { goto l23; } else { badJump(21, r[4]); }
	l22: goto l24;
	l23: goto l26;
	l24: r[1] = r[1] + 1;
	l25: goto l18;
	l26: r[3] = r[1];
	l27: goto l8;
	l28: r[1] = r[5] == r[0] ? 1 : 0; // r5 == r0
	// Code added to transpiled input starts here
	if (last == -1) {
		printf("Part 1: %ld\n", r[5]);
	}
	if (numbers.find(r[5]) != numbers.end()) {
		printf("Part 2: %ld\n", last);
		exit(0);
	}
	last = r[5];
	numbers.insert(last);
	// Code added to transpiled input ends here
	l29: if (r[1] == 0) { goto l30; } else if (r[1] == 1) { r[2] = 29; printRegs(r); return 0; } else { badJump(29, r[1]); } // Exit
	l30: goto l6;
	r[2] = 30; printRegs(r); return 0;
}
