//+------------------------------------------------------------------+
//|                                                  TimeBlocks.mq5  |
//|                    Draws vertical time-block separators on chart |
//+------------------------------------------------------------------+
#property copyright   "Dineth"
#property version     "1.00"
#property description "Vertical time-block lines (1 min .. 1 day or custom)"
#property indicator_chart_window
#property indicator_plots 0

//--- Block size preset (minutes). Select CUSTOM to use InpCustomMinutes.
enum ENUM_BLOCK_PRESET
  {
   BLOCK_CUSTOM  = 0,     // Custom (use InpCustomMinutes)
   BLOCK_1_MIN   = 1,     // 1 minute
   BLOCK_5_MIN   = 5,     // 5 minutes
   BLOCK_15_MIN  = 15,    // 15 minutes
   BLOCK_30_MIN  = 30,    // 30 minutes
   BLOCK_1_HOUR  = 60,    // 1 hour
   BLOCK_2_HOUR  = 120,   // 2 hours
   BLOCK_4_HOUR  = 240,   // 4 hours
   BLOCK_8_HOUR  = 480,   // 8 hours
   BLOCK_12_HOUR = 720,   // 12 hours
   BLOCK_1_DAY   = 1440   // 1 day
  };

//--- Day-selection mode.
enum ENUM_DAY_MODE
  {
   DAY_TODAY   = 0,       // Today (server time)
   DAY_ALL     = 1,       // All days within BarCount
   DAY_SPECIFIC = 2       // Specific date (InpTargetDate)
  };

//--- Inputs
input group                 "=== Block size ==="
input ENUM_BLOCK_PRESET     InpBlockPreset    = BLOCK_1_HOUR;  // Block preset
input int                   InpCustomMinutes  = 60;            // Custom minutes (if preset = CUSTOM)

input group                 "=== Day selection ==="
input ENUM_DAY_MODE         InpDayMode        = DAY_TODAY;     // Which day(s)
input string                InpTargetDate     = "2026.04.18";  // Target date (YYYY.MM.DD) for DAY_SPECIFIC
input bool                  InpDrawForward    = true;          // Draw forward lines into unfinished day

input group                 "=== Range / bars ==="
input int                   InpBarCount       = 1000;          // Apply within last N bars (0 = all visible)

input group                 "=== Appearance ==="
input color                 InpLineColor      = clrDodgerBlue; // Line colour
input ENUM_LINE_STYLE       InpLineStyle      = STYLE_DOT;     // Line style
input int                   InpLineWidth      = 1;             // Line width
input bool                  InpLineBack       = true;          // Draw behind bars
input bool                  InpShowLabels     = true;          // Show time labels
input color                 InpLabelColor     = clrSilver;     // Label colour
input int                   InpLabelFontSize  = 8;             // Label font size
input string                InpLabelFont      = "Arial";       // Label font

input group                 "=== High / Low per block ==="
input bool                  InpShowHighLow    = true;          // Draw high/low line per block
input color                 InpHighColor      = clrLime;       // High line colour
input color                 InpLowColor       = clrCrimson;    // Low line colour
input ENUM_LINE_STYLE       InpHLStyle        = STYLE_SOLID;   // High/low line style
input int                   InpHLWidth        = 1;             // High/low line width
input bool                  InpHLBack         = false;         // Draw high/low behind bars

//--- Must match PRICE_TYPE in VWAP.mq5 (same ordering)
enum ENUM_VWAP_PRICE
  {
   VP_OPEN                = 0,  // Open
   VP_CLOSE               = 1,  // Close
   VP_HIGH                = 2,  // High
   VP_LOW                 = 3,  // Low
   VP_OPEN_CLOSE          = 4,  // (O+C)/2
   VP_HIGH_LOW            = 5,  // (H+L)/2
   VP_CLOSE_HIGH_LOW      = 6,  // (C+H+L)/3
   VP_OPEN_CLOSE_HIGH_LOW = 7   // (O+C+H+L)/4
  };

input group                 "=== VWAP balance per block ==="
input bool                  InpShowVwapBalance = true;               // Show VWAP balance per block
input string                InpVwapIndicator   = "VWAP";             // VWAP indicator name (under MQL5/Indicators)
input ENUM_VWAP_PRICE       InpVwapPriceType   = VP_CLOSE_HIGH_LOW;  // VWAP price source (must match)
input int                   InpVwapDecimals    = 2;                  // Decimals for balance value
input color                 InpVwapPosColor    = clrLime;            // Colour when balance > 0
input color                 InpVwapNegColor    = clrCrimson;         // Colour when balance < 0
input color                 InpVwapZeroColor   = clrSilver;          // Colour when balance = 0
input int                   InpVwapFontSize    = 9;                  // Balance font size
input string                InpVwapFont        = "Arial";            // Balance font

input group                 "=== VWAP projection (ongoing block) ==="
input bool                  InpShowVwapProj     = true;         // Simulate daily VWAP at block end
input int                   InpVwapProjLookback = 20;           // Historical days for volume profile
input bool                  InpVwapProjToDayEnd = false;        // Project to end-of-day (else end-of-block)
input color                 InpVwapProjColor    = clrOrange;    // Projection line colour
input ENUM_LINE_STYLE       InpVwapProjStyle    = STYLE_DASH;   // Projection line style
input int                   InpVwapProjWidth    = 2;            // Projection line width
input bool                  InpVwapProjLabel    = true;         // Show projected value label
input int                   InpVwapProjFontSize = 8;            // Projection label font size

