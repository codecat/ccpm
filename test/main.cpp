#include <cstdio>

#include <foo.h>

int main()
{
	printf("It works!\n");

#if defined(PLATFORM_WINDOWS)
	printf("Windows\n");
#elif defined(PLATFORM_LINUX)
	printf("Linux\n");
#elif defined(PLATFORM_MACOS)
	printf("MacOS\n");
#endif

	DoFoo();
	return 0;
}
