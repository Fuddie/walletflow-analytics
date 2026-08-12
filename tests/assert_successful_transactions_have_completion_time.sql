select *
from {{ ref('stg_transactions') }}
where status = 'success'
  and completed_at is null
