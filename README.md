# TC514 Controller

# TC514 ADC FSM Controller

This project implements a complete digital controller for the TC514 integrating analog-to-digital converter (ADC), including the FSM (finite state machine), counter, output latch, and clock divider. It is designed in VHDL and includes a detailed simulation testbench and a behavioral model of the TC514.

---

## 💡 Overview

The controller operates the TC514 ADC by managing its phase signals (`a` and `b`), monitoring the comparator, and measuring integration time with a counter. Once the conversion is complete, the final digital value is latched into an output register.

---

## 📐 Top-Level Module: `tc514cntrl`

This structural module integrates the following components:
- `freq_div`: Clock divider
- `binary_cntr`: N-bit up counter
- `tc514fsm`: FSM controlling the conversion states
- `out_reg`: Output register for storing the result

### Inputs
- `soc`: Start-of-conversion signal
- `clk`: System clock
- `cmptr`: Comparator output from TC514
- `rst_bar`: Active-low synchronous reset

### Outputs
- `a`, `b`: Phase control signals for TC514
- `dout`: Final digital output
- `busy_bar`: High when idle, low during conversion

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

Outputs include control for phase lines, busy signal, counter enable, clear, and load signal.

---

## 🧪 Testbench: `tc514cntrl_tb`

A complete simulation testbench is provided which:
- Generates the system clock
- Simulates two conversions with a test analog value
- Asserts correctness of the output (`dout`)
- Instantiates a behavioral model of the TC514 device

Behavioral model includes:
- `fsm`: Controls simulated comparator output
- `bin_cntr`: Internal analog model counter
- `freq_div_tc514_model`: Simulated divider
- `tc514model`: Top-level behavioral model entity

---

## 🔧 Features

- FSM-based conversion control for integrating ADC
- Testbench includes analog behavioral model
- Modular and reusable components
- Parametrizable bit-width (default 16 bits)

---

## 📝 Notes

The controller assumes:
- The TC514 outputs a logic-high comparator signal during integration, and a logic-low during deintegration.
- Timing behavior is simulated for verification using delays and internal counters.
