#property copyright "��������� ��������"
#property link      "http://www.mql4.com/ru/users/incognitos"
// v1.1

//----------------------------------------------------------------------------------------------------------------------------------+
// ������ ������ ��� ������ ������������� (����������. � ����. �� ��������� ����) ������ ����� ����� ����.                          |
// ������ ��� ������� ���� �� ����� � >95% �������� �����������.                                                                   |
// (������ �������� ����� �������? ������ 90% - ��� 1 ��� �� 10, � ������������� ���� ������������ �� 10 ���� ������ ������ �����.) |
// ��������: ������������� ���������� ���� (�� PeriodDays) ����������� � ���/����. ����� ��� - �������� ������ � ������ �������.    |
// � ������� ��� ���������� ����� ����������, ������� � �������� ��� ������� ���������� ���������.                                  | 
// ������ �������� � ������ ������� ����� (00:00).                                                                                  |                                                                                                                  
// 2 �������� ���������: ��������� ��� �������.                                                                                     |
//----------------------------------------------------------------------------------------------------------------------------------+
#property indicator_chart_window

   extern   int   PeriodDays=20;  // ������ ����.  1 = �����, 20 = ������ ������� ������ (�����)

// �������� �������. ������ � ������� ������� - ����������. � ����. �������������, �����-���� - ������� �����   
   extern   bool  ShowRectangle = true;  
// �������� ����� 
   extern   bool  ShowLinesAvrDaysVol = false;  // �������� ����� ������������� ���.
   extern   bool  ShowLinesMaxDaysVol = false;  // �������� ����� ����.������� ���.
// ���� � ����� �����
   extern   color Color = LightBlue;     // �� ��������� ���� LightBlue, ��������. ��������� ������, ��������� ������ ��� �� ����
   extern   int   Style = STYLE_DASH;  

   extern   bool  ShowVolsInComment=false;  // ���������� ������������ �������� �������������


//+------------------------------------------------------------------+
int init()
{
   // ���� ���.����������� ��������, ���������� ����������� ������� �� ��������� �� ��������
   //if (ShowRectangle) {ShowLinesAvrDaysVol=false; ShowLinesMaxDaysVol=false;} 
    
   ObjectDelete ("������������� �����");
   ObjectDelete ("������������� ����"); 
   ObjectDelete ("����������.������������� �����");
   ObjectDelete ("����������.������������� ����");
   ObjectDelete ("����.����.������������� �����");
   ObjectDelete ("����.����.������������� ����");
}

int deinit()
{
 if (ShowRectangle){
   ObjectDelete ("������������� �����");
   ObjectDelete ("������������� ����"); 
 } else {
   ObjectDelete ("����������.������������� �����");
   ObjectDelete ("����������.������������� ����");
   ObjectDelete ("����.����.������������� �����");
   ObjectDelete ("����.����.������������� ����");}
 if (ShowVolsInComment)  Comment("");  
}


//+------------------------------------------------------------------+
int start()
{   
   if (!IsNewBarM1()) return;   // ������ ��� � ������, ���� �� ������� ��� ����� ����������; �������� ��������� ������ ���� M1
   
   string volcomment = LevelsDayVolatility (PeriodDays, ShowRectangle, ShowLinesAvrDaysVol,ShowLinesMaxDaysVol, Color,Style);

   if (ShowVolsInComment)  Comment(volcomment);     
   
}
//+------------------------------------------------------------------+



