import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
    }

    const supabase = createClient(
      Deno.env.get('PROJECT_URL')!,
      Deno.env.get('PROJECT_SERVICE_ROLE_KEY')!
    )

    const userClient = createClient(
      Deno.env.get('PROJECT_URL')!,
      Deno.env.get('PROJECT_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: authError } = await userClient.auth.getUser()
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Invalid token' }), { status: 401 })
    }

    const { actions } = await req.json()

    if (!Array.isArray(actions)) {
      return new Response(JSON.stringify({ error: 'actions must be array' }), { status: 400 })
    }

    const results = []

    for (const action of actions) {
      const { reference_id, action_type, payload } = action

      const { data: existing } = await supabase
        .from('transactions')
        .select('id, status')
        .eq('reference_id', reference_id)
        .single()

      if (existing) {
        results.push({ reference_id, status: 'already_processed', transaction_id: existing.id })
        continue
      }

      try {
        if (action_type === 'p2p_send') {
          const { data: recipient } = await supabase
            .from('profiles')
            .select('id')
            .ilike('lyra_tag', payload.to_lyra_tag.replace('$', ''))
            .single()

          if (!recipient) {
            results.push({ reference_id, status: 'failed', error: 'recipient_not_found' })
            continue
          }

          const { data: result } = await supabase.rpc('process_p2p_transfer', {
            p_from_user_id: user.id,
            p_to_user_id:   recipient.id,
            p_amount:       payload.amount,
            p_note:         payload.note || '',
            p_reference_id: reference_id
          })

          results.push({
            reference_id,
            status: result.success ? 'completed' : 'failed',
            transaction_id: result.transaction_id,
            error: result.error
          })
        }
      } catch (err) {
        results.push({ reference_id, status: 'failed', error: err.message })
      }
    }

    return new Response(
      JSON.stringify({ results }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})