#include "serial.h"
#include "timer.h"
#include "rtc_init.h"
#include "switch.h"
#include "pmu.h"

void vk_machine_init(void)
{
	vh_LedInit();
	vh_serial_init();
	vh_timer_init();
}
