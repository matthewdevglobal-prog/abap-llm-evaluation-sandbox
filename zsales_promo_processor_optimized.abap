REPORT zsales_promo_processor.

TYPES: BEGIN OF ty_vbap_subset,
         vbeln TYPE vbap-vbeln,
         posnr TYPE vbap-posnr,
         netwr TYPE vbap-netwr,
       END OF ty_vbap_subset.

DATA: lt_vbap_data TYPE STANDARD TABLE OF ty_vbap_subset,
      lt_log_bulk  TYPE STANDARD TABLE OF zso_log,
      ls_log_row   TYPE zso_log.

SELECT-OPTIONS: s_vbeln FOR ls_log_row-vbeln.

START-OF-SELECTION.
  " Enforce corporate governance and data access control
  AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'
    ID 'ACTVT' FIELD '03'.
  IF sy-subrc <> 0.
    MESSAGE 'Authorization check failed.' TYPE 'E'.
    EXIT.
  ENDIF.

  " Selective data fetch to reduce memory footprint
  SELECT vbeln, posnr, netwr
    FROM vbap
    INTO TABLE @lt_vbap_data
    WHERE vbeln IN @s_vbeln.

  IF lt_vbap_data IS NOT INITIAL.
    " Memory-buffered calculation using field symbols for faster row iteration
    LOOP AT lt_vbap_data ASSIGNING FIELD-SYMBOL(<fs_vbap>).
      CLEAR ls_log_row.
      ls_log_row-vbeln        = <fs_vbap>-vbeln.
      ls_log_row-posnr        = <fs_vbap>-posnr.
      ls_log_row-orig_netwr   = <fs_vbap>-netwr.
      ls_log_row-discount_val = <fs_vbap>-netwr * '0.10'.
      APPEND ls_log_row TO lt_log_bulk.
    ENDLOOP.

    " Bulk database operation using a single transaction commit
    INSERT zso_log FROM TABLE @lt_log_bulk.
    
    COMMIT WORK.
    WRITE: / 'Bulk ingestion processed successfully. Records created: ', sy-dbcnt.
  ELSE.
    WRITE: / 'No matching transactional records found.'.
  ENDIF.
