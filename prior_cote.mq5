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
input int      days          = 5;
input bool     _close        = true; //Previus day close price
input color    inpCloseColor = clrWhite; // close Color
input bool     max           = true; //Previus day max price
input color    inpMaxColor   = clrBlue; // Max Color
input bool     min           = true; //Previus day min price
input color    inpMinColor   = clrRed; // Min Color

double   closePrices[];
datetime closePricesStartTime[];
datetime closePricesEndTime[];
string   closePricesLineObj[];

double   maxPrices[];
datetime maxPricesStartTime[];
datetime maxPricesEndTime[];
string   maxPricesLineObj[];

double   minPrices[];
datetime minPricesStartTime[];
datetime minPricesEndTime[];
string   minPricesLineObj[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---
   
   ArrayResize(closePrices, days+2);
   ArrayResize(closePricesStartTime, days+2);
   ArrayResize(closePricesEndTime, days+2);
   ArrayResize(closePricesLineObj, days+1);

   ArrayResize(maxPrices, days+2);
   ArrayResize(maxPricesStartTime, days+2);
   ArrayResize(maxPricesEndTime, days+2);
   ArrayResize(maxPricesLineObj, days+1);
   
   ArrayResize(minPrices, days+2);
   ArrayResize(minPricesStartTime, days+2);
   ArrayResize(minPricesEndTime, days+2);
   ArrayResize(minPricesLineObj, days+1);

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
   
   //--- Create Max sup/res line
   
   if (max || min || _close) {
      
      //contagem de dias para guardar o valor das máximas na variável -> maxPrices
      int daysCount = 0;

      MqlDateTime previusDateTime;
      TimeToStruct(time[rates_total - 1], previusDateTime);
   
      for (int i = rates_total - 1; i >= 0; i--) {
   
         //atribui o valor do primeiro candle do dia como maxima/minima
         //se for a primenra interação do for
         if (i == rates_total - 1) {
            
            if (max) {
               maxPricesStartTime[daysCount] = time[i];
               maxPrices[daysCount] = high[i];
            }
            
            if (min) {
               minPricesStartTime[daysCount] = time[i];
               minPrices[daysCount] = low[i];
            }
            
            if (_close) closePricesStartTime[daysCount] = time[i];

         }
         
         //verifica se a máxima do candle atual é maior q
         //a maxima do dia atual, caso afirmativo, a máxima do
         //candle atual será a máxima do dia
         if (max) {
            if (high[i] > maxPrices[daysCount]) {
               maxPrices[daysCount] = high[i];
            }
         }
         //verifica se a minima do candle atual é menor q
         //a minima do dia atual
         if (min) {
            if (low[i] < minPrices[daysCount]) {
               minPrices[daysCount] = low[i];
            }
         }
         
         //cria a variável -> currentDateTime <- para posteriormente 
         //verificar o momento em que trocamos de dia
         MqlDateTime currentDateTime;
         TimeToStruct(time[i], currentDateTime);
         
         //valida se trocamos de dia e atribui as referencias do dia seguinte/anterior
         if (previusDateTime.day  > currentDateTime.day ||
             previusDateTime.mon  > currentDateTime.mon ||
             previusDateTime.year > currentDateTime.year) {
             
             if (max) maxPricesEndTime[daysCount] = time[i+1];
             if (min) minPricesEndTime[daysCount] = time[i+1];
             if (_close) {
               closePricesEndTime[daysCount] = time[i+1];
               closePrices[daysCount] = close[i];
             }
                
             daysCount++;
             
             if (max) {
               maxPricesStartTime[daysCount] = time[i];
               maxPrices[daysCount] = high[i];
             }
             
             if (min) {
               minPricesStartTime[daysCount] = time[i];
               minPrices[daysCount] = low[i];
             }
             
             if (_close) closePricesStartTime[daysCount] = time[i];
         }

         //variável axiliar que guarda o valor do DateTime do candle atual
         previusDateTime = currentDateTime;
         
         //quando todos os dados solicitados pelo usuario forem atribuidos
         //a suas respectivas variaveis traçamos linhas de sup/res
         if (daysCount > days) {
            
            //verifica se existem linhas d sup/res traçadas
            if (maxPricesLineObj[0] != NULL ||
                minPricesLineObj[0] != NULL ||
                closePricesLineObj[0] != NULL) {
               //percorre as linhas
               for (int j = 0; j <= days-1; j++) {
                  //deleta as linhas anteriormente traçadas
                  if (max) ObjectDelete(ChartID(), maxPricesLineObj[j]);
                  if (min) ObjectDelete(ChartID(), minPricesLineObj[j]);
                  if (_close) ObjectDelete(ChartID(), closePricesLineObj[j]);
               }
            
            }
            
            //percorre e traça as linhas de sup/res atualizadas
            for (int j = 0; j <= days-1; j++) {
               if (max) {
                  string maxLineName = DoubleToString(maxPrices[j+1]);
                  ObjectCreate(ChartID(),
                               maxLineName,
                               OBJ_TREND,
                               0,
                               maxPricesEndTime[j],
                               maxPrices[j+1],
                               maxPricesStartTime[j],
                               maxPrices[j+1]);
                  //adiciona cor ao linha
                  ObjectSetInteger(0, maxLineName, OBJPROP_COLOR, inpMaxColor);
                  //cria uma referência dos nomes das
                  //linhas para posteriormente deleta-las
                  maxPricesLineObj[j] = maxLineName;
               }
               if (min) {
                  string minLineName = DoubleToString(minPrices[j+1]);
                  ObjectCreate(ChartID(),
                               minLineName,
                               OBJ_TREND,
                               0,
                               minPricesEndTime[j],
                               minPrices[j+1],
                               minPricesStartTime[j],
                               minPrices[j+1]);
                  //adiciona cor ao linha
                  ObjectSetInteger(0, minLineName, OBJPROP_COLOR, inpMinColor);
                  //cria uma referência dos nomes das
                  //linhas para posteriormente deleta-las
                  maxPricesLineObj[j] = minLineName;
               }
               if (_close) {
                  string closeLineName = DoubleToString(closePrices[j+1]);
                  ObjectCreate(ChartID(),
                               closeLineName,
                               OBJ_TREND,
                               0,
                               closePricesEndTime[j],
                               closePrices[j],
                               closePricesStartTime[j],
                               closePrices[j]);
                  //adiciona cor ao linha
                  ObjectSetInteger(0, closeLineName, OBJPROP_COLOR, inpCloseColor);
                  //cria uma referência dos nomes das
                  //linhas para posteriormente deleta-las
                  closePricesLineObj[j] = closeLineName;
               }
            }

            break;
         }

      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+