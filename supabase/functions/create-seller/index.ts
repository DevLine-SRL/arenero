import { createClient } from 'npm:@supabase/supabase-js@2.111.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/

type ErrorCode =
  | 'METHOD_NOT_ALLOWED'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'INVALID_REQUEST'
  | 'INVALID_EMAIL'
  | 'WEAK_PASSWORD'
  | 'NAME_REQUIRED'
  | 'EMAIL_TAKEN'
  | 'INTERNAL'

const errorMessages: Record<ErrorCode, string> = {
  METHOD_NOT_ALLOWED: 'Method not allowed',
  UNAUTHORIZED: 'Unauthorized',
  FORBIDDEN: 'Forbidden',
  INVALID_REQUEST: 'Invalid request',
  INVALID_EMAIL: 'Invalid email address',
  WEAK_PASSWORD: 'Password does not meet the requirements',
  NAME_REQUIRED: 'Name is required',
  EMAIL_TAKEN: 'Email is already in use',
  INTERNAL: 'Internal server error',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return errorResponse('METHOD_NOT_ALLOWED', 405)
  }

  const { url, clientKey, adminKey } = getEnvKeys()

  let body: Record<string, unknown> | null = null
  try {
    const raw: unknown = await req.json()
    if (typeof raw === 'object' && raw !== null) {
      body = raw as Record<string, unknown>
    }
  } catch {
    return errorResponse('INVALID_REQUEST', 400, 'Request body is not valid JSON')
  }

  const email = typeof body?.email === 'string' ? body.email.trim() : ''
  const password = typeof body?.password === 'string' ? body.password : ''
  const name = typeof body?.name === 'string' ? body.name.trim() : ''

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return errorResponse('INVALID_EMAIL', 400)
  }
  if (!passwordRegex.test(password)) {
    return errorResponse('WEAK_PASSWORD', 400)
  }
  if (!name) {
    return errorResponse('NAME_REQUIRED', 400)
  }

  const token = req.headers.get('Authorization')?.replace('Bearer ', '')
  if (!token) {
    return errorResponse('UNAUTHORIZED', 401)
  }

  const authed = createClient(url, clientKey, {
    global: {
      headers: { Authorization: `Bearer ${token}` },
    },
  })

  const {
    data: { user },
    error: userError,
  } = await authed.auth.getUser(token)
  if (userError || !user) {
    return errorResponse('UNAUTHORIZED', 401, userError ?? 'getUser returned no user')
  }

  const { data: profile, error: profileError } = await authed
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single()
  if (profileError || profile?.role !== 'admin') {
    return errorResponse('FORBIDDEN', 403, profileError ?? `User ${user.id} is not an admin`)
  }

  const admin = createClient(url, adminKey)

  const { data, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { name },
  })

  if (error) {
    if (error.code === 'user_already_exists' || error.code === 'email_exists') {
      return errorResponse('EMAIL_TAKEN', 409, error)
    }
    return errorResponse('INTERNAL', 500, error)
  }

  console.log(`[create-seller] created user ${data.user.id} (${email})`)

  return jsonResponse(
    {
      data: {
        id: data.user.id,
        email: data.user.email,
        name,
        role: 'seller',
        active: true,
      },
    },
    201,
  )
})

function getEnvKeys() {
  const url = Deno.env.get('SUPABASE_URL') ?? ''

  const parseJson = (name: string): Record<string, string> => {
    try {
      return JSON.parse(Deno.env.get(name) ?? '{}')
    } catch {
      return {}
    }
  }

  const publishable = parseJson('SUPABASE_PUBLISHABLE_KEYS')
  const secret = parseJson('SUPABASE_SECRET_KEYS')

  return {
    url,
    clientKey: publishable.default ?? Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    adminKey: secret.default ?? Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  }
}

function errorResponse(code: ErrorCode, status: number, details?: unknown) {
  if (details !== undefined) {
    console.error(`[create-seller] ${code}:`, details)
  }
  return jsonResponse(
    {
      error: {
        code,
        message: errorMessages[code],
      },
    },
    status,
  )
}

function jsonResponse(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
