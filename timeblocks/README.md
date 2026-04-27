# TimeBlocks (with VWAP)

Active, maintained indicator package for MetaTrader 5. Unlike the legacy
indicators in this repository, **TimeBlocks is the current focus and is built
for present-day chart analysis**, not binary-options signal generation.

This folder contains two indicators that work together:

| File | Purpose |
|------|---------|
| `TimeBlocks.mq5` | Slices the chart into fixed time blocks and overlays per-block analytics. |
| `VWAP.mq5` | Daily Volume-Weighted Average Price. Required by TimeBlocks for VWAP features. |

---

## TimeBlocks.mq5

Draws vertical separators at fixed time intervals (1 min through 1 day, or
custom) and decorates each block with statistics drawn from the bars inside it.

### Per-block overlays

| Overlay | What it shows |
|---------|---------------|
| **Vertical separators** | Boundaries between blocks. Optional time labels. |
| **High / Low lines** | Highest high and lowest low recorded inside each completed block. |
| **Candle counts** | Number of bullish vs. bearish bars inside each block. |
| **VWAP balance** | `Σ(high − VWAP) − Σ(VWAP − low)` across the block; positive means price spent more time above VWAP, negative means below. |
| **VWAP projection** | Simulated VWAP value at the end of the ongoing block (or end of day), using historical same-time-of-day volume profile. |
| **Range prediction** | Locked predicted high / low for the ongoing block. **Non-repaint**: anchored at block open, sized from historical same-time-of-day blocks (or ATR fallback). |

### Block size presets

`1m`, `5m`, `15m`, `30m`, `1h`, `2h`, `4h`, `8h`, `12h`, `1d`, or **custom
minutes**.

### Day selection

| Mode | Behaviour |
|------|-----------|
| `Today` | Current server-time day only. |
| `All` | Every day inside the configured bar window. |
| `Specific` | A single date (`YYYY.MM.DD`). |

`InpDrawForward = true` extends boundaries into the unfinished portion of the
day so today's lines render before bars exist for them.

### Range prediction model

Three modes:

1. **Hybrid** *(default)*: historical same-time-of-day block deviations,
   falling back to ATR-scaled extension when no history is available.
2. **Historical**: same-time-of-day blocks only; nothing drawn if no history.
3. **ATR locked**: symmetric extension from block open: `0.5 · ATR · √N · K`,
   where `N` is the number of base-timeframe bars per block.

The cache is locked at block start, so the lines never shift intrabar.

### VWAP projection model

At the end of each new bar, TimeBlocks recovers `Σ(TPV)` from the live VWAP
buffer, then projects forward using mean volume from the last
`InpVwapProjLookback` days over the same time-of-day window. Falls back to
session-pace extrapolation if no historical days are available. The projection
line then updates per tick using only the latest price.

---

## VWAP.mq5

Daily VWAP. Resets at the start of each calendar day. Single dashed line.

### Price source (`Price_Type`)

| Option | Formula |
|--------|---------|
| `OPEN` | `O` |
| `CLOSE` | `C` |
| `HIGH` | `H` |
| `LOW` | `L` |
| `OPEN_CLOSE` | `(O + C) / 2` |
| `HIGH_LOW` | `(H + L) / 2` |
| `CLOSE_HIGH_LOW` *(default)* | `(C + H + L) / 3` |
| `OPEN_CLOSE_HIGH_LOW` | `(O + C + H + L) / 4` |

Volume source: prefers tick volume, falls back to real volume.

---

## Installation

1. Copy both `.mq5` files into MetaTrader 5 under
   `MQL5/Indicators/` (VWAP must sit at the root of `Indicators/`, not in a
   subfolder, because TimeBlocks loads it by name via `iCustom`).
2. In MetaEditor, compile `VWAP.mq5` first, then `TimeBlocks.mq5`.
3. Attach `TimeBlocks` to a chart. To enable VWAP features, leave
   `InpVwapIndicator = "VWAP"` and ensure `InpVwapPriceType` matches the
   `Price_Type` set on the VWAP indicator.

---

## Usage notes

- **Price-type alignment.** `InpVwapPriceType` in TimeBlocks must match
  `Price_Type` in VWAP. The enums are intentionally ordered identically; just
  pick the same option in both.
- **Standalone VWAP.** VWAP.mq5 works on its own, no TimeBlocks required.
- **Non-repaint guarantee** applies to the range-prediction lines only. Block
  high/low lines naturally extend during the active block as new highs/lows
  print; they stop moving once the block closes.
- **Object cleanup.** Every object created by TimeBlocks is prefixed with
  `InpObjPrefix` (default `TB_`) and removed on deinit.

---

## Inputs reference (TimeBlocks)

Grouped exactly as they appear in the indicator dialog:

- **Block size**: preset selector and custom-minutes override.
- **Day selection**: mode + target date + forward-draw toggle.
- **Range / bars**: apply within last N bars (0 = all visible).
- **Appearance**: vertical line colour/style/width, label settings.
- **High / Low per block**: toggle, colours, style, width, z-order.
- **VWAP balance per block**: toggle, indicator name, price source,
  decimals, colours.
- **VWAP projection**: toggle, lookback days, project-to-block-end vs.
  end-of-day, line/label appearance.
- **Range prediction**: model selector, lookback, ATR bars, extension
  multiplier `K`, line/label appearance.
- **Candle counts per block**: toggle, top/bottom position, colours,
  font.
- **Object naming**: prefix used for all created objects.

---

## License

Provided as-is for educational and personal use. See the
[repository root](../README.md) for the broader collection.