//--- Range-prediction model.
enum ENUM_RANGE_MODE
  {
   RANGE_HYBRID     = 0,  // Historical same-TOD blocks, fall back to ATR
   RANGE_HISTORICAL = 1,  // Historical same-TOD blocks only
   RANGE_ATR_LOCKED = 2   // ATR-scaled full-block extension only
  };

input group                 "=== Range prediction (ongoing block, non-repaint) ==="
input bool                  InpShowRangePred   = true;          // Predict block high/low
input ENUM_RANGE_MODE       InpRangeMode       = RANGE_HYBRID;  // Prediction model
input int                   InpRangeLookback   = 20;            // Historical days (same-TOD blocks)
input int                   InpRangeAtrBars    = 14;            // ATR lookback (bars, for fallback)
input double                InpRangeK          = 1.0;           // Extension multiplier (1=expected, 2=wide)
input color                 InpRangeHighColor  = clrAqua;       // Predicted-high line colour
input color                 InpRangeLowColor   = clrMagenta;    // Predicted-low line colour
input ENUM_LINE_STYLE       InpRangeStyle      = STYLE_DOT;     // Line style
input int                   InpRangeWidth      = 1;             // Line width
input bool                  InpRangeLabel      = true;          // Show value labels
input int                   InpRangeFontSize   = 8;             // Label font size

input group                 "=== Candle counts per block ==="
enum ENUM_COUNT_POSITION
  {
   COUNT_POS_TOP    = 0,   // Near chart top
   COUNT_POS_BOTTOM = 1    // Near chart bottom
  };
input bool                  InpShowCounts     = true;          // Show bullish/bearish counts
input ENUM_COUNT_POSITION   InpCountPosition  = COUNT_POS_TOP; // Label position
input color                 InpBullCountColor = clrLime;       // Bullish count colour
input color                 InpBearCountColor = clrCrimson;    // Bearish count colour
input int                   InpCountFontSize  = 9;             // Count font size
input string                InpCountFont      = "Arial";       // Count font

input group                 "=== Object naming ==="
input string                InpObjPrefix      = "TB_";         // Object name prefix

//--- Globals
int    g_block_minutes = 60;
int    g_vwap_handle   = INVALID_HANDLE;
double g_vwap[];           // aligned 1:1 with time[] (index 0 = oldest)

//--- Projection cache (refreshed on new-bar / full redraw, reused on ticks)
double   g_proj_vol_so_far    = 0.0;  // sum volume from day-start up to last bar
double   g_proj_tpv_so_far    = 0.0;  // = VWAP_current * V_so_far
double   g_proj_vol_remaining = 0.0;  // expected volume from "now" to horizon
datetime g_proj_horizon_end   = 0;    // block_end or day_end at cache time
datetime g_proj_now_tod       = 0;    // now-of-day seconds at cache time
bool     g_proj_valid         = false;

//--- Range-prediction caches.
//    ATR cache (refreshed on new-bar) — used when InpRangeMode touches ATR.
double   g_range_atr          = 0.0;
bool     g_range_valid        = false;

//    Locked prediction cache: fixed at block start, never recomputed during
//    the block. This is what guarantees the lines don't repaint.
datetime g_pred_block_start   = 0;
datetime g_pred_block_end     = 0;
double   g_pred_high          = 0.0;
double   g_pred_low           = 0.0;
bool     g_pred_valid         = false;

