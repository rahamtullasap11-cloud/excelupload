CLASS lhc_ZI_EmpUploadS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR ZI_EmpUploadS RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR ZI_EmpUploadS RESULT result.
    METHODS uploadExcel FOR MODIFY
      keys FOR ACTION ZI_EmpUploadS~uploadExcel RESULT result.

ENDCLASS.

CLASS lhc_ZI_EmpUploadS IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD uploadExcel.
  ENDMETHOD.

ENDCLASS.
