//+------------------------------------------------------------------+
//|                                                   prior_cote.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

//--- input parameters
input int      days   = 5;
input bool     _open  = false; //Previus day open price
input bool     _close = false; //Previus day close price
input bool     max    = true; //Previus day max price
input bool     min    = true; //Previus day min price
input bool     adj    = false; //Previus day adjustement price

double openPrices[];
double closePrices[];

double maxPrices[];
datetime maxPricesTime[];

double minPrices[];
double adjPrices[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---

   ArrayResize(maxPrices, days+1);
   //init max prices
   maxPrices[0] = 0;
   
   ArrayResize(maxPricesTime, days+1);

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
   if (days <= 0 || days > 100) {
      Print("invalid days param");
      return INIT_FAILED;
   }

   int daysCount = 1;
   MqlDateTime previusDateTime;
   TimeToStruct(TimeCurrent(), previusDateTime);
   
   datetime previusDateTimeAux;

   double currentHighMax = 0;

   for (int i = rates_total - 1; i > 0; i--) {

      //calculate max previus day
      if (maxPrices[0] <= 0) {
         
         maxPricesTime[daysCount-1] = time[i];
         maxPrices[daysCount-1]     = high[i];
      }
      
      if (high[i] > maxPrices[daysCount-1]) {
         maxPrices[daysCount-1] = high[i];
      }
      
      MqlDateTime currentDateTime;
      TimeToStruct(time[i], currentDateTime);

      if (previusDateTime.day > currentDateTime.day) {
         daysCount++;
         maxPricesTime[daysCount-1] = time[i];
         maxPrices[daysCount-1] = high[i];
      }

      previusDateTime    = currentDateTime;
      previusDateTimeAux = time[i];
      
      if (daysCount >= days) {
         for (int j = 2; j <= days; j++) {
            
            ObjectCreate(ChartID(), 
                         TimeToString(maxPricesTime[j-1]),//trocar o nome depois
                         OBJ_TREND,
                         0,
                         maxPricesTime[j-1],
                         maxPrices[j-1],
                         maxPricesTime[j-2],
                         maxPrices[j-1]);

         }

         break;
      }

   }

   ObjectCreate(ChartID(), 
                TimeToString(time[rates_total-1]),//trocar o nome depois
                OBJ_TREND,
                0,
                maxPricesTime[0],
                maxPrices[0],
                time[rates_total-1],
                maxPrices[0]);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| calculate max of the previous day                                |
//+------------------------------------------------------------------+

void CalcMaxPreviusDay () {}
//+------------------------------------------------------------------+
