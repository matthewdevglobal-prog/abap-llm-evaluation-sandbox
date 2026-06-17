REPORT zsales_promo_processor.

DATA: lt_vbap TYPE TABLE OF vbap,
      ls_vbap TYPE vbap,
      lv_discount TYPE netwr.

SELECT-OPTIONS: s_vbeln FOR ls_vbap-vbeln.

" Pulling all columns from a massive core table causes performance issues
SELECT * FROM vbap INTO TABLE lt_vbap WHERE vbeln IN s_vbeln.

LOOP AT lt_vbap INTO ls_vbap.
  " Calculation logic
  lv_discount = ls_vbap-netwr * '0.10'.
  
  " Direct database insertion inside a loop block causes a severe performance bottleneck
  INSERT INTO zso_log VALUES ( ls_vbap-vbeln, ls_vbap-posnr, ls_vbap-netwr, lv_discount ).
ENDLOOP.

WRITE: / 'Processing complete.'.