//+------------------------------------------------------------------+
//| Initialisation                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_block_minutes = ResolveBlockMinutes();
   if(g_block_minutes <= 0)
     {
      Print("TimeBlocks: invalid block size (", g_block_minutes, " min). Aborting.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("TimeBlocks (%d min)", g_block_minutes));

   if(InpShowVwapBalance || InpShowVwapProj)
     {
      g_vwap_handle = iCustom(_Symbol, _Period, InpVwapIndicator,
                              (int)InpVwapPriceType);
      if(g_vwap_handle == INVALID_HANDLE)
         Print("TimeBlocks: failed to load VWAP indicator '",
               InpVwapIndicator, "'. VWAP features disabled.");
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialisation                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_vwap_handle != INVALID_HANDLE)
     {
      IndicatorRelease(g_vwap_handle);
      g_vwap_handle = INVALID_HANDLE;
     }
   DeleteAllOwnedObjects();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int      rates_total,
                const int      prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
   if(rates_total <= 0)
      return(0);

   // Refresh VWAP buffer (if any feature needs it). Bail out and retry next
   // tick if the VWAP indicator hasn't finished calculating for every bar.
   const bool want_vwap = ((InpShowVwapBalance || InpShowVwapProj) &&
                           g_vwap_handle != INVALID_HANDLE);
   if(want_vwap)
     {
      if(BarsCalculated(g_vwap_handle) < rates_total)
         return(prev_calculated);
      if(ArraySize(g_vwap) != rates_total)
         ArrayResize(g_vwap, rates_total);
      if(CopyBuffer(g_vwap_handle, 0, 0, rates_total, g_vwap) < rates_total)
         return(prev_calculated);
     }

   // Full redraw on first run, parameter change, or new bar.
   if(prev_calculated == 0 || prev_calculated != rates_total)
     {
      RedrawAll(rates_total, time, open, high, low, close, want_vwap);
      if(want_vwap && InpShowVwapProj)
         RefreshProjectionCache(rates_total, time, close, tick_volume, volume);
      if(InpShowRangePred)
        {
         RefreshAtrCache(rates_total, high, low, close);
         RefreshRangePredictionCache(rates_total, time, open, high, low);
         DrawRangePrediction();
        }
     }
   else if(InpShowHighLow || InpShowCounts || want_vwap)
     {
      UpdateOngoingBlock(rates_total, time, open, high, low, close, want_vwap);
     }

   // Tick path: only the VWAP projection is price-driven. The range
   // prediction is intentionally NOT recomputed per tick — its cache is
   // locked at block start so the lines never shift intrabar.
   if(want_vwap && InpShowVwapProj)
      DrawVwapProjection(rates_total, close);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Input change triggers full rebuild                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
      ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Resolve block size (minutes) from preset + custom input          |
//+------------------------------------------------------------------+
int ResolveBlockMinutes()
  {
   if(InpBlockPreset == BLOCK_CUSTOM)
      return(InpCustomMinutes);
   return((int)InpBlockPreset);
  }

//+------------------------------------------------------------------+
//| Redraw all time-block lines                                      |
//+------------------------------------------------------------------+
void RedrawAll(const int rates_total,
               const datetime &time[],
               const double   &open[],
               const double   &high[],
               const double   &low[],
               const double   &close[],
               const bool     want_vwap)
  {
   DeleteAllOwnedObjects();

   const int block_seconds = g_block_minutes * 60;
   if(block_seconds <= 0)
      return;

   // Determine bar-range window [range_from, range_to].
   int first_idx = 0;
   if(InpBarCount > 0 && InpBarCount < rates_total)
      first_idx = rates_total - InpBarCount;

   const datetime range_from = time[first_idx];
   const datetime now        = TimeCurrent();

   // Upper bound of the drawing window:
   //   - latest bar time (history)
   //   - extended forward to end-of-day if InpDrawForward and the queried
   //     day is today/ongoing, so unfinished sessions still get lines.
   datetime range_to = time[rates_total - 1];
   if(InpDrawForward && range_to < now)
      range_to = now;

   // Single scanning cursor reused across days; bars are ordered ascending.
   int cursor = first_idx;

   switch(InpDayMode)
     {
      case DAY_TODAY:
        {
         const datetime day_start = DayStart(now);
         DrawDay(day_start, range_from, range_to, block_seconds, /*allow_forward=*/true,
                 rates_total, time, open, high, low, close, want_vwap, cursor);
         break;
        }

      case DAY_SPECIFIC:
        {
         const datetime target = ParseDateInput(InpTargetDate);
         if(target == 0)
           {
            Print("TimeBlocks: cannot parse InpTargetDate '", InpTargetDate,
                  "'. Expected format YYYY.MM.DD");
            return;
           }
         const datetime day_start = DayStart(target);
         const bool forward_ok = (day_start == DayStart(now));
         DrawDay(day_start, range_from, range_to, block_seconds, forward_ok,
                 rates_total, time, open, high, low, close, want_vwap, cursor);
         break;
        }

      case DAY_ALL:
        {
         datetime d = DayStart(range_from);
         const datetime d_end = DayStart(range_to) + 86400;
         while(d < d_end)
           {
            const bool forward_ok = (d == DayStart(now));
            DrawDay(d, range_from, range_to, block_seconds, forward_ok,
                    rates_total, time, open, high, low, close, want_vwap, cursor);
            d += 86400;
           }
         break;
        }
     }

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Draw all block boundaries + high/low lines for a single day      |
//+------------------------------------------------------------------+
void DrawDay(const datetime day_start,
             const datetime range_from,
             const datetime range_to,
             const int      block_seconds,
             const bool     allow_forward,
             const int      rates_total,
             const datetime &time[],
             const double   &open[],
             const double   &high[],
             const double   &low[],
             const double   &close[],
             const bool     want_vwap,
             int            &cursor)
  {
   const datetime day_end = day_start + 86400;
   const datetime now     = TimeCurrent();

   for(datetime t = day_start; t < day_end; t += block_seconds)
     {
      const datetime t_next = t + block_seconds;
      const bool     is_future_boundary = (t > now);

      // --- Vertical boundary ---
      bool draw_v = true;
      if(t < range_from)
         draw_v = false;
      else if(is_future_boundary)
         draw_v = (allow_forward && InpDrawForward);
      else if(t > range_to)
         draw_v = false;

      if(draw_v)
        {
         DrawVLine(t);
         if(InpShowLabels)
            DrawLabel(t);
        }

      // --- Per-block stats: high/low + candle counts + VWAP balance ---
      if(InpShowHighLow || InpShowCounts || want_vwap)
        {
         const bool is_ongoing = (t <= now && now < t_next);
         const bool is_past    = (t_next <= now);
         const bool in_range   = (t_next > range_from && t < range_to + block_seconds);

         if((is_past && in_range) || is_ongoing)
           {
            double hi, lo, vwap_bal;
            int    bull, bear;
            bool   vwap_ok;
            if(BlockStats(t, t_next, rates_total, time, open, high, low, close,
                          g_vwap, want_vwap, cursor,
                          hi, lo, bull, bear, vwap_bal, vwap_ok))
              {
               if(InpShowHighLow)      DrawBlockHL(t, t_next, hi, lo);
               if(InpShowCounts)       DrawBlockCounts(t, t_next, bull, bear);
               if(want_vwap && vwap_ok) DrawBlockVwapBalance(t, t_next, vwap_bal);
              }
           }
        }

      // Always draw the closing boundary for the last block of the day.
      if(t_next >= day_end)
        {
         bool draw_end = true;
         if(t_next < range_from)
            draw_end = false;
         else if(t_next > now)
            draw_end = (allow_forward && InpDrawForward);
         else if(t_next > range_to)
            draw_end = false;

         if(draw_end)
           {
            DrawVLine(t_next);
            if(InpShowLabels)
               DrawLabel(t_next);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Scan bars in [block_start, block_end) for high/low.              |
//| 'cursor' is moved forward; callers walk blocks in time order.    |
//+------------------------------------------------------------------+
bool BlockStats(const datetime block_start,
                const datetime block_end,
                const int      rates_total,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const double   &vwap[],
                const bool     want_vwap,
                int            &cursor,
                double         &out_high,
                double         &out_low,
                int            &out_bull,
                int            &out_bear,
                double         &out_vwap_balance,
                bool           &out_vwap_valid)
  {
   while(cursor < rates_total && time[cursor] < block_start)
      cursor++;

   if(cursor >= rates_total || time[cursor] >= block_end)
     {
      out_vwap_balance = 0.0;
      out_vwap_valid   = false;
      return(false);
     }

   out_high = high[cursor];
   out_low  = low[cursor];
   out_bull = 0;
   out_bear = 0;

   double sum_up   = 0.0;   // Σ (high - vwap)
   double sum_down = 0.0;   // Σ (vwap - low)
   bool   any_vwap = false;

   const bool vwap_ok = (want_vwap && ArraySize(vwap) == rates_total);

   while(cursor < rates_total && time[cursor] < block_end)
     {
      if(high[cursor]  > out_high) out_high = high[cursor];
      if(low[cursor]   < out_low)  out_low  = low[cursor];
      if(close[cursor] > open[cursor])      out_bull++;
      else if(close[cursor] < open[cursor]) out_bear++;

      if(vwap_ok)
        {
         const double v = vwap[cursor];
         if(v != EMPTY_VALUE && v > 0.0)
           {
            sum_up   += (high[cursor] - v);
            sum_down += (v - low[cursor]);
            any_vwap  = true;
           }
        }
      cursor++;
     }

   out_vwap_balance = sum_up - sum_down;
   out_vwap_valid   = any_vwap;
   return(true);
  }

//+------------------------------------------------------------------+
//| Create / update the high & low trend-lines for one block         |
//+------------------------------------------------------------------+
void DrawBlockHL(const datetime block_start,
                 const datetime block_end,
                 const double   hi,
                 const double   lo)
  {
   const long key = (long)block_start;
   const string hi_name = InpObjPrefix + "HI_" + (string)key;
   const string lo_name = InpObjPrefix + "LO_" + (string)key;

   UpsertHLine(hi_name, block_start, block_end, hi, InpHighColor);
   UpsertHLine(lo_name, block_start, block_end, lo, InpLowColor);
  }

//+------------------------------------------------------------------+
//| Create-or-update one horizontal trend line segment               |
//+------------------------------------------------------------------+
void UpsertHLine(const string   name,
                 const datetime t1,
                 const datetime t2,
                 const double   price,
                 const color    clr)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);

   ObjectSetInteger(0, name, OBJPROP_TIME,  0, t1);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(0, name, OBJPROP_TIME,  1, t2);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 1, price);

   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE,      InpHLStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,      InpHLWidth);
   ObjectSetInteger(0, name, OBJPROP_BACK,       InpHLBack);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT,   false);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT,  false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
   ObjectSetString (0, name, OBJPROP_TOOLTIP,
                    StringFormat("%s\n%s", DoubleToString(price, _Digits),
                                 TimeToString(t1, TIME_DATE|TIME_MINUTES)));
  }

//+------------------------------------------------------------------+
//| Create / update the bullish + bearish count labels for one block |
//+------------------------------------------------------------------+
void DrawBlockCounts(const datetime block_start,
                     const datetime block_end,
                     const int      bull,
                     const int      bear)
  {
   const long     key     = (long)block_start;
   const datetime mid_t   = block_start + (block_end - block_start) / 2;
   const string   bull_nm = InpObjPrefix + "CB_" + (string)key;
   const string   bear_nm = InpObjPrefix + "CS_" + (string)key;

   const double pmax  = ChartGetDouble(0, CHART_PRICE_MAX);
   const double pmin  = ChartGetDouble(0, CHART_PRICE_MIN);
   const double range = pmax - pmin;
   if(range <= 0.0)
      return;

   double y_bull, y_bear;
   if(InpCountPosition == COUNT_POS_TOP)
     {
      y_bull = pmax - range * 0.04;  // bull on top
      y_bear = pmax - range * 0.08;  // bear below
     }
   else
     {
      y_bull = pmin + range * 0.08;  // bull above
      y_bear = pmin + range * 0.04;  // bear at bottom
     }

   UpsertCountText(bull_nm, mid_t, y_bull, IntegerToString(bull), InpBullCountColor);
   UpsertCountText(bear_nm, mid_t, y_bear, IntegerToString(bear), InpBearCountColor);
  }

//+------------------------------------------------------------------+
//| Create-or-update a count text object                             |
//+------------------------------------------------------------------+
void UpsertCountText(const string   name,
                     const datetime t,
                     const double   price,
                     const string   text,
                     const color    clr)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);

   ObjectSetInteger(0, name, OBJPROP_TIME,  0, t);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 0, price);
   ObjectSetString (0, name, OBJPROP_TEXT,     text);
   ObjectSetString (0, name, OBJPROP_FONT,     InpCountFont);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpCountFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR,    clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,   ANCHOR_CENTER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,   true);
   ObjectSetInteger(0, name, OBJPROP_BACK,     false);
  }