//---------------------------------------------------------------------------------------------------+
// �����:  ��������� ��������,  http://www.mql4.com/ru/users/incognitos                              |
// --------------------------------------------------------------------------------------------------|
// ������ ������ ��� ������ ������������� (�� DayVlt ����) �������������, ������ ����� ����� ����    |
//---------------------------------------------------------------------------------------------------+ 
#define SEKUNDvSUTKAH 86400   // ����� ������ � ������ = 60*60*24
string LevelsDayVolatility (int DayVlt = 5, //  DayVlt - ���-�� ���� �� ������� ����������� ������������� �������������
         bool ShowRectangle=true, bool ShowLinesAvrDaysVol=false, bool ShowLinesMaxDaysVol=false, 
         int Color=Black, int Style=STYLE_DASH)   
{  
   datetime timeDayBegin = iTime(NULL,PERIOD_D1,0);    // ����� ������ ������� �����
   int ibarM1DayBegin = iBarShift(NULL,PERIOD_M1,timeDayBegin);   // ����� ���� ������ ���� ����� (M1 - ���������� ��������� �� �������� ������������ ��� ����) 
   double DayMin = iLow(NULL,PERIOD_M1, iLowest(NULL,PERIOD_M1,MODE_LOW,ibarM1DayBegin));   // ��������� ������� ���
   double DayMax = iHigh(NULL,PERIOD_M1,iHighest(NULL,PERIOD_M1,MODE_HIGH,ibarM1DayBegin)); // ��������� ������� ����
   double avgDaysVltPts = iATR(NULL,PERIOD_D1,DayVlt,1);   // ����������.�������������
   double maxDaysVltPts=MaxDaysVolatility(DayVlt);         // ����.����.�������������
      
   if (ShowRectangle){
      rectangle("������������� �����", timeDayBegin, DayMin+avgDaysVltPts, timeDayBegin+SEKUNDvSUTKAH, DayMin+maxDaysVltPts, Color, Style, 1);
      rectangle("������������� ����",  timeDayBegin, DayMax-avgDaysVltPts, timeDayBegin+SEKUNDvSUTKAH, DayMax-maxDaysVltPts, Color, Style, 1);
      }

   if (ShowLinesAvrDaysVol){
      writeline ("����������.������������� �����", DayMin + avgDaysVltPts, Color, Style, 1);  // ������.����.������������� �����
      writeline ("����������.������������� ����",  DayMax - avgDaysVltPts, Color, Style, 1);  // ������.����.������������� ����  
      }   
   if (ShowLinesMaxDaysVol){
      writeline ("����.����.������������� �����", DayMin + maxDaysVltPts, Color, Style, 1);  // ������.����.������������� �����
      writeline ("����.����.������������� ����",  DayMax - maxDaysVltPts, Color, Style, 1);  // ������.����.������������� ����   
      }
   
   // �������
   /*Print (
   " maxDaysVltPts=",DS(maxDaysVltPts),    
   " avgDaysVltPts=",DS(avgDaysVltPts),
   " ThisDayMin=",DS(DayMin),
   " ThisDayMax=",DS(DayMax),
   " ibarlow=",ibarlow," time=",TimeToString(iTime(NULL,PERIOD_M1,ibarlow)),
   " ibarhi=",ibarhi," time=",TimeToString(iTime(NULL,PERIOD_M1,ibarhi)),
   " ibarM1DayBegin=",ibarM1DayBegin,
   " timeDayBegin=",TimeToString(timeDayBegin),
   " MaxDaysVolatility =",DS(MaxDaysVolatility(5))
   );*/
   
   if (ShowVolsInComment)  
      string comment = StringConcatenate("����������.������������� =",DS(avgDaysVltPts)," ��, ����.����.������������� =",DS(maxDaysVltPts)," ��");
   return(comment);
}

double MaxDaysVolatility (int DayVlt = 5)   //  DayVlt - ���-�� ���� �� ������� ����������� max.������� �������������
{  
   if (DayVlt<=0) {Alert("��������� �������������: DayVlt ������ ���� >= 0");}
   double  maxdayvol;
   for (int iday=1; iday<=DayVlt; iday++) { 
      double maxofday=0, minofday=0;
      double dayvol = iHigh(NULL,PERIOD_D1,iday) - iLow(NULL,PERIOD_D1,iday);  
      if (dayvol > maxdayvol) maxdayvol=dayvol;} // int ibarmaxvol=iday;}
   return (maxdayvol);
}


//---------------------------------------------------------------------------------------------/
// ��������� �������������� � �������� ����:
//---------------------------------------------------------------------------------------------/
void rectangle (string name, datetime time1, double Price1, datetime time2, double Price2, color Color, int Style, int Width)
{
 ObjectDelete(name);
 ObjectCreate (name, OBJ_RECTANGLE, 0, time1, Price1, time2, Price2);
 ObjectSet(name, OBJPROP_COLOR, Color);
 ObjectSet(name, OBJPROP_STYLE, Style);
 ObjectSet(name, OBJPROP_WIDTH, Width);
}

//---------------------------------------------------------------------------------------------/
// ��������� ��������. ����� � �������� ����:
//---------------------------------------------------------------------------------------------/
void writeline (string Linename, double Price, color Color, int Style, int Width)
{
 ObjectDelete(Linename);
 ObjectCreate(Linename, OBJ_HLINE, 0, 0, Price);
 ObjectSet(Linename, OBJPROP_COLOR, Color);
 ObjectSet(Linename, OBJPROP_STYLE, Style);
 ObjectSet(Linename, OBJPROP_WIDTH, Width);
}
//---------------------------------------------------------------------------------------------/


//+-------------------------------------------------------------------------------------+
//| ���������� ����������� ���� � ��������� � ������ ������ Digits
//+-------------------------------------------------------------------------------------+
string DS(double x) {return(DoubleToStr(x,Digits));}  


// ----------------------------------------------------------------------------|
// ������ ��������� ������� ��� � ������, ���� �� ������� ��� ����� ���������� |
// �������������:  if (!RunOnceMinute()) return;                               |
//-----------------------------------------------------------------------------+
bool IsNewBarM1() {   
   static datetime dPrevtime;  
   if (dPrevtime==0  ||  dPrevtime!=iTime(NULL,PERIOD_M1,0)) 
      {dPrevtime=iTime(NULL,PERIOD_M1,0);  
      return (true);}
   else return (false);  
}

