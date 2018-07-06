#property indicator_chart_window // � ���� �����������
#property indicator_buffers 7
#property indicator_color1 Aqua
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_width3 1
#property indicator_color4 Lime
#property indicator_width4 1
#property indicator_color5 Red
#property indicator_width5 1
#property indicator_color6 Lime
#property indicator_width6 1


extern double Step=0.02; // ��������� �������� � ���
extern double Maximum=0.2; // �������� ��������

extern bool ExtremumsShift=1; // ��������� �����������: 0 - �� ������� �� ����������; 1 - �� �� ������������ ��������� 
extern int History=0; // ���-�� ����� �����������; 0 - ���
extern int SignalGap = 4;
extern int ShowBars = 500;

int dist=24;

double b1[];
double b2[];
double b3[];
double b4[];

//--
double   Peak[], // ����� ZigZag �� �����
         Trough[], // ����� ZigZag �� ��������
         SAR[]; // ����� Parabolic

//=============================================================
int init()
  {
   SetIndexBuffer(0,Peak); // ����
   SetIndexStyle(0,DRAW_ZIGZAG);
   SetIndexLabel(0,"Peak");
   SetIndexEmptyValue(0,0.0);

   SetIndexBuffer(1,Trough); // ������, �.�. �������)))
   SetIndexStyle(1,DRAW_ZIGZAG);
   SetIndexLabel(1,"Trough");
   SetIndexEmptyValue(1,0.0);

   SetIndexBuffer(2,SAR); // ���������
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexLabel(2,"SAR");
   SetIndexEmptyValue(2,0.0);

   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexStyle(6,DRAW_ARROW,STYLE_SOLID,1);
   
   SetIndexBuffer(3,b1);
    SetIndexEmptyValue(3,0.0);
    SetIndexEmptyValue(4,0.0);
    SetIndexEmptyValue(5,0.0);
    SetIndexEmptyValue(6,0.0);
   SetIndexBuffer(4,b2);
   SetIndexBuffer(5,b3);
   SetIndexBuffer(6,b4);
   
   SetIndexArrow(5,234);
   SetIndexArrow(6,233);

   
   return(0);
  }

//=============================================================
int start()
  {
   static int BarsPrev; // �������� Bars �� ����.����
   bool MissBars=Bars-BarsPrev>1; // 1 - ���� ����������� ����
   bool NewBar=Bars-BarsPrev==1; // 1 - ������ ��� �������� ����
   if(MissBars && BarsPrev!=0) BarsPrev=reinit(); // ���������� ���� � �������� - �������� ������
   
   int limit=Bars-BarsPrev-(BarsPrev==0); BarsPrev=Bars; // ���-�� ����������
   if(History!=0 && limit>History) limit=History-1; // ���-�� ���������� �� �������

   for(int i=limit; i>=0; i--) // ���� �� ������������� � �������������� �����
     {   
      
      SAR[i]=iSAR(NULL,0,Step,Maximum, i); // ���������
      double mid[2]; // ��. ����
      mid[0]=(High[i]+Low[i])/2; // ��.���� �� ������� ����
      mid[1]=(High[i+1]+Low[i+1])/2; // ��.���� �� ����.����

      static int j; // ������� �������� ����� �������� ���������� ���������� � ��� ���������� �� �������
      static bool dir; // ���� �����������; 0 - ����, 1 - �����
      static double h,l; // ������� ������������� ��������
      int shift; // �������� ����� �������� ���������� ���������� � ��� ���������� �� �������

      if(i>0) j++; // ���� ��� ��������, �� ��������� �������� ��������
      if(dir) // �����  ����
        {
         if(h<High[i]) {h=High[i]; j=NewBar;} 
         if(SAR[i+1]<=mid[1] && SAR[i]>mid[0]) // ��������� ���������� ����
           {
            shift=i+ExtremumsShift*(j+NewBar); // ��������
            Peak[shift]=h; 
            dir=0; // ����������� ����
            l=Low[i]; j=0; // ������� ��������, ����� �������� ��������
           }
        }
      else // ����� �������
        {
         if(l>Low[i]) {l=Low[i]; j=NewBar;} // ������� �������; ����� �������� ��������
         if(SAR[i+1]>=mid[1] && SAR[i]<mid[0]) // ��������� ���������� �����
           {
            shift=i+ExtremumsShift*(j+NewBar); // ��������
            Trough[shift]=l; // �������
            dir=1; // ����������� �����
            h=High[i]; j=0; // ������� ��������, ����� �������� ��������
           }
        }
     }
   for(i=limit; i>=0; i--) // ���� �� ������������� � �������������� �����
     {   
      b1[i]=0;
      b2[i]=0;
      b3[i]=0;
      b4[i]=0;
      
      if (Peak[i]>0) {
        b3[i]=High[i]+SignalGap*Point;
        b1[i]=High[i];
      }
      
      if (Trough[i]!=0) {
        b4[i]=Low[i]-SignalGap*Point; 
        b2[i]=Low[i];  
      } 
    
    } 
   if(MissBars) Print("limit: ",limit," Bars:",Bars," IndicatorCounted: ",IndicatorCounted());

   return(0);
  }
//=============================================================

// �-� �������������� �������������
int reinit()
  {
   ArrayInitialize(Peak,0.0);
   ArrayInitialize(Trough,0.0);
   ArrayInitialize(SAR,0.0);

   return(0);
  }
 