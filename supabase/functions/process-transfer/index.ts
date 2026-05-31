import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import * as bcrypt from 'https://deno.land/x/bcrypt@v0.4.1/mod.ts'

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
      return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders })
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
      return new Response(JSON.stringify({ error: 'Invalid token' }), { status: 401, headers: corsHeaders })
    }

    const {
      to_lyra_tag,
      amount,
      note,
      pin,
      reference_id
    } = await req.json()

    if (!to_lyra_tag || !amount || !pin || !reference_id) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (typeof amount !== 'number' || amount <= 0 || amount > 5000) {
      return new Response(
        JSON.stringify({ error: 'invalid_amount' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { data: security } = await supabase
      .from('security_settings')
      .select('transaction_pin_hash, pin_attempts, pin_locked_until')
      .eq('user_id', user.id)
      .single()

    if (!security?.transaction_pin_hash) {
      return new Response(
        JSON.stringify({ error: 'pin_not_set' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (security.pin_locked_until) {
      const lockedUntil = new Date(security.pin_locked_until).getTime()
      if (lockedUntil > Date.now()) {
        return new Response(
          JSON.stringify({ error: 'pin_locked', locked_until: security.pin_locked_until }),
          { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    const pinValid = await bcrypt.compare(pin, security.transaction_pin_hash)
    if (!pinValid) {
      const newAttempts = (security.pin_attempts || 0) + 1
      const updates: any = { pin_attempts: newAttempts }

      if (newAttempts >= 5) {
        updates.pin_locked_until = new Date(Date.now() + 3600_000).toISOString()
        updates.pin_attempts = 0
      }

      await supabase
        .from('security_settings')
        .update(updates)
        .eq('user_id', user.id)

      return new Response(
        JSON.stringify({
          error: 'invalid_pin',
          attempts_remaining: Math.max(0, 5 - newAttempts)
        }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    await supabase
      .from('security_settings')
      .update({ pin_attempts: 0, pin_locked_until: null })
      .eq('user_id', user.id)

    const { data: recipient } = await supabase
      .from('profiles')
      .select('id')
      .ilike('lyra_tag', to_lyra_tag.replace('$', ''))
      .single()

    if (!recipient) {
      return new Response(
        JSON.stringify({ error: 'recipient_not_found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (recipient.id === user.id) {
      return new Response(
        JSON.stringify({ error: 'cannot_send_to_self' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { data: result, error: transferError } = await supabase.rpc(
      'process_p2p_transfer',
      {
        p_from_user_id: user.id,
        p_to_user_id:   recipient.id,
        p_amount:       amount,
        p_note:         note || '',
        p_reference_id: reference_id
      }
    )

    if (transferError) throw transferError

    if (!result.success) {
      return new Response(
        JSON.stringify({ error: result.error }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        transaction_id: result.transaction_id,
        new_balance: result.new_balance,
        idempotent: result.idempotent ?? false
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (err) {
    console.error('process-transfer error:', err)
    return new Response(
      JSON.stringify({ error: 'internal_error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})