USE [uchet]
GO
/****** Object:  StoredProcedure [dbo].[ad_PSR_report_f1412_1]    Script Date: 09/20/2018 12:23:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from doc_ref a inner join doc_ref b on a.link=b.code where a.type_doc like '%Р%' and b.type_doc like '%Р%'
--select * from doc_ref where type_doc like '%%'


--select * from columns


--select * from doc_ref where code=797997
--- * from doc_ref where code=

--select * from  where code=798430
--select * from doc_ref where code=798429
--### 5%
--select * from doc_ref where code=798430
--exec ad_PSR_report_f1412_1 '01.05.2018','01.09.2018'
ALTER procedure [dbo].[ad_PSR_report_f1412_1]
@date1 datetime,
@date2 datetime

as
begin

WITH rn 
     AS (SELECT dr.link, 
                Sum(amount) amount 
         FROM   doc_ref dr 
                INNER JOIN document dc 
                        ON dr.code = dc.upcode 
                INNER JOIN nomencl n 
                        ON dc.tovar = n.code 
         WHERE  dr.type_doc LIKE 'Р%Н%' 
                AND n.upcode <> 19350 
         GROUP  BY dr.link), 
     psr 
     AS (SELECT ( CASE 
                    WHEN Charindex('%', a.NAME) <> 0 THEN Abs(a.total) * 100 / 
                    CONVERT(INT, Rtrim(Ltrim( 
                    Substring(a.NAME, 
                    Charindex('%', a.NAME) 
                    - 2, 2)))) 
                    ELSE 0 
                  END )    totalpsr, 
                a.code, 
                a.nn, 
                a.date, 
                a.total, 
                a.NAME, 
                a.type_doc, 
                 
                rn.amount   amountrn 
                 
         FROM   doc_ref a 
                INNER JOIN rn 
                        ON a.link = rn.link 
         WHERE  a.type_doc LIKE '%ПСР%' /*a.code=798422*/ 
                
                AND a.link <> 0 
                AND rn.link <> 0 and
                a.date BETWEEN @date1 AND @date2 
         /*ORDER  BY a.code*/), 
         
         
          pn 
     AS (SELECT dr.link,  0 amountrn--, 
                --Sum(amount) amount 
         FROM   doc_ref dr 
                /*INNER JOIN document dc 
                        ON dr.code = dc.upcode 
                INNER JOIN nomencl n 
                        ON dc.tovar = n.code*/ 
         WHERE  dr.type_doc LIKE 'П%Н%' 
                --AND n.upcode <> 19350 
         GROUP  BY dr.link),
         psr1 
     AS (SELECT ( CASE 
                    WHEN Charindex('%', a.NAME) <> 0 THEN Abs(a.total) * 100 / 
                    CONVERT(INT, Rtrim(Ltrim( 
                    Substring(a.NAME, 
                    Charindex('%', a.NAME) 
                    - 2, 2)))) 
                    ELSE 0 
                  END )    totalpsr, 
                a.code, 
                a.nn, 
                a.date, 
                a.total, 
                a.NAME, 
                a.type_doc, 
                 
                pn.amountrn   amountrn 
                 
         FROM   doc_ref a 
                INNER JOIN pn 
                        ON a.link = pn.link 
         WHERE  a.type_doc LIKE '%ПСР%' /*a.code=798422*/ 
                
                AND a.link <> 0 
                AND pn.link <> 0 and
               a.date   BETWEEN @date1 AND @date2 
         /*ORDER  BY a.code*/),
          rn1 
     AS (SELECT dr.link,MAX(dr.date) date1, 
                Sum(amount) amount 
         FROM   doc_ref dr 
                INNER JOIN document dc 
                        ON dr.code = dc.upcode 
                INNER JOIN nomencl n 
                        ON dc.tovar = n.code 
         WHERE  dr.type_doc LIKE 'Р%Н%' 
                AND n.upcode <> 19350 
         GROUP  BY dr.link),
         
     psr2 
     AS (SELECT ( CASE 
                    WHEN Charindex('%', a.NAME) <> 0 THEN Abs(a.total) * 100 / 
                    CONVERT(INT, Rtrim(Ltrim( 
                    Substring(a.NAME, 
                    Charindex('%', a.NAME) 
                    - 2, 2)))) 
                    ELSE 0 
                  END )    totalpsr, 
                a.code, 
                a.nn, 
                a.date, 
                a.total, 
                a.NAME, 
                a.type_doc, 
                --rn1.date1,
                
             rn1.amount   amountrn ,
             (case when (DATEPART(m,a.date)<>DATEPART(M,rn1.date1)) /*OR (DATEPART(y,a.date)<>DATEPART(y,rn1.date1))*/ then 1 else 0 end) OtherMonth
                 
         FROM   doc_ref a 
                INNER JOIN rn1 
                        ON a.link = rn1.link 
         WHERE  a.type_doc LIKE '%ПСР%' /*a.code=798422*/ 
                
                AND a.link <> 0 
                AND rn1.link <> 0 and
                a.date BETWEEN @date1 AND @date2 )    
        
        
      
SELECT *,0 as GetPN,0 OtherMonth,1 as EqSum 
FROM   psr 
WHERE  totalpsr <> amountrn 
       --AND ( date BETWEEN @date1 AND @date2 ) 
       
       
   union all
   
   SELECT *,1 as GetPN ,0 OtherMonth,0 as EqSum
FROM   psr1
union all
select totalpsr, 
                code, 
                nn, 
                date, 
                total, 
                NAME, 
                type_doc, 
                --rn1.date1,
                
                amountrn ,0 as GetPN,OtherMonth,0 as  EqSum 
from psr2 where OtherMonth=1
 
order by GetPN
           
 end