//+------------------------------------------------------------------+
//| Create / update the VWAP-balance label for one block             |
//+------------------------------------------------------------------+
void DrawBlockVwapBalance(const datetime block_start,
                          const datetime block_end,
                          const double   balance)
  {
   const long     key   = (long)block_start;
   const datetime mid_t = block_start + (block_end - block_start) / 2;
   const string   nm    = InpObjPrefix + "VB_" + (string)key;

   const double pmax  = ChartGetDouble(0, CHART_PRICE_MAX);
   const double pmin  = ChartGetDouble(0, CHART_PRICE_MIN);
   const double range = pmax - pmin;
   if(range <= 0.0)
      return;

   const double price = (InpCountPosition == COUNT_POS_TOP)
                        ? pmax - range * 0.12
                        : pmin + range * 0.12;

   color clr;
   if(balance > 0.0)      clr = InpVwapPosColor;
   else if(balance < 0.0) clr = InpVwapNegColor;
   else                   clr = InpVwapZeroColor;

   const string prefix = (balance > 0.0) ? "+" : "";
   const string text   = prefix + DoubleToString(balance, InpVwapDecimals);

   if(ObjectFind(0, nm) < 0)
      ObjectCreate(0, nm, OBJ_TEXT, 0, mid_t, price);

   ObjectSetInteger(0, nm, OBJPROP_TIME,  0, mid_t);
   ObjectSetDouble (0, nm, OBJPROP_PRICE, 0, price);
   ObjectSetString (0, nm, OBJPROP_TEXT,     text);
   ObjectSetString (0, nm, OBJPROP_FONT,     InpVwapFont);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, InpVwapFontSize);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,    clr);
   ObjectSetInteger(0, nm, OBJPROP_ANCHOR,   ANCHOR_CENTER);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN,   true);
   ObjectSetInteger(0, nm, OBJPROP_BACK,     false);
  }

//+------------------------------------------------------------------+
//| Pick bar volume: prefer tick, fall back to real                  |
//+------------------------------------------------------------------+
double PickVolume(const long tv, const long v)
  {
   if(tv > 0) return((double)tv);
   if(v  > 0) return((double)v);
   return(0.0);
  }

//+------------------------------------------------------------------+
//| Refresh VWAP-projection cache. Runs on new bar / first run.      |
//|                                                                  |
//| Builds:                                                          |
//|   TPV_so_far = VWAP_current * V_so_far    (recovered from VWAP)  |
//|   V_so_far   = Σ volume from day-start up to last bar             |
//|   V_remaining = mean Σ volume across last N historical days       |
//|                 over the same time-of-day window [now, horizon). |
//| Falls back to pace extrapolation if no historical data available.|
//+------------------------------------------------------------------+
void RefreshProjectionCache(const int rates_total,
                            const datetime &time[],
                            const double   &close[],
                            const long     &tick_volume[],
                            const long     &volume[])
  {
   g_proj_valid = false;
   if(ArraySize(g_vwap) != rates_total)
      return;

   const datetime now       = TimeCurrent();
   const datetime day_start = DayStart(now);
   const int      block_s   = g_block_minutes * 60;
   if(block_s <= 0)
      return;

   // Block containing 'now'.
   const int      elapsed   = (int)(now - day_start);
   const int      idx       = elapsed / block_s;
   const datetime block_end = day_start + (datetime)(idx + 1) * block_s;

   const datetime horizon_end = InpVwapProjToDayEnd
                                ? day_start + 86400
                                : block_end;

   const datetime now_tod     = now - day_start;
   const datetime horizon_tod = horizon_end - day_start;

   if(horizon_tod <= now_tod)
      return;  // nothing left to project

   // Volume so far today (walk backward from tail to first bar of today).
   double v_so_far = 0.0;
   for(int i = rates_total - 1; i >= 0; i--)
     {
      if(time[i] < day_start) break;
      v_so_far += PickVolume(tick_volume[i], volume[i]);
     }

   // Recover Σ(TPV * Vol) so-far from the VWAP buffer.
   const double vwap_now = g_vwap[rates_total - 1];
   if(vwap_now == EMPTY_VALUE || vwap_now <= 0.0 || v_so_far <= 0.0)
      return;

   g_proj_vol_so_far = v_so_far;
   g_proj_tpv_so_far = vwap_now * v_so_far;

   // Historical volume profile — rolling mean over last N same-time-of-day windows.
   double sum_remaining = 0.0;
   int    days_used     = 0;
   for(int d = 1; d <= InpVwapProjLookback; d++)
     {
      const datetime hist_day = day_start - (datetime)d * 86400;
      const datetime from_t   = hist_day + now_tod;
      const datetime to_t     = hist_day + horizon_tod;

      double day_vol = 0.0;
      bool   any     = false;
      for(int i = 0; i < rates_total; i++)
        {
         if(time[i] >= to_t) break;
         if(time[i] <  from_t) continue;
         day_vol += PickVolume(tick_volume[i], volume[i]);
         any = true;
        }
      if(any)
        {
         sum_remaining += day_vol;
         days_used++;
        }
     }

   if(days_used > 0)
     {
      g_proj_vol_remaining = sum_remaining / days_used;
     }
   else
     {
      // Fallback: extrapolate current-session pace.
      const double elapsed_d = (double)now_tod;
      const double remain_d  = (double)(horizon_tod - now_tod);
      g_proj_vol_remaining = (elapsed_d > 0.0)
                             ? v_so_far * (remain_d / elapsed_d)
                             : 0.0;
     }

   g_proj_horizon_end = horizon_end;
   g_proj_now_tod     = now_tod;
   g_proj_valid       = true;
  }

//+------------------------------------------------------------------+
//| Draw / update the simulated-VWAP line for the ongoing block.     |
//| Uses cached V_so_far / TPV_so_far / V_remaining + latest price.  |
//+------------------------------------------------------------------+
void DrawVwapProjection(const int      rates_total,
                        const double   &close[])
  {
   if(!g_proj_valid || rates_total <= 0)
      return;

   const double denom = g_proj_vol_so_far + g_proj_vol_remaining;
   if(denom <= 0.0)
      return;

   const double price_proj = close[rates_total - 1];
   const double sim_vwap   = (g_proj_tpv_so_far + price_proj * g_proj_vol_remaining) / denom;

   const datetime t1 = TimeCurrent();
   const datetime t2 = g_proj_horizon_end;
   if(t2 <= t1)
      return;

   const string name = InpObjPrefix + "VP_ongoing";

   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t1, sim_vwap, t2, sim_vwap);

   ObjectSetInteger(0, name, OBJPROP_TIME,  0, t1);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 0, sim_vwap);
   ObjectSetInteger(0, name, OBJPROP_TIME,  1, t2);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 1, sim_vwap);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      InpVwapProjColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE,      InpVwapProjStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,      InpVwapProjWidth);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT,   false);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT,  false);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
   ObjectSetString (0, name, OBJPROP_TOOLTIP,
                    StringFormat("Sim VWAP %s\nto %s",
                                 DoubleToString(sim_vwap, _Digits),
                                 TimeToString(t2, TIME_DATE|TIME_MINUTES)));

   if(InpVwapProjLabel)
     {
      const string lbl = InpObjPrefix + "VP_label";
      if(ObjectFind(0, lbl) < 0)
         ObjectCreate(0, lbl, OBJ_TEXT, 0, t2, sim_vwap);

      ObjectSetInteger(0, lbl, OBJPROP_TIME,  0, t2);
      ObjectSetDouble (0, lbl, OBJPROP_PRICE, 0, sim_vwap);
      ObjectSetString (0, lbl, OBJPROP_TEXT,
                       "~VWAP " + DoubleToString(sim_vwap, _Digits));
      ObjectSetString (0, lbl, OBJPROP_FONT,     "Arial");
      ObjectSetInteger(0, lbl, OBJPROP_FONTSIZE, InpVwapProjFontSize);
      ObjectSetInteger(0, lbl, OBJPROP_COLOR,    InpVwapProjColor);
      ObjectSetInteger(0, lbl, OBJPROP_ANCHOR,   ANCHOR_LEFT);
      ObjectSetInteger(0, lbl, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lbl, OBJPROP_HIDDEN,   true);
      ObjectSetInteger(0, lbl, OBJPROP_BACK,     false);
     }

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Refresh ATR cache (new-bar only). Classic Wilder true-range mean |
//| over the last InpRangeAtrBars bars.                              |
//+------------------------------------------------------------------+
void RefreshAtrCache(const int rates_total,
                     const double &high[],
                     const double &low[],
                     const double &close[])
  {
   g_range_valid = false;
   g_range_atr   = 0.0;

   const int n = InpRangeAtrBars;
   if(n <= 0 || rates_total < n + 1)
      return;

   double sum_tr = 0.0;
   const int start = rates_total - n;
   for(int i = start; i < rates_total; i++)
     {
      const double hl  = high[i] - low[i];
      const double hpc = MathAbs(high[i] - close[i - 1]);
      const double lpc = MathAbs(low[i]  - close[i - 1]);
      const double tr  = MathMax(hl, MathMax(hpc, lpc));
      sum_tr += tr;
     }

   g_range_atr   = sum_tr / n;
   g_range_valid = (g_range_atr > 0.0);
  }

