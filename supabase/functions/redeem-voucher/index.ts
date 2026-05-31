import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import * as bcrypt from 'https://deno.land/x/bcrypt@v0.4.1/mod.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const rateLimitStore = new Map<string, { count: number; resetAt: number; lockedUntil?: number }>()

function checkRateLimit(userId: string): { allowed: boolean; lockedUntil?: number } {
  const now = Date.now()
  const key = `voucher:${userId}`
  const entry = rateLimitStore.get(key) || { count: 0, resetAt: now + 3600_000 }

  if (entry.lockedUntil && entry.lockedUntil > now) {
    return { allowed: false, lockedUntil: entry.lockedUntil }
  }

  if (entry.resetAt < now) {
    entry.count = 0
    entry.resetAt = now + 3600_000
    entry.lockedUntil = undefined
  }

  if (entry.count >= 5) {
    entry.lockedUntil = now + 86_400_000
    rateLimitStore.set(key, entry)
    return { allowed: false, lockedUntil: entry.lockedUntil }
  }

  entry.count++
  rateLimitStore.set(key, entry)
  return { allowed: true }
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
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
      return new Response(
        JSON.stringify({ error: 'Invalid token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { data: secSettings } = await supabase
      .from('security_settings')
      .select('voucher_attempts, voucher_locked_until')
      .eq('user_id', user.id)
      .single()

    if (secSettings?.voucher_locked_until) {
      const lockedUntil = new Date(secSettings.voucher_locked_until).getTime()
      if (lockedUntil > Date.now()) {
        return new Response(
          JSON.stringify({
            error: 'too_many_attempts',
            locked_until: secSettings.voucher_locked_until
          }),
          { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    const memLimit = checkRateLimit(user.id)
    if (!memLimit.allowed) {
      await supabase
        .from('security_settings')
        .update({
          voucher_locked_until: new Date(memLimit.lockedUntil!).toISOString()
        })
        .eq('user_id', user.id)

      return new Response(
        JSON.stringify({ error: 'too_many_attempts' }),
        { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { code, reference_id } = await req.json()

    if (!code || !reference_id) {
      return new Response(
        JSON.stringify({ error: 'code and reference_id are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const normalizedCode = code.replace(/-/g, '').toUpperCase()

    if (normalizedCode.length !== 15) {
      return new Response(
        JSON.stringify({ error: 'invalid_code_format' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { data: candidates, error: fetchError } = await supabase
      .from('vouchers')
      .select('id, code_hash, denomination, status, expires_at')
      .in('status', ['generated', 'printed', 'sold'])
      .limit(100)

    if (fetchError) throw fetchError

    let matchedVoucher: any = null
    for (const candidate of candidates || []) {
      const isMatch = await bcrypt.compare(normalizedCode, candidate.code_hash)
      if (isMatch) {
        matchedVoucher = candidate
        break
      }
    }

    if (!matchedVoucher) {
      await supabase.rpc('increment_voucher_attempts', { p_user_id: user.id })

      return new Response(
        JSON.stringify({ error: 'invalid_voucher_code' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { data: result, error: redeemError } = await supabase.rpc(
      'redeem_voucher_atomic',
      {
        p_voucher_id:   matchedVoucher.id,
        p_user_id:      user.id,
        p_reference_id: reference_id
      }
    )

    if (redeemError) throw redeemError

    if (!result.success) {
      return new Response(
        JSON.stringify({ error: result.error }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    await supabase
      .from('security_settings')
      .update({ voucher_attempts: 0, voucher_locked_until: null })
      .eq('user_id', user.id)

    return new Response(
      JSON.stringify({
        success: true,
        transaction_id: result.transaction_id,
        amount: result.amount,
        new_balance: result.new_balance,
        idempotent: result.idempotent ?? false
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (err) {
    console.error('redeem-voucher error:', err)
    return new Response(
      JSON.stringify({ error: 'internal_error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})