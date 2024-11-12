# Custom Indicator for MetaTrader

### Overview
This repository contains a custom indicator for the MetaTrader platform, specifically designed for traders who want a simple Buy signal indicator with optional alerting functionality. The indicator uses the Average True Range (ATR) to determine suitable buying opportunities.

- **Version:** 1.00 (Free Version)
- **Creator:** [@binarydina](https://t.me/binarydina)
- **License:** Free version without time limits; contact for the Pro version.

### Features
- **Simple Buy Indicator**: Displays a Buy arrow on the chart when ATR falls below a certain value.
- **Audible Alerts**: Optional audible alerts can be configured to trigger for Buy signals.
- **Highly Customizable**: Adjustable parameters, including alert thresholds and other settings.

### Parameters
| Parameter       | Type    | Description |
| --------------- | ------- | ----------- |
| `Value_B`       | `double` | Threshold for ATR to trigger a Buy signal. Default is `2.23`. |
| `Audible_Alerts` | `bool` | Enables/disables sound alerts when a Buy signal is generated. Default is `true`. |

### Installation
1. Copy the provided code into a `.mq5` file and save it to the MetaTrader platform's `Indicators` folder.
2. Refresh or restart MetaTrader to recognize the new indicator.

### Usage
1. **Attach the Indicator**: Open a chart, navigate to Indicators, and attach this custom indicator.
2. **Adjust Parameters**: Before adding to the chart, configure `Value_B` and `Audible_Alerts` as desired.

### Code Structure
- **Initialization (`OnInit`)**: Sets up the indicator buffers and initializes ATR for calculating the Buy signals.
- **Calculation (`OnCalculate`)**: Processes each tick, checking if the ATR is below the specified threshold (`Value_B`). When it is, a Buy arrow appears, and an alert may sound if `Audible_Alerts` is enabled.
- **Alert System (`myAlert`)**: Provides different types of alerts; by default, it logs alerts or shows sound alerts when `Audible_Alerts` is set to `true`.

### Sample Output
The indicator plots a Buy arrow on the chart whenever the conditions are met, based on the specified `Value_B`. The Buy arrow will appear at the candle low and may trigger a sound alert if configured.

### Contact for Pro Version
This free version is fully functional, with no time limits. However, for additional features and customization, contact me on Telegram: [@binarydina](https://t.me/binarydina).

### License
This indicator is provided as-is with no warranty. It’s free to use, modify, and share with attribution to the original author.
