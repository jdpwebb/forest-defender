#pragma once

#include <stdbool.h>
#include <stdio.h>

// Size of buffer needed for the event string
#define EVENT_STRING_SIZE 85

/// <summary>
///		Creates a formatted string representing the event as a JSON object.
///		The generated JSON object consists of three key-value properties:
///			"eventType": specifies a string with the event category
///			"confidence": a value from 0 - 1 representing the prediction confidence
///			"eventTime": the time the event occurred represented using seconds since epoch
///		The stringified JSON is then stored in buffer.
///	</summary>
/// <param name="buffer">Array that the event string is stored in.</param>
/// <param name="buf_size">
///		Byte size of the buffer parameter.
///		This should be at least EVENT_STRING_SIZE large.
///	</param>
/// <param name="event_type">String of event category.</param>
///	<param name="confidence">Confidence in event prediction (0 - 1).</param>
/// <returns>True on success, false on failure.</returns>
bool construct_event_message(
	char* buffer, size_t buf_size, const char* event_type, float confidence
);