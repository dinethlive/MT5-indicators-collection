//+------------------------------------------------------------------+
//|                                                         VWAP.mq5 |
//|       Daily Volume-Weighted Average Price (single red dash line) |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022-2026, Dineth Pramodya (@binarydina, @dinethlive)"
#property link      "http://www.dineth.lk"
#property version   "2.00"
#property description "Daily VWAP"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "VWAP Daily"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_DASH
#property indicator_width1  2

//+------------------------------------------------------------------+
//| Typical-price selector                                           |
//+------------------------------------------------------------------+
enum PRICE_TYPE
  {
   OPEN,                 // Open
   CLOSE,                // Close
   HIGH,                 // High
   LOW,                  // Low
   OPEN_CLOSE,           // (Open + Close) / 2
   HIGH_LOW,             // (High + Low) / 2
   CLOSE_HIGH_LOW,       // (Close + High + Low) / 3
   OPEN_CLOSE_HIGH_LOW   // (Open + Close + High + Low) / 4
  };

input PRICE_TYPE Price_Type = CLOSE_HIGH_LOW;  // Price source

double VWAP_Buffer_Daily[];

//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   SetIndexBuffer(0, VWAP_Buffer_Daily, INDICATOR_DATA);
   PlotIndexSetString(0, PLOT_LABEL, "VWAP Daily");
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Typical price                                                    |
//+------------------------------------------------------------------+
double TypicalPrice(const double o, const double h, const double l, const double c)
  {
   switch(Price_Type)
     {
      case OPEN:                return(o);
      case CLOSE:               return(c);
      case HIGH:                return(h);
      case LOW:                 return(l);
      case OPEN_CLOSE:          return((o + c) * 0.5);
      case HIGH_LOW:            return((h + l) * 0.5);
      case CLOSE_HIGH_LOW:      return((c + h + l) / 3.0);
      case OPEN_CLOSE_HIGH_LOW: return((o + c + h + l) * 0.25);
     }
   return((c + h + l) / 3.0);
  }

//+------------------------------------------------------------------+
//| Same calendar day?                                               |
//+------------------------------------------------------------------+
bool SameDay(const datetime a, const datetime b)
  {
   MqlDateTime ma, mb;
   TimeToStruct(a, ma);
   TimeToStruct(b, mb);
   return(ma.year == mb.year && ma.mon == mb.mon && ma.day == mb.day);
  }

//+------------------------------------------------------------------+
//| Pick volume: prefer tick, fall back to real                      |
//+------------------------------------------------------------------+
double PickVolume(const long tv, const long v)
  {
   if(tv > 0) return((double)tv);
   if(v  > 0) return((double)v);
   return(0.0);
  }

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[])
  {
   if(rates_total <= 0)
      return(0);

   // Restart index: always recompute the current day from its first bar,
   // so the forming bar's VWAP stays accurate.
   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;
   if(start < 0) start = 0;

   // Walk back to the start of the day containing 'start'.
   while(start > 0 && SameDay(time[start], time[start - 1]))
      start--;

   double sum_tpv = 0.0;
   double sum_vol = 0.0;

   for(int i = start; i < rates_total; i++)
     {
      if(i > 0 && !SameDay(time[i], time[i - 1]))
        {
         sum_tpv = 0.0;
         sum_vol = 0.0;
        }

      const double tp = TypicalPrice(open[i], high[i], low[i], close[i]);
      const double vv = PickVolume(tick_volume[i], volume[i]);

      sum_tpv += tp * vv;
      sum_vol += vv;

      VWAP_Buffer_Daily[i] = (sum_vol > 0.0) ? (sum_tpv / sum_vol) : EMPTY_VALUE;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
