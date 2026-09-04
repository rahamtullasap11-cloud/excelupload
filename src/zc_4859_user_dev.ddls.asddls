@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'user dev consumption view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_4859_user_dev
   as projection on ZI_4859_user_dev
{
    key EmpId,
    key DevId,
    key SerialNo,
    ObjectType,
    ObjectName,
    /* Associations */
    _User : redirected to parent zc_4859_user
}
