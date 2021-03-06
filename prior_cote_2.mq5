//+------------------------------------------------------------------+
//|                                                 prior_cote_2.mq5 |
//|                                   Copyright 2019, Renan Plathon. |
//|                                       https://github.com/plathon |
//+------------------------------------------------------------------+
#property copyright " Copyright 2019, Renan Plathon."
#property link      "https://github.com/plathon"
#property version   "1.00"
#property indicator_chart_window
//--- input parameters
input int      days = 5;
input bool     open_line = false;
input bool     close_line = false;
input bool     high_line = true;
input bool     low_line = true;
input color    open_line_color = clrGreen;//previus high color
input color    close_line_color = clrRed;//previus high color
input color    high_line_color = clrDeepSkyBlue;//previus high color
input color    low_line_color = clrBlack;//previus high color
//--- indicator internal variables
MqlRates rates[];
datetime anchor_point_one[];
datetime anchor_point_two[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArraySetAsSeries(rates, true);
   ArrayResize(anchor_point_one, days+1);
   ArrayResize(anchor_point_two, days);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int copied = CopyRates(Symbol(), PERIOD_D1, 0, days + 2, rates);
   if (copied > 0) {
      int daysCount = 0;
      bool firstCandle = true;
      MqlDateTime previusDatetime;
      MqlDateTime currentDatetime;
      TimeToStruct(time[rates_total - 1], previusDatetime);
      
      for (int i = rates_total - 1; i > 0; i--) {
         if (daysCount < days) {
            TimeToStruct(time[i], currentDatetime);
            //valida se estamos no primeira barra do grafico
             if (previusDatetime.day  == currentDatetime.day &&
                   previusDatetime.mon == currentDatetime.mon &&
                   previusDatetime.year == currentDatetime.year && firstCandle) {
                     anchor_point_one[daysCount] = time[i];
                     firstCandle = false;
                   }
                   
             if (previusDatetime.day != currentDatetime.day) {
               anchor_point_two[daysCount] = time[i+1];
               daysCount++;
               anchor_point_one[daysCount] = time[i];
               //reset previus datetime
               TimeToStruct(time[i], previusDatetime);
             }
         } else
            break;
      }
      
      daysCount = 0;
      for(int i = 0; i < days; i++) {
         string lineName = "";
         double open_price;
         double close_price;
         double high_price;
         double low_price;
         
         MqlDateTime datetimeToValidateWeekends;
         TimeToStruct(rates[i+1].time, datetimeToValidateWeekends);
         
         if (datetimeToValidateWeekends.day_of_week == 0) {
            open_price = rates[i+2].open;
            close_price = rates[i+2].close;
            high_price = rates[i+2].high;
            low_price = rates[i+2].low;
         } else {
            open_price = rates[i+1].open;
            close_price = rates[i+1].close;
            high_price = rates[i+1].high;
            low_price = rates[i+1].low;
         }
         
         //previus open
         if (open_line)
         {
            lineName = "prior-cote-open-day-" + IntegerToString(daysCount);
            ObjectCreate(ChartID(),
                         lineName,
                         OBJ_TREND,
                         0,
                         anchor_point_one[i],
                         open_price,
                         anchor_point_two[i],
                         open_price);
            //adiciona cor ao linha
            ObjectSetInteger(0, lineName, OBJPROP_COLOR, open_line_color);
         }
         
         //previus close
         if (close_line)
         {
            lineName = "prior-cote-close-day-" + IntegerToString(daysCount);
            ObjectCreate(ChartID(),
                         lineName,
                         OBJ_TREND,
                         0,
                         anchor_point_one[i],
                         close_price,
                         anchor_point_two[i],
                         close_price);
            //adiciona cor ao linha
            ObjectSetInteger(0, lineName, OBJPROP_COLOR, close_line_color);
         }
         
         //previus high
         if (high_line)
         {
            lineName = "prior-cote-high-day-" + IntegerToString(daysCount);
            ObjectCreate(ChartID(),
                         lineName,
                         OBJ_TREND,
                         0,
                         anchor_point_one[i],
                         high_price,
                         anchor_point_two[i],
                         high_price);
            //adiciona cor ao linha
            ObjectSetInteger(0, lineName, OBJPROP_COLOR, high_line_color);
         }
         
         //previus low
         if (low_line)
         {
            //previus low
            lineName = "prior-cote-low-day-" + IntegerToString(daysCount);
            ObjectCreate(ChartID(),
                         lineName,
                         OBJ_TREND,
                         0,
                         anchor_point_one[i],
                         low_price,
                         anchor_point_two[i],
                        low_price);
            //adiciona cor ao linha
            ObjectSetInteger(0, lineName, OBJPROP_COLOR, low_line_color);  
         }
         
         daysCount++;
         
      }
    } else
      Print("Falha ao receber dados históricos para o símbolo ",Symbol());
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   for (int i = 0; i < days; i++) {
      ObjectDelete(ChartID(), "prior-cote-open-day-" + IntegerToString(i));
      ObjectDelete(ChartID(), "prior-cote-close-day-" + IntegerToString(i));
      ObjectDelete(ChartID(), "prior-cote-high-day-" + IntegerToString(i));
      ObjectDelete(ChartID(), "prior-cote-low-day-" + IntegerToString(i));
   }
}