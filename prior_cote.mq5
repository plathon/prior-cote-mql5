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

double maxPrices[];
datetime maxPricesStartTime[];
datetime maxPricesEndTime[];
string maxPricesLineObj[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---

   ArrayResize(maxPrices, days+2);
   ArrayResize(maxPricesStartTime, days+2);
   ArrayResize(maxPricesEndTime, days+2);
   ArrayResize(maxPricesLineObj, days+1);

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

   if (max) {
      
      bool fetchLastday = false;
      
      //contagem de dias para guardar o valor das máximas na variável -> maxPrices
      int daysCount = 0;

      MqlDateTime previusDateTime;
      TimeToStruct(time[rates_total - 1], previusDateTime);
   
      for (int i = rates_total - 1; i >= 0; i--) {
   
         //atribui o valor do primeiro candle do dia como maxima 
         //se for a primenra interação do for
         if (i == rates_total - 1) {
            maxPricesStartTime[daysCount] = time[i];
            maxPrices[daysCount] = high[i];
         }
         
         //verifica se a máxima do candle atual é maior q
         //a maxima do dia atual, caso afirmativo, a máxima do
         //candle atual será a máxima do dia
         if (high[i] > maxPrices[daysCount]) {
            maxPrices[daysCount] = high[i];
         }
         
         //cria a variável -> currentDateTime <- para posteriormente 
         //verificar o momento em que trocamos de dia
         MqlDateTime currentDateTime;
         TimeToStruct(time[i], currentDateTime);
         
         //valida se trocamos de dia e atribui os valores do dia seguinte
         if (previusDateTime.day  > currentDateTime.day ||
             previusDateTime.mon  > currentDateTime.mon ||
             previusDateTime.year > currentDateTime.year) {
             maxPricesEndTime[daysCount] = time[i+1];
             daysCount++;
             maxPricesStartTime[daysCount] = time[i];
             maxPrices[daysCount] = high[i];
         }

         //variável axiliar que guarda o valor do DateTime do candle atual
         previusDateTime = currentDateTime;
         
         //quando todos os dados solicitados pelo usuario forem atribuidos
         //a suas respectivas variaveis traçamos linhas de sup/res
         if (daysCount > days) {
            
            //verifica se existem linhas d sup/res traçadas
            if (maxPricesLineObj[0] != NULL) {
               //percorre as linhas
               for (int j = 0; j <= days-1; j++) {
                  //deleta as linhas anteriormente traçadas
                  ObjectDelete(ChartID(), maxPricesLineObj[j]);
               }
            
            }
            
            //percorre e traça as linhas de sup/res atualizadas
            for (int j = 0; j <= days-1; j++) {
               string lineName = DoubleToString(maxPrices[j+1]);
               ObjectCreate(ChartID(),
                            lineName,
                            OBJ_TREND,
                            0,
                            maxPricesEndTime[j],
                            maxPrices[j+1],
                            maxPricesStartTime[j],
                            maxPrices[j+1]);
               //cria uma referência dos nomes das
               //linhas para posteriormente deleta-las
               maxPricesLineObj[j] = lineName;
            }

            break;
         }

      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| calculate max of the previous day                                |
//+------------------------------------------------------------------+
void CalcMaxPreviusDay () {}
//+----------------------------------------------------------------------+
//| Retorna true se uma nova barra aparece para o par de símbolo/período |
//+----------------------------------------------------------------------+
bool isNewBar()
  {
//--- lembrar o tempo de abertura da última barra na variável estática
   static datetime last_time = 0;
//--- tempo corrente
   datetime lastbar_time = SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time == 0) {
      //--- definir tempo e sair
      last_time = lastbar_time;
      return(false);
   }

//--- se o tempo é diferente
   if(last_time != lastbar_time){
      //--- memorizar tempo e retornar true
      last_time = lastbar_time;
      return(true);
   }
//--- se passarmos desta linha e a barra não é nova, retorna false
   return(false);
  }
//+------------------------------------------------------------------+