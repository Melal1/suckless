static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"", "mem.sh",	20,		0},
	{"^c#B97E11^TEST", "cpu.sh",	5,		5},


	{"", "clock.sh",					45,		0},
};

//sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = " | ";
static unsigned int delimLen = 5;
