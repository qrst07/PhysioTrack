.. highlight:: cpp

GPIO
====
A general-purpose input/output (GPIO) is an uncommitted digital or analog signal pin on the MetaWear board.

All boards come with general purpose I/O pins allowing users to attach their own sensors. You can attach an analog heart-rate sensor, a thermistor, a push sensor and more using the GPIOs on the MetaWear board. 

Functions for communicating with the gpio pins are in the 
`gpio.h <https://mbientlab.com/docs/metawear/cpp/latest/gpio_8h.html>`_ header file.

Analog Data
-----------
Analog input data comes in 2 forms, an ADC value or a absolute reference value.  These two modes are distinguished with the 
`MblMwGpioAnalogReadMode <https://mbientlab.com/docs/metawear/cpp/latest/gpio_8h.html#a88643319ca6ab68ed13089c51dbbd95d>`_ enum.

To read analog data, call 
`mbl_mw_datasignal_read <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#a0a456ad1b6d7e7abb157bdf2fc98f179>`_ with your analog input 
signal.  ADC values are represented as an unsigned integer and are simply ratiometric values with no units.  The absolute reference value is also 
represented as an unsigned integer but has units of milli volts. ::

    let pin = UInt8(1)
    let signal = mbl_mw_gpio_get_analog_input_data_signal(device.board, pin, MBL_MW_GPIO_ANALOG_READ_MODE_ABS_REF)!
    signal.read().continueOnSuccessWith { data in
        let value: UInt32 = data.valueAs() // Units in mili volts
        print(String(format: "%.3fV", Double(value) / 1000.0))
    }

Enhanced Analog Reads
---------------------
Starting with firmware v1.2.3, additional features have been added to the analog read.  To use these features, call 
`mbl_mw_datasignal_read_with_parameters <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#a71391d5862eb18327ce2aaaac4a12159>`_
and use a `MblMwGpioAnalogReadParameters <https://mbientlab.com/docs/metawear/cpp/latest/structMblMwGpioAnalogReadParameters.html>`_ struct as the 
parameter.  Not all of the struct variables are required, for the read.  To indicate that any of the pin variables are not used, set them to 
`MBL_MW_GPIO_UNUSED_PIN <https://mbientlab.com/docs/metawear/cpp/latest/gpio_8h.html#a2fa68bf3103b371ad501bb9bceab40ba>`_, and to indicate the delay 
variable is unused, set it to 0.  ::

    // read with pullup pin 0, unused pull down pin, virtual pin 21, unused delay
    MblMwGpioAnalogReadParameters read_params= { 0, MBL_MW_GPIO_UNUSED_PIN, 0x15, 0};
    mbl_mw_datasignal_read_with_parameters(adc_signal, &read_params);

Pullup and Pulldown Pins
^^^^^^^^^^^^^^^^^^^^^^^^
Setting a pullup/pulldown pin will have the board automatically set the pull mode on that pin prior to reading the analog data.  ::

    // pullup pin 0 before reading pin 0
    var parameters = MblMwGpioAnalogReadParameters(0, MBL_MW_GPIO_UNUSED_PIN, MBL_MW_GPIO_UNUSED_PIN, 0)
    mbl_mw_datasignal_read_with_parameters(signal, &parameters)

Delay
^^^^^
The delay parameter controls how long the firmware will wait after the pull mode is set before reading the data.  The firmware will wait for up to 
1 millisecond or if unused, immediately read the analog signal.  ::

    // wait 10 milliseconds after pulling down pin 2 before reading pin 1
    var parameters = MblMwGpioAnalogReadParameters(MBL_MW_GPIO_UNUSED_PIN, 2, MBL_MW_GPIO_UNUSED_PIN, 10)
    mbl_mw_datasignal_read_with_parameters(signal, &parameters)

Virtual Pins
^^^^^^^^^^^^
Virtual pins are dummy GPIO pins that can be used to redirect the analog output to another pin.  For example, you can assign a unique pin for each 
read configuration in your circuit which will send the data for the configurations to different message handlers.  Keep in mind that when using virtual 
pins, you will need to subscribe to both the original and virtual pin for streaming.  ::

    var virtual_adc_signal = mbl_mw_gpio_get_analog_input_data_signal(board, 0x15, MBL_MW_GPIO_ANALOG_READ_MODE_ADC)

    mbl_mw_datasignal_subscribe(virtual_adc_signal, bridge(obj: self)) { (context, obj) in
        let value: UInt32 = obj!.pointee.valueAs()
        print("gpio 21 adc: \(value)")
    }
    mbl_mw_datasignal_subscribe(adc_signal, nullptr);

    // read pin 0, direct output to pin 21
    var parameters = MblMwGpioAnalogReadParameters(MBL_MW_GPIO_UNUSED_PIN, MBL_MW_GPIO_UNUSED_PIN, 0x15, 0)
    mbl_mw_datasignal_read_with_parameters(signal, &parameters)

Digital Data
------------
Digital input data is an input signal that is interpreted as a 1 or 0.  As per the 
`product specification <https://mbientlab.com/docs/MetaWearPPSv0.7.pdf>`_ section 6.1, a logical 
high is between 2.1 and 3.0 volts and low is between 0 and 0.9 volts.  To ensure that your input signal resides within one of the valid ranges, set 
the pull mode with `mbl_mw_gpio_set_pull_mode <https://mbientlab.com/docs/metawear/cpp/latest/gpio_8h.html#aa451272a7c3d6a98feef8ed75723b677>`_.

To read the data input value, issue a call to 
`mbl_mw_datasignal_read <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#a0a456ad1b6d7e7abb157bdf2fc98f179>`_ with your digial signal.  
Digital data is interpreted as an unsigned integer. ::

    let pin = UInt8(0)
    let signal = mbl_mw_gpio_get_digital_input_data_signal(device.board, pin)!
    signal.read().continueOnSuccessWith { data in
        let value: UInt32 = data.valueAs()
        print(value != 0 ? "1" : "0")
    }

Input Monitoring
----------------
The firmware can also monitor the digital state of the input signal and alert the user if the state changes.  Set the change type by calling 
`mbl_mw_gpio_set_pin_change_type <https://mbientlab.com/docs/metawear/cpp/latest/gpio_8h.html#aea5c02779ade9da2592c234088bb1f8e>`_ and then call 
`mbl_mw_gpio_start_pin_monitoring <https://mbientlab.com/docs/metawear/cpp/latest/gpio_8h.html#a5cf8e8869e0e4ca551f6c775df469364>`_ to start the 
monitoring. ::

    let pin = UInt8(3)
    mbl_mw_gpio_set_pin_change_type(device.board, pin, MBL_MW_GPIO_PIN_CHANGE_TYPE_ANY)

    let signal = mbl_mw_gpio_get_pin_monitor_data_signal(device.board, pin)!
    mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
        let value: UInt32 = obj!.pointee.valueAs()
        print("Change Count: \(value)")
    }
    mbl_mw_gpio_start_pin_monitoring(device.board, pin)