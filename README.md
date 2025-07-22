# TC514 Controller

# TC514 ADC FSM Controller

This project implements a complete digital controller for the dual slope integrating analog-to-digital converter (ADC), the TC514, including the FSM (finite state machine), counter, output latch, and clock divider. It is designed in VHDL and includes a simulation testbench and a behavioral model of the TC514.

---

## Overview

The controller operates the TC514 ADC by managing its phase signals (`a` and `b`), monitoring the comparator, and measuring integration time with a counter. Once the conversion is complete, the final digital value is latched into an output register.

---

## 🧱 Module Descriptions

### `freq_div`
A 4-bit frequency divider used to generate a slower clock (`clk_dvd`) from the system clock.

### `binary_cntr`
A parameterized up/down counter controlled by two enables and direction input. Counts integration/deintegration time.

### `out_reg`
Parameterizable register used to latch the counter value (`q`) at the end of conversion.

### `tc514fsm`
The core FSM controller that manages the following states:
- `AUTOZERO`: Reset the integrator
- `IDLE`: Await SOC
- `INTEGRATE`: Integrate input signal
- `DEINTEGRATE`: Discharge phase
- `INTEGRATOR_ZERO`: Wait for integrator to return to zero
- `CLEAR_CNTR`: Clear counter before next cycle

<img width="574" height="591" alt="image" src="https://github.com/user-attachments/assets/506cd705-f07f-49ff-bf67-7765127e03f6" />


Outputs include control for phase lines, busy signal, counter enable, clear, and load signal.

Conversion Phases Table:
## Conversion Phases

| A | B | Phase              | Purpose                                | Duration                         |
|---|---|--------------------|----------------------------------------|----------------------------------|
| 0 | 1 | Auto Zero          | Correct for offset voltages            | 2<sup>16</sup> clocks minimum    |
| 1 | 0 | Signal Integrate   | Integrate unknown input voltage        | 2<sup>16</sup> clocks exactly    |
| 1 | 1 | Reference Deintegrate | Integrate -V<sub>ref</sub>          | Until neg. edge of `CMPTR`       |
| 0 | 0 | Integrator Zero    | Bring integrator’s output to 0         | Until pos. edge of `CMPTR`       |

---

## Features

- FSM-based conversion control for integrating ADC
- Testbench includes analog behavioral model
- Modular and reusable components
- Parametrizable bit-width 
---

## Hardware Implementation

The controller assumes:
- The TC514 outputs a logic-high comparator signal during integration, and a logic-low during deintegration.
- Timing behavior is simulated for verification using delays and internal counters.
