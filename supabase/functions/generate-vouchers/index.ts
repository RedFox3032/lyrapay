import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import * as bcrypt from 'https://deno.land/x/bcrypt@v0.4.1/mod.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const CHARSET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'

function generateCode(): string {
  let code = ''
  const array = new Uint8Array(15)
  crypto.getRandomValues(array)
  for (const byte of array) {
    code += CHARSET[byte % CHARSET.length]
  }
  return code
}

function formatCode(code: string): string {
  return `${code.slice(0, 5)}-${code.slice(5, 10)}-${code.slice(10, 15)}`
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const serviceKey = req.headers.get('x-service-role')
    if (serviceKey !== Deno.env.get('ADMIN_SECRET_KEY')) {
      return new Response(JSON.stringify({ error: 'Forbidden' }), { status: 403 })
    }

    const { denomination, quantity, agent_id, notes } = await req.json()

    if (![25, 50, 100, 200, 500].includes(denomination)) {
      return new Response(JSON.stringify({ error: 'Invalid denomination' }), { status: 400 })
    }

    if (!quantity || quantity < 1 || quantity > 10000) {
      return new Response(JSON.stringify({ error: 'Quantity must be 1–10000' }), { status: 400 })
    }

    const supabase = createClient(
      Deno.env.get('PROJECT_URL')!,
      Deno.env.get('PROJECT_SERVICE_ROLE_KEY')!
    )

    const { data: batch } = await supabase
      .from('voucher_batches')
      .insert({
        created_by:   agent_id,
        denomination,
        quantity,
        notes
      })
      .select('id')
      .single()

    const plainCodes: { serial: string; code: string; formatted: string }[] = []
    const dbVouchers: any[] = []
    const expiresAt = new Date(Date.now() + 365 * 24 * 3600_000).toISOString()

    for (let i = 0; i < quantity; i++) {
      const code = generateCode()
      const formatted = formatCode(code)
      const serial = `LYR-${Date.now()}-${String(i).padStart(6, '0')}`
      const hash = await bcrypt.hash(code)

      plainCodes.push({ serial, code, formatted })
      dbVouchers.push({
        serial_number: serial,
        code_hash:     hash,
        denomination,
        status:        'generated',
        batch_id:      batch!.id,
        agent_id,
        expires_at:    expiresAt
      })
    }

    const CHUNK = 100
    for (let i = 0; i < dbVouchers.length; i += CHUNK) {
      const chunk = dbVouchers.slice(i, i + CHUNK)
      await supabase.from('vouchers').insert(chunk)
    }

    const csv = [
      'serial_number,code,formatted_code,denomination,expires_at',
      ...plainCodes.map(v =>
        `${v.serial},${v.code},${v.formatted},${denomination} LYD,${expiresAt}`
      )
    ].join('\n')

    return new Response(csv, {
      headers: {
        ...corsHeaders,
        'Content-Type': 'text/csv',
        'Content-Disposition': `attachment; filename="vouchers_${denomination}LYD_${Date.now()}.csv"`,
      }
    })

  } catch (err) {
    console.error('generate-vouchers error:', err)
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})