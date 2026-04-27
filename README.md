# MT5 Indicators Collection

MetaTrader 5 indicators. One actively maintained package; the rest are
archived.

## Indicators

| Folder | Status | Description |
|--------|--------|-------------|
| [`timeblocks/`](./timeblocks/README.md) | Active | Time-block separators with per-block high/low, candle counts, VWAP balance, VWAP projection, and non-repaint range prediction. Ships with a daily VWAP indicator. |
| [`Go-V-Indicator/`](./Go-V-Indicator/README.md) | Archived | Moving-average signal indicator for Deriv volatility indices. |
| [`PAM/`](./PAM/README.md) | Archived | ATR-threshold buy-arrow indicator with optional alerts. |
| [`RSI-MA-Indicator/`](./RSI-MA-Indicator/README.md) | Archived | RSI + EMA crossover for Jump / Volatility indices on 5m. |
| [`imbalance-indicator/`](./imbalance-indicator/README.md) | Archived | Early-stage imbalance detector. Unfinished. |

> [!WARNING]
> Archived indicators target a binary-options workflow on Deriv synthetic
> indices. They are kept for reference and are not recommended for live
> trading.

## Installation

1. Copy the relevant `.mq5` files into `MQL5/Indicators/` in your MetaTrader 5
   data folder.
2. Compile in MetaEditor.
3. Attach to a chart.

Parameters and per-indicator notes live in each folder's README.

## Contributing

Issues and pull requests are welcome for `timeblocks/`. Archived indicators
are not maintained.

## License

[MIT](./LICENCE) © Dineth Pramodya.

## Author

Dineth Pramodya · <http://www.dineth.lk>
