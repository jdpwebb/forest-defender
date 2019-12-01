/* Copyright (c) Jeremy Webb. All rights reserved.
   Licensed under the MIT License. */

// This file defines the mapping from the Avnet AESMS MT3620 Starter Kit to the
// abstraction used for the peripherals for the Forest Defender project.

// This file is autogenerated from ../../forest_defender_hardware.json.  Do not edit it directly.

#pragma once
#include "avnet_aesms_mt3620.h"

// AVNET AESMS MT3620: Button A.
#define BUTTON_A AVNET_AESMS_PIN14_GPIO12

// AVNET AESMS MT3620: ADC Microphone controller
#define MICROPHONE_CONTROLLER AVNET_AESMS_ADC_CONTROLLER0

// AVNET AESMS MT3620: Connect external microphone ADC controller 0, channel 1 using SOCKET1 AN.
#define MICROPHONE AVNET_AESMS_ADC_CHANNEL1

