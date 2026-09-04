CLASS lhc_ZI_4859_USER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR User RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR User RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR User RESULT result.

    METHODS DownloadExcel FOR MODIFY
       keys FOR ACTION User~DownloadExcel RESULT result.

    METHODS uploadExcelData FOR MODIFY
       keys FOR ACTION User~uploadExcelData RESULT result.

    METHODS FillFileStatus FOR DETERMINE ON MODIFY
       keys FOR User~FillFileStatus.

    METHODS FillSelectedStatus FOR DETERMINE ON MODIFY
       keys FOR User~FillSelectedStatus.

ENDCLASS.

CLASS lhc_ZI_4859_USER IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_4859_user IN LOCAL MODE
       ENTITY User
       FIELDS (
         EmpId
         DevId
         FileStatus
         TemplateStatus
       )
       WITH CORRESPONDING #( keys )
       RESULT DATA(it_users)
       FAILED failed.

    result =
      VALUE #(
        FOR user IN it_users

        LET uploadBtn =
              COND #(
                WHEN user-FileStatus = 'File Selected'
                THEN if_abap_behv=>fc-o-enabled
                ELSE if_abap_behv=>fc-o-disabled
              )

            downloadBtn =
              COND #(
                WHEN user-TemplateStatus = 'Absent'
                THEN if_abap_behv=>fc-o-enabled
                ELSE if_abap_behv=>fc-o-disabled
              )

        IN
        (
          %tky = user-%tky

          %assoc-_UserDev = if_abap_behv=>fc-o-disabled

          %action-uploadExcelData = uploadBtn
          %action-downloadExcel   = downloadBtn
        )
      ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
    result = VALUE #(
        FOR ls_key IN keys
        (
          %tky = ls_key-%tky

          %update    = if_abap_behv=>auth-allowed
          %delete    = if_abap_behv=>auth-allowed
          %action-uploadExcelData = if_abap_behv=>auth-allowed
          %action-downloadExcel   = if_abap_behv=>auth-allowed
        )
      ).
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD DownloadExcel.
    TYPES:
      BEGIN OF lty_exl_file,
        emp_id   TYPE string,
        dev_id   TYPE string,
        dev_desc TYPE string,
        obj_type TYPE string,
        obj_name TYPE string,
      END OF lty_exl_file.

    DATA lt_template TYPE STANDARD TABLE OF lty_exl_file WITH EMPTY KEY.

    DATA(lo_document) = xco_cp_xlsx=>document->empty( ).

    DATA(lo_write_access) = lo_document->write_access( ).

    DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) =
      xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_column(
          xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
        )->to_column(
          xco_cp_xlsx=>coordinate->for_alphabetic_value( 'E' )
        )->from_row(
          xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
        )->get_pattern( ).

    lt_template = VALUE #(
        (
          emp_id   = 'User Id'
          dev_id   = 'Development Id'
          dev_desc = 'Development Description'
          obj_type = 'Object Type'
          obj_name = 'Object Name'
        )
    ).

    lo_worksheet->select( lo_selection_pattern )->row_stream( )->operation->write_from(
        REF #( lt_template )
      )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    MODIFY ENTITIES OF zi_4859_user IN LOCAL MODE
      ENTITY User
      UPDATE FROM VALUE #(
        FOR ls_key IN keys
        (
          EmpId      = ls_key-EmpId
          DevId      = ls_key-DevId

          Attachment = lv_file_content
          FileName   = 'template.xlsx'
          MimeType   = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

          %control-Attachment = if_abap_behv=>mk-on
          %control-FileName   = if_abap_behv=>mk-on
          %control-MimeType   = if_abap_behv=>mk-on
        )
      )
      MAPPED DATA(ls_mapped)
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    READ ENTITIES OF zi_4859_user IN LOCAL MODE
      ENTITY User
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_user).

    LOOP AT lt_user INTO DATA(ls_user).

      MODIFY ENTITIES OF zi_4859_user IN LOCAL MODE
        ENTITY User
        UPDATE FIELDS ( FileStatus TemplateStatus )
        WITH VALUE #(
          (
            %tky = ls_user-%tky

            %data-FileStatus     = 'File not Selected'
            %data-TemplateStatus = 'Present'

            %control-FileStatus     = if_abap_behv=>mk-on
            %control-TemplateStatus = if_abap_behv=>mk-on
          )
        ).

    ENDLOOP.

    result = VALUE #(
      FOR ls_result IN lt_user
      (
        %tky   = ls_result-%tky
        %param = ls_result
      )
    ).

  ENDMETHOD.

  METHOD FillFileStatus.

    READ ENTITIES OF zi_4859_user IN LOCAL MODE
      ENTITY User
      FIELDS ( EmpId DevId FileStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_user).

    LOOP AT lt_user INTO DATA(ls_user).

      MODIFY ENTITIES OF zi_4859_user IN LOCAL MODE
        ENTITY User
        UPDATE FIELDS ( FileStatus TemplateStatus )
        WITH VALUE #(
          (
            %tky = ls_user-%tky

            %data-FileStatus     = 'File not Selected'
            %data-TemplateStatus = 'Absent'

            %control-FileStatus     = if_abap_behv=>mk-on
            %control-TemplateStatus = if_abap_behv=>mk-on
          )
        ).

    ENDLOOP.
  ENDMETHOD.

  METHOD FillSelectedStatus.
    READ ENTITIES OF zi_4859_user IN LOCAL MODE
     ENTITY User
     ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_user).

    LOOP AT lt_user INTO DATA(ls_user).

      MODIFY ENTITIES OF zi_4859_user IN LOCAL MODE
        ENTITY User
        UPDATE FIELDS ( FileStatus )
        WITH VALUE #(
          (
            %tky = ls_user-%tky

            %data-FileStatus =
              COND #(
                WHEN ls_user-Attachment IS INITIAL
                THEN 'File not Selected'
                ELSE 'File Selected'
              )

            %control-FileStatus = if_abap_behv=>mk-on
          )
        ).

    ENDLOOP.

  ENDMETHOD.

  METHOD uploadExcelData.
    TYPES:
      BEGIN OF lty_row,
        emp_id   TYPE string,
        dev_id   TYPE string,
        dev_desc TYPE string,
        obj_type TYPE string,
        obj_name TYPE string,
      END OF lty_row.

    DATA lt_rows TYPE STANDARD TABLE OF lty_row WITH EMPTY KEY.
    DATA lt_dev  TYPE TABLE FOR CREATE zi_4859_user\_UserDev.

    " Read the uploaded attachment for each key
    READ ENTITIES OF zi_4859_user IN LOCAL MODE
      ENTITY User
      FIELDS ( EmpId DevId Attachment )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_user).

    LOOP AT lt_user INTO DATA(ls_user).

      IF ls_user-Attachment IS INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR lt_rows.

      TRY.
          DATA(lo_document)     = xco_cp_xlsx=>document->for_file_content( ls_user-Attachment ).
          DATA(lo_read_access)  = lo_document->read_access( ).
          DATA(lo_worksheet)    = lo_read_access->get_workbook( )->worksheet->at_position( 1 ).

          DATA(lo_selection_pattern) =
            xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
              )->from_column(
                xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
              )->to_column(
                xco_cp_xlsx=>coordinate->for_alphabetic_value( 'E' )
              )->from_row(
                xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
              )->get_pattern( ).

          lo_worksheet->select( lo_selection_pattern )->row_stream( )->operation->write_to(
              REF #( lt_rows )
            )->set_value_transformation(
              xco_cp_xlsx_read_access=>value_transformation->string_value
            )->execute( ).

        CATCH cx_root INTO DATA(lx_error).
          " Parsing failed - skip this record's upload
          CONTINUE.
      ENDTRY.

      " Build child entity creation table from parsed rows
      DATA lv_serial TYPE i VALUE 0.

      LOOP AT lt_rows INTO DATA(ls_row).

        IF ls_row-obj_type IS INITIAL AND ls_row-obj_name IS INITIAL.
          CONTINUE.
        ENDIF.

        lv_serial = lv_serial + 1.

        APPEND VALUE #(
          %tky    = ls_user-%tky
          %target = VALUE #(
            (
              %cid       = |CID{ lv_serial }|
              SerialNo   = lv_serial
              ObjectType = ls_row-obj_type
              ObjectName = ls_row-obj_name
            )
          )
        ) TO lt_dev.

      ENDLOOP.

    ENDLOOP.

    IF lt_dev IS NOT INITIAL.

      MODIFY ENTITIES OF zi_4859_user IN LOCAL MODE
        ENTITY User
        CREATE BY \_UserDev
        FIELDS ( SerialNo ObjectType ObjectName )
        WITH lt_dev
        MAPPED DATA(ls_mapped)
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported).

    ENDIF.

    " Update FileStatus after upload
    LOOP AT lt_user INTO ls_user.

      MODIFY ENTITIES OF zi_4859_user IN LOCAL MODE
        ENTITY User
        UPDATE FIELDS ( FileStatus )
        WITH VALUE #(
          (
            %tky = ls_user-%tky

            %data-FileStatus = 'Excel Uploaded'

            %control-FileStatus = if_abap_behv=>mk-on
          )
        ).

    ENDLOOP.

    result = VALUE #(
      FOR ls_result IN lt_user
      (
        %tky   = ls_result-%tky
        %param = ls_result
      )
    ).


  ENDMETHOD.

ENDCLASS.
