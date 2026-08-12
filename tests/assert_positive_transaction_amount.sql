select *
from {{ ref('stg_transactions') }}
where amount_ngn <= 0
