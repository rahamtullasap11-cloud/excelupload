@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption view of user'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zc_4859_user
  provider contract transactional_query
  as projection on ZI_4859_USER
{
  key EmpId,
  key DevId,
      DevDescription,
      @Semantics.largeObject : {
        mimeType: 'Mimetype',
        fileName: 'Filename',
        acceptableMimeTypes: [ 'application/vnd.ms-excel','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
        contentDispositionPreference: #ATTACHMENT
        }
      Attachment,
      Mimetype,
      Filename,
      FileStatus,
      TemplateStatus,
      Criticality,
      TemplateCrticality,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _UserDev : redirected to composition child ZC_4859_USER_DEV
}