//+------------------------------------------------------------------+
//| Refresh the locked range-prediction cache. Runs on new bar only. |
//|                                                                  |
//| Non-repaint by construction: the predicted high / low are        |
//| anchored at this block's OPEN (first bar of block) and sized by  |
//| historical same-time-of-day block statistics (or ATR as a        |
//| fallback). Neither input changes during the block, so the lines  |
//| stay fixed until the next block begins.                          |
//|                                                                  |
//| Historical model (InpRangeLookback days back):                   |
//|   up_dev   = mean( block_high - block_open )   (same TOD window) |
//|   dn_dev   = mean( block_open  - block_low  )                    |
//|   pred_hi  = block_open + K * up_dev                             |
//|   pred_lo  = block_open - K * dn_dev                             |
//|                                                                  |
//| ATR fallback (Parkinson / Brownian-extreme scaling):             |
//|   ext      = 0.5 * ATR * sqrt(N_bars_in_block) * K               |
//|   pred_hi  = block_open + ext                                    |
//|   pred_lo  = block_open - ext                                    |
//+------------------------------------------------------------------+
void RefreshRangePredictionCache(const int rates_total,
                                 const datetime &time[],
                                 const double   &open[],
                                 const double   &high[],
                                 const double   &low[])
  {
   g_pred_valid = false;
   if(rates_total <= 0)
      return;

   const int block_s = g_block_minutes * 60;
   if(block_s <= 0)
      return;

   const datetime now       = TimeCurrent();
   const datetime day_start = DayStart(now);

   // Respect DAY_SPECIFIC scoping: only predict when the queried day is today.
   if(InpDayMode == DAY_SPECIFIC)
     {
      const datetime target = ParseDateInput(InpTargetDate);
      if(target == 0 || DayStart(target) != day_start)
         return;
     }

   const int      idx     = (int)(now - day_start) / block_s;
   const datetime t_start = day_start + (datetime)idx * block_s;
   const datetime t_end   = t_start + block_s;

   // Block open = open of the earliest bar whose timestamp falls in the block.
   double block_open = 0.0;
   bool   have_open  = false;
   for(int i = 0; i < rates_total; i++)
     {
      if(time[i] <  t_start) continue;
      if(time[i] >= t_end)   break;
      block_open = open[i];
      have_open  = true;
      break;
     }
   if(!have_open)
      return;

   // --- Historical same-TOD block statistics ---
   const datetime tod_start = t_start - day_start;
   const datetime tod_end   = t_end   - day_start;

   double sum_up = 0.0, sum_dn = 0.0;
   int    days_used = 0;

   if(InpRangeMode != RANGE_ATR_LOCKED && InpRangeLookback > 0)
     {
      for(int d = 1; d <= InpRangeLookback; d++)
        {
         const datetime hday   = day_start - (datetime)d * 86400;
         const datetime hstart = hday + tod_start;
         const datetime hend   = hday + tod_end;

         double h_open = 0.0, h_high = 0.0, h_low = 0.0;
         bool   h_found = false;
         for(int i = 0; i < rates_total; i++)
           {
            if(time[i] >= hend)  break;
            if(time[i] <  hstart) continue;
            if(!h_found)
              {
               h_open  = open[i];
               h_high  = high[i];
               h_low   = low[i];
               h_found = true;
              }
            else
              {
               if(high[i] > h_high) h_high = high[i];
               if(low[i]  < h_low)  h_low  = low[i];
              }
           }
         if(h_found)
           {
            sum_up += (h_high - h_open);
            sum_dn += (h_open - h_low);
            days_used++;
           }
        }
     }

   double pred_high = 0.0, pred_low = 0.0;
   bool   have_pred = false;

   if(days_used > 0)
     {
      const double mean_up = sum_up / days_used;
      const double mean_dn = sum_dn / days_used;
      pred_high = block_open + InpRangeK * mean_up;
      pred_low  = block_open - InpRangeK * mean_dn;
      have_pred = true;
     }
   else if(InpRangeMode != RANGE_HISTORICAL && g_range_valid)
     {
      // ATR fallback: symmetric extension anchored at block open.
      const int period_sec = PeriodSeconds(_Period);
      if(period_sec > 0)
        {
         const double n_total = (double)block_s / (double)period_sec;
         if(n_total > 0.0)
           {
            const double ext = 0.5 * g_range_atr * MathSqrt(n_total) * InpRangeK;
            pred_high = block_open + ext;
            pred_low  = block_open - ext;
            have_pred = true;
           }
        }
     }

   if(!have_pred)
      return;

   g_pred_block_start = t_start;
   g_pred_block_end   = t_end;
   g_pred_high        = pred_high;
   g_pred_low         = pred_low;
   g_pred_valid       = true;
  }

//+------------------------------------------------------------------+
//| Draw the locked predicted-high / predicted-low lines. Idempotent |
//| — safe to call any number of times per bar; the cache values are |
//| fixed for the whole block so no visible movement occurs.         |
//+------------------------------------------------------------------+
void DrawRangePrediction()
  {
   if(!g_pred_valid)
      return;

   UpsertPredLine(InpObjPrefix + "PH_ongoing",
                  g_pred_block_start, g_pred_block_end,
                  g_pred_high, InpRangeHighColor);
   UpsertPredLine(InpObjPrefix + "PL_ongoing",
                  g_pred_block_start, g_pred_block_end,
                  g_pred_low,  InpRangeLowColor);

   if(InpRangeLabel)
     {
      UpsertPredLabel(InpObjPrefix + "PH_label", g_pred_block_end, g_pred_high,
                      "~H " + DoubleToString(g_pred_high, _Digits),
                      InpRangeHighColor);
      UpsertPredLabel(InpObjPrefix + "PL_label", g_pred_block_end, g_pred_low,
                      "~L " + DoubleToString(g_pred_low, _Digits),
                      InpRangeLowColor);
     }

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Create-or-update a dotted prediction trend line segment          |
//+------------------------------------------------------------------+
void UpsertPredLine(const string   name,
                    const datetime t1,
                    const datetime t2,
                    const double   price,
                    const color    clr)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);

   ObjectSetInteger(0, name, OBJPROP_TIME,  0, t1);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(0, name, OBJPROP_TIME,  1, t2);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 1, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE,      InpRangeStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,      InpRangeWidth);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT,   false);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT,  false);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
  }

