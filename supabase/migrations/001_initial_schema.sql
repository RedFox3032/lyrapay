import os

BASE = "/mnt/agents/output/lyrapay"

def write(path, content):
    full = os.path.join(BASE, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)

# Write the corrected schema with REAL newlines, not literal \n
write("supabase/migrations/001_initial_schema.sql", """-- ============================================================
-- LyraPay — Complete Supabase Schema
-- PostgreSQL 15 | Run in Supabase SQL Editor
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_net";

CREATE TYPE voucher_status AS ENUM (
  'generated', 'printed', 'sold', 'redeemed', 'expired', 'voided'
);

CREATE TYPE transaction_type AS ENUM (
  'voucher_redemption', 'p2p_send', 'p2p_receive', 'p2p_request',
  'refund', 'admin_credit', 'admin_debit', 'fee'
);

CREATE TYPE transaction_status AS ENUM (
  'pending', 'completed', 'failed', 'cancelled', 'reversed'
);

CREATE TYPE ledger_entry_type AS ENUM ('debit', 'credit');

CREATE TYPE request_status AS ENUM (
  'pending', 'paid', 'declined', 'expired', 'cancelled'
);

CREATE TABLE public.profiles (
  id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name      TEXT NOT NULL CHECK (char_length(first_name) BETWEEN 1 AND 50),
  last_name       TEXT NOT NULL CHECK (char_length(last_name) BETWEEN 1 AND 50),
  email           TEXT NOT NULL,
  lyra_tag        TEXT UNIQUE NOT NULL CHECK (
                    lyra_tag ~ '^[a-z0-9][a-z0-9._]{2,28}[a-z0-9]$'
                  ),
  avatar_url      TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  daily_limit     NUMERIC(12,3) NOT NULL DEFAULT 5000.000 CHECK (daily_limit >= 0),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_profiles_lyra_tag ON public.profiles (LOWER(lyra_tag));
CREATE INDEX idx_profiles_email ON public.profiles (LOWER(email));

CREATE TABLE public.wallets (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE RESTRICT,
  balance         NUMERIC(12,3) NOT NULL DEFAULT 0.000 CHECK (balance >= 0),
  held_balance    NUMERIC(12,3) NOT NULL DEFAULT 0.000 CHECK (held_balance >= 0),
  daily_sent      NUMERIC(12,3) NOT NULL DEFAULT 0.000 CHECK (daily_sent >= 0),
  daily_reset_at  TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '1 day'),
  currency        TEXT NOT NULL DEFAULT 'LYD',
  is_frozen       BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wallets_user_id ON public.wallets (user_id);

CREATE TABLE public.transactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  from_wallet_id  UUID REFERENCES public.wallets(id) ON DELETE RESTRICT,
  to_wallet_id    UUID REFERENCES public.wallets(id) ON DELETE RESTRICT,
  amount          NUMERIC(12,3) NOT NULL CHECK (amount > 0),
  fee             NUMERIC(12,3) NOT NULL DEFAULT 0.000 CHECK (fee >= 0),
  type            transaction_type NOT NULL,
  status          transaction_status NOT NULL DEFAULT 'pending',
  note            TEXT CHECK (char_length(note) <= 280),
  reference_id    TEXT UNIQUE,
  metadata        JSONB DEFAULT '{}',
  initiated_by    UUID REFERENCES public.profiles(id),
  ip_address      INET,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.transactions
  ADD CONSTRAINT chk_transfer_needs_wallets
    CHECK (
      (type = 'voucher_redemption' AND from_wallet_id IS NULL AND to_wallet_id IS NOT NULL)
      OR
      (type NOT IN ('voucher_redemption', 'admin_credit') AND from_wallet_id IS NOT NULL)
      OR
      (type = 'admin_credit' AND from_wallet_id IS NULL)
    );

CREATE INDEX idx_transactions_from_wallet ON public.transactions (from_wallet_id, created_at DESC);
CREATE INDEX idx_transactions_to_wallet   ON public.transactions (to_wallet_id, created_at DESC);
CREATE INDEX idx_transactions_initiated   ON public.transactions (initiated_by, created_at DESC);
CREATE INDEX idx_transactions_status      ON public.transactions (status);
CREATE INDEX idx_transactions_reference   ON public.transactions (reference_id);

CREATE TABLE public.ledger_entries (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_id  UUID NOT NULL REFERENCES public.transactions(id) ON DELETE RESTRICT,
  wallet_id       UUID NOT NULL REFERENCES public.wallets(id) ON DELETE RESTRICT,
  entry_type      ledger_entry_type NOT NULL,
  amount          NUMERIC(12,3) NOT NULL CHECK (amount > 0),
  balance_after   NUMERIC(12,3) NOT NULL CHECK (balance_after >= 0),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ledger_transaction ON public.ledger_entries (transaction_id);
CREATE INDEX idx_ledger_wallet      ON public.ledger_entries (wallet_id, created_at DESC);

CREATE TABLE public.voucher_batches (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_by      UUID NOT NULL REFERENCES public.profiles(id),
  denomination    INTEGER NOT NULL CHECK (denomination IN (25, 50, 100, 200, 500)),
  quantity        INTEGER NOT NULL CHECK (quantity BETWEEN 1 AND 10000),
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.vouchers (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  serial_number   TEXT UNIQUE NOT NULL,
  code_hash       TEXT NOT NULL,
  denomination    INTEGER NOT NULL CHECK (denomination IN (25, 50, 100, 200, 500)),
  status          voucher_status NOT NULL DEFAULT 'generated',
  batch_id        UUID REFERENCES public.voucher_batches(id),
  agent_id        UUID REFERENCES public.profiles(id),
  redeemed_by     UUID REFERENCES public.profiles(id),
  transaction_id  UUID REFERENCES public.transactions(id),
  generated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  printed_at      TIMESTAMPTZ,
  sold_at         TIMESTAMPTZ,
  redeemed_at     TIMESTAMPTZ,
  expires_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '12 months'),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_vouchers_status     ON public.vouchers (status);
CREATE INDEX idx_vouchers_batch      ON public.vouchers (batch_id);
CREATE INDEX idx_vouchers_redeemed   ON public.vouchers (redeemed_by);
CREATE INDEX idx_vouchers_expires    ON public.vouchers (expires_at) WHERE status != 'redeemed';

CREATE TABLE public.payment_requests (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  requester_id    UUID NOT NULL REFERENCES public.profiles(id),
  payer_id        UUID REFERENCES public.profiles(id),
  amount          NUMERIC(12,3) NOT NULL CHECK (amount > 0),
  note            TEXT CHECK (char_length(note) <= 280),
  status          request_status NOT NULL DEFAULT 'pending',
  transaction_id  UUID REFERENCES public.transactions(id),
  expires_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days'),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_requests_requester ON public.payment_requests (requester_id, created_at DESC);
CREATE INDEX idx_requests_payer     ON public.payment_requests (payer_id, created_at DESC);
CREATE INDEX idx_requests_status    ON public.payment_requests (status);

CREATE TABLE public.security_settings (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id             UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  transaction_pin_hash TEXT,
  biometric_enabled   BOOLEAN NOT NULL DEFAULT FALSE,
  pin_attempts        INTEGER NOT NULL DEFAULT 0,
  pin_locked_until    TIMESTAMPTZ,
  voucher_attempts    INTEGER NOT NULL DEFAULT 0,
  voucher_locked_until TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.offline_queue (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id),
  action_type     TEXT NOT NULL,
  payload         JSONB NOT NULL,
  reference_id    TEXT NOT NULL UNIQUE,
  attempts        INTEGER NOT NULL DEFAULT 0,
  last_attempted  TIMESTAMPTZ,
  status          TEXT NOT NULL DEFAULT 'queued',
  error_message   TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_offline_queue_user   ON public.offline_queue (user_id, status);
CREATE INDEX idx_offline_queue_status ON public.offline_queue (status, created_at);

CREATE TABLE public.audit_log (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID REFERENCES public.profiles(id),
  event_type      TEXT NOT NULL,
  table_name      TEXT,
  record_id       TEXT,
  old_data        JSONB,
  new_data        JSONB,
  ip_address      INET,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_user   ON public.audit_log (user_id, created_at DESC);
CREATE INDEX idx_audit_event  ON public.audit_log (event_type, created_at DESC);

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user_wallet()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.wallets (user_id)
  VALUES (NEW.id);
  INSERT INTO public.security_settings (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_wallet();

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_wallets_updated_at
  BEFORE UPDATE ON public.wallets
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_transactions_updated_at
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_security_updated_at
  BEFORE UPDATE ON public.security_settings
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_requests_updated_at
  BEFORE UPDATE ON public.payment_requests
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE FUNCTION public.reset_daily_limits()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.wallets
  SET daily_sent = 0,
      daily_reset_at = NOW() + INTERVAL '1 day'
  WHERE daily_reset_at <= NOW();
END;
$$;

-- ============================================================
-- CORE RPC: process_p2p_transfer
-- ============================================================

CREATE OR REPLACE FUNCTION public.process_p2p_transfer(
  p_from_user_id   UUID,
  p_to_user_id     UUID,
  p_amount         NUMERIC,
  p_note           TEXT,
  p_reference_id   TEXT
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_from_wallet    public.wallets%ROWTYPE;
  v_to_wallet      public.wallets%ROWTYPE;
  v_transaction_id UUID;
  v_daily_limit    NUMERIC;
BEGIN
  SELECT * INTO v_from_wallet
  FROM public.wallets
  WHERE user_id = p_from_user_id
  FOR UPDATE;

  SELECT * INTO v_to_wallet
  FROM public.wallets
  WHERE user_id = p_to_user_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'wallet_not_found');
  END IF;

  IF v_from_wallet.is_frozen THEN
    RETURN jsonb_build_object('success', false, 'error', 'wallet_frozen');
  END IF;

  IF v_to_wallet.is_frozen THEN
    RETURN jsonb_build_object('success', false, 'error', 'recipient_wallet_frozen');
  END IF;

  IF (v_from_wallet.balance - v_from_wallet.held_balance) < p_amount THEN
    RETURN jsonb_build_object('success', false, 'error', 'insufficient_funds');
  END IF;

  SELECT daily_limit INTO v_daily_limit FROM public.profiles WHERE id = p_from_user_id;

  IF v_from_wallet.daily_reset_at <= NOW() THEN
    UPDATE public.wallets SET daily_sent = 0, daily_reset_at = NOW() + INTERVAL '1 day'
    WHERE user_id = p_from_user_id;
    v_from_wallet.daily_sent := 0;
  END IF;

  IF (v_from_wallet.daily_sent + p_amount) > v_daily_limit THEN
    RETURN jsonb_build_object('success', false, 'error', 'daily_limit_exceeded');
  END IF;

  IF EXISTS (SELECT 1 FROM public.transactions WHERE reference_id = p_reference_id) THEN
    SELECT id INTO v_transaction_id FROM public.transactions WHERE reference_id = p_reference_id;
    RETURN jsonb_build_object('success', true, 'transaction_id', v_transaction_id, 'idempotent', true);
  END IF;

  INSERT INTO public.transactions (
    from_wallet_id, to_wallet_id, amount, type, status,
    note, reference_id, initiated_by
  ) VALUES (
    v_from_wallet.id, v_to_wallet.id, p_amount, 'p2p_send', 'completed',
    p_note, p_reference_id, p_from_user_id
  ) RETURNING id INTO v_transaction_id;

  UPDATE public.wallets
  SET balance = balance - p_amount,
      daily_sent = daily_sent + p_amount
  WHERE id = v_from_wallet.id;

  UPDATE public.wallets
  SET balance = balance + p_amount
  WHERE id = v_to_wallet.id;

  INSERT INTO public.ledger_entries (transaction_id, wallet_id, entry_type, amount, balance_after)
  VALUES (v_transaction_id, v_from_wallet.id, 'debit', p_amount,
          v_from_wallet.balance - p_amount);

  INSERT INTO public.ledger_entries (transaction_id, wallet_id, entry_type, amount, balance_after)
  VALUES (v_transaction_id, v_to_wallet.id, 'credit', p_amount,
          v_to_wallet.balance + p_amount);

  RETURN jsonb_build_object(
    'success', true,
    'transaction_id', v_transaction_id,
    'new_balance', (v_from_wallet.balance - p_amount)
  );

EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- ============================================================
-- CORE RPC: redeem_voucher_atomic
-- ============================================================

CREATE OR REPLACE FUNCTION public.redeem_voucher_atomic(
  p_voucher_id   UUID,
  p_user_id      UUID,
  p_reference_id TEXT
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_voucher       public.vouchers%ROWTYPE;
  v_wallet        public.wallets%ROWTYPE;
  v_transaction_id UUID;
BEGIN
  SELECT * INTO v_voucher FROM public.vouchers WHERE id = p_voucher_id FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'voucher_not_found');
  END IF;

  IF v_voucher.status != 'sold' AND v_voucher.status != 'printed' AND v_voucher.status != 'generated' THEN
    RETURN jsonb_build_object('success', false, 'error', 'voucher_already_used');
  END IF;

  IF v_voucher.expires_at < NOW() THEN
    UPDATE public.vouchers SET status = 'expired' WHERE id = p_voucher_id;
    RETURN jsonb_build_object('success', false, 'error', 'voucher_expired');
  END IF;

  IF EXISTS (SELECT 1 FROM public.transactions WHERE reference_id = p_reference_id) THEN
    SELECT id INTO v_transaction_id FROM public.transactions WHERE reference_id = p_reference_id;
    RETURN jsonb_build_object('success', true, 'transaction_id', v_transaction_id, 'idempotent', true);
  END IF;

  SELECT * INTO v_wallet FROM public.wallets WHERE user_id = p_user_id FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'wallet_not_found');
  END IF;

  INSERT INTO public.transactions (
    from_wallet_id, to_wallet_id, amount, type, status,
    reference_id, initiated_by
  ) VALUES (
    NULL, v_wallet.id, v_voucher.denomination, 'voucher_redemption', 'completed',
    p_reference_id, p_user_id
  ) RETURNING id INTO v_transaction_id;

  UPDATE public.wallets
  SET balance = balance + v_voucher.denomination
  WHERE id = v_wallet.id;

  INSERT INTO public.ledger_entries (transaction_id, wallet_id, entry_type, amount, balance_after)
  VALUES (v_transaction_id, v_wallet.id, 'credit', v_voucher.denomination,
          v_wallet.balance + v_voucher.denomination);

  UPDATE public.vouchers
  SET status = 'redeemed',
      redeemed_by = p_user_id,
      redeemed_at = NOW(),
      transaction_id = v_transaction_id
  WHERE id = p_voucher_id;

  RETURN jsonb_build_object(
    'success', true,
    'transaction_id', v_transaction_id,
    'amount', v_voucher.denomination,
    'new_balance', (v_wallet.balance + v_voucher.denomination)
  );

EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- ============================================================
-- HELPER: check_lyra_tag_available
-- ============================================================

CREATE OR REPLACE FUNCTION public.check_lyra_tag_available(p_tag TEXT)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN NOT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE LOWER(lyra_tag) = LOWER(p_tag)
  );
END;
$$;

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE public.profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_entries    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vouchers          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voucher_batches   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_requests  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offline_queue     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log         ENABLE ROW LEVEL SECURITY;

-- PROFILES
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can search others by lyra_tag"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Service role can insert profiles"
  ON public.profiles FOR INSERT
  WITH CHECK (true);

-- WALLETS
CREATE POLICY "Users can view own wallet"
  ON public.wallets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role manages wallets"
  ON public.wallets FOR ALL
  USING (auth.role() = 'service_role');

-- TRANSACTIONS
CREATE POLICY "Users see transactions they are part of"
  ON public.transactions FOR SELECT
  USING (
    auth.uid() = initiated_by
    OR auth.uid() = (SELECT user_id FROM public.wallets WHERE id = from_wallet_id)
    OR auth.uid() = (SELECT user_id FROM public.wallets WHERE id = to_wallet_id)
  );

CREATE POLICY "Service role manages transactions"
  ON public.transactions FOR ALL
  USING (auth.role() = 'service_role');

-- LEDGER ENTRIES
CREATE POLICY "Users see own ledger entries"
  ON public.ledger_entries FOR SELECT
  USING (
    auth.uid() = (SELECT user_id FROM public.wallets WHERE id = wallet_id)
  );

CREATE POLICY "Service role manages ledger"
  ON public.ledger_entries FOR ALL
  USING (auth.role() = 'service_role');

-- SECURITY SETTINGS
CREATE POLICY "Users can view own security settings"
  ON public.security_settings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role manages security settings"
  ON public.security_settings FOR ALL
  USING (auth.role() = 'service_role');

-- OFFLINE QUEUE
CREATE POLICY "Users manage own offline queue"
  ON public.offline_queue FOR ALL
  USING (auth.uid() = user_id);

-- PAYMENT REQUESTS
CREATE POLICY "Users see own payment requests"
  ON public.payment_requests FOR SELECT
  USING (auth.uid() = requester_id OR auth.uid() = payer_id);

CREATE POLICY "Users can create payment requests"
  ON public.payment_requests FOR INSERT
  WITH CHECK (auth.uid() = requester_id);

CREATE POLICY "Payer can update request status"
  ON public.payment_requests FOR UPDATE
  USING (auth.uid() = payer_id OR auth.uid() = requester_id);

-- VOUCHERS
CREATE POLICY "Users see own redeemed vouchers"
  ON public.vouchers FOR SELECT
  USING (auth.uid() = redeemed_by);

CREATE POLICY "Service role manages vouchers"
  ON public.vouchers FOR ALL
  USING (auth.role() = 'service_role');

-- AUDIT LOG
CREATE POLICY "Users can view own audit events"
  ON public.audit_log FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role manages audit log"
  ON public.audit_log FOR ALL
  USING (auth.role() = 'service_role');