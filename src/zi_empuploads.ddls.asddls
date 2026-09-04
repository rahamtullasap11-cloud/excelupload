@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Emp interface upload'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_EmpUploadS
  as select from zemp_uploads

{
  key emp_id                as EmpId,
      emp_name              as EmpName,
      department            as Department,
      salary                as Salary,
      join_date             as JoinDate,

      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt

}
