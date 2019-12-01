#include "event_utilities.h"
#include <string.h>
#include <time.h>

bool construct_event_message(
	char* buffer, size_t buf_size, const char* event_type, float confidence
)
{
	const char* EventMsgTemplate = "{\"eventType\":\"%s\",\"confidence\":%1.2f,\"eventTime\":%d}";
	struct timespec currentTime;
	clock_gettime(CLOCK_REALTIME, &currentTime);
	int len = snprintf(buffer, buf_size, EventMsgTemplate, event_type, confidence, currentTime.tv_sec);
	return len > 0;
}