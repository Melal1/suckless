static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"", "volume",	 0,		16},
	{"", "mem",	 20,		6},
	{"", "storage",	 60,		2},
	{" ", "cpu",	 3,			5},
	{" ", "clock", 45,		4},
	{"", "openurl", 0, 3},

};

//sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = "";
static unsigned int delimLen = 5;