//+------------------------------------------------------------------+
//| Create-or-update a prediction value label                        |
//+------------------------------------------------------------------+
void UpsertPredLabel(const string   name,
                     const datetime t,
                     const double   price,
                     const string   text,
                     const color    clr)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);

   ObjectSetInteger(0, name, OBJPROP_TIME,  0, t);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 0, price);
   ObjectSetString (0, name, OBJPROP_TEXT,     text);
   ObjectSetString (0, name, OBJPROP_FONT,     "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpRangeFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR,    clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,   ANCHOR_LEFT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,   true);
   ObjectSetInteger(0, name, OBJPROP_BACK,     false);
  }

//+------------------------------------------------------------------+
//| Recompute stats of the block currently containing TimeCurrent    |
//+------------------------------------------------------------------+
void UpdateOngoingBlock(const int rates_total,
                        const datetime &time[],
                        const double   &open[],
                        const double   &high[],
                        const double   &low[],
                        const double   &close[],
                        const bool     want_vwap)
  {
   const int block_seconds = g_block_minutes * 60;
   if(block_seconds <= 0)
      return;

   const datetime now     = TimeCurrent();
   const datetime now_day = DayStart(now);

   if(InpDayMode == DAY_SPECIFIC)
     {
      const datetime target = ParseDateInput(InpTargetDate);
      if(target == 0 || DayStart(target) != now_day)
         return;
     }

   const int      elapsed = (int)(now - now_day);
   const int      idx     = elapsed / block_seconds;
   const datetime t_start = now_day + (datetime)idx * block_seconds;
   const datetime t_end   = t_start + block_seconds;

   const bool vwap_ok = (want_vwap && ArraySize(g_vwap) == rates_total);

   double hi = 0, lo = 0;
   int    bull = 0, bear = 0;
   double sum_up = 0.0, sum_down = 0.0;
   bool   any_vwap = false;
   bool   found = false;

   for(int i = rates_total - 1; i >= 0; i--)
     {
      if(time[i] >= t_end)  continue;
      if(time[i] <  t_start) break;
      if(!found)
        {
         hi = high[i];
         lo = low[i];
         found = true;
        }
      else
        {
         if(high[i] > hi) hi = high[i];
         if(low[i]  < lo) lo = low[i];
        }
      if(close[i] > open[i])      bull++;
      else if(close[i] < open[i]) bear++;

      if(vwap_ok)
        {
         const double v = g_vwap[i];
         if(v != EMPTY_VALUE && v > 0.0)
           {
            sum_up   += (high[i] - v);
            sum_down += (v - low[i]);
            any_vwap  = true;
           }
        }
     }

   if(!found)
      return;

   if(InpShowHighLow)               DrawBlockHL(t_start, t_end, hi, lo);
   if(InpShowCounts)                DrawBlockCounts(t_start, t_end, bull, bear);
   if(want_vwap && any_vwap)        DrawBlockVwapBalance(t_start, t_end, sum_up - sum_down);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Create / update one vertical line                                |
//+------------------------------------------------------------------+
void DrawVLine(const datetime t)
  {
   const string name = InpObjPrefix + "L_" + (string)(long)t;

   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_VLINE, 0, t, 0);
   else
      ObjectMove(0, name, 0, t, 0);

   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpLineColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, InpLineStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, InpLineWidth);
   ObjectSetInteger(0, name, OBJPROP_BACK,  InpLineBack);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetString (0, name, OBJPROP_TOOLTIP, TimeToString(t, TIME_DATE|TIME_MINUTES));
  }

//+------------------------------------------------------------------+
//| Create / update one time label (OBJ_TEXT pinned near chart top)  |
//+------------------------------------------------------------------+
void DrawLabel(const datetime t)
  {
   const string name = InpObjPrefix + "T_" + (string)(long)t;

   // Anchor near the top of the visible price range.
   const double price = ChartGetDouble(0, CHART_PRICE_MAX) -
                        (ChartGetDouble(0, CHART_PRICE_MAX) -
                         ChartGetDouble(0, CHART_PRICE_MIN)) * 0.02;

   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
   else
     {
      ObjectMove(0, name, 0, t, price);
     }

   ObjectSetString (0, name, OBJPROP_TEXT, TimeToString(t, TIME_MINUTES));
   ObjectSetString (0, name, OBJPROP_FONT, InpLabelFont);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpLabelFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpLabelColor);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
  }

//+------------------------------------------------------------------+
//| Delete every object created by this indicator                    |
//+------------------------------------------------------------------+
void DeleteAllOwnedObjects()
  {
   ObjectsDeleteAll(0, InpObjPrefix, -1, -1);
  }

//+------------------------------------------------------------------+
//| Floor a datetime to 00:00:00 of its day (server time)            |
//+------------------------------------------------------------------+
datetime DayStart(const datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;
   return(StructToTime(dt));
  }

//+------------------------------------------------------------------+
//| Parse "YYYY.MM.DD" or "YYYY.MM.DD HH:MM" user input              |
//+------------------------------------------------------------------+
datetime ParseDateInput(const string s)
  {
   const string trimmed = s;
   if(StringLen(trimmed) == 0)
      return(0);
   return(StringToTime(trimmed));   // returns 0 on failure
  }
//+------------------------------------------------------------------+
