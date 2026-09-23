-- Speech Therapy Tracker — schema for the shared My Health Postgres database.
-- Tables already exist if My Health migrations have been applied. Safe to re-run:
--   psql "$DATABASE_URL" -f migrations/setup.sql
-- Use the same DATABASE_URL as my-health-open-source-express-server (database my_health).

CREATE TABLE IF NOT EXISTS public.therapy_exercise_imports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  status TEXT NOT NULL DEFAULT 'previewed'
    CHECK (status IN ('previewed', 'committed')),
  draft_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_therapy_exercise_imports_status
  ON public.therapy_exercise_imports (status);

CREATE TABLE IF NOT EXISTS public.therapy_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discipline TEXT NOT NULL DEFAULT 'speech'
    CHECK (discipline IN ('speech')),
  name TEXT NOT NULL,
  instructions TEXT,
  tracking_kind TEXT NOT NULL
    CHECK (tracking_kind IN ('timed_attempts', 'sets_reps')),
  target_count INTEGER NOT NULL CHECK (target_count > 0),
  unit_size INTEGER NOT NULL DEFAULT 1 CHECK (unit_size > 0),
  frequency TEXT NOT NULL DEFAULT 'daily'
    CHECK (frequency IN ('daily', 'session')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT 'manual'
    CHECK (source IN ('manual', 'photo_import')),
  import_id UUID REFERENCES public.therapy_exercise_imports(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_therapy_exercises_discipline_active
  ON public.therapy_exercises (discipline, is_active, sort_order);

CREATE TABLE IF NOT EXISTS public.therapy_exercise_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES public.therapy_exercises(id) ON DELETE CASCADE,
  log_date DATE NOT NULL,
  completed_count INTEGER NOT NULL DEFAULT 0 CHECK (completed_count >= 0),
  skipped BOOLEAN NOT NULL DEFAULT false,
  due BOOLEAN NOT NULL DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_therapy_exercise_logs_exercise_date
  ON public.therapy_exercise_logs (exercise_id, log_date);

CREATE INDEX IF NOT EXISTS idx_therapy_exercise_logs_log_date
  ON public.therapy_exercise_logs (log_date DESC);

CREATE TABLE IF NOT EXISTS public.llm_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider TEXT NOT NULL,
  model TEXT NOT NULL UNIQUE,
  input_cost_per_million_usd NUMERIC(12, 6) NOT NULL,
  output_cost_per_million_usd NUMERIC(12, 6) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO public.llm_models (provider, model, input_cost_per_million_usd, output_cost_per_million_usd)
VALUES ('anthropic', 'claude-sonnet-4-20250514', 3.000000, 15.000000)
ON CONFLICT (model) DO UPDATE
SET
  provider = EXCLUDED.provider,
  input_cost_per_million_usd = EXCLUDED.input_cost_per_million_usd,
  output_cost_per_million_usd = EXCLUDED.output_cost_per_million_usd,
  updated_at = now();

INSERT INTO public.llm_models (provider, model, input_cost_per_million_usd, output_cost_per_million_usd)
VALUES ('anthropic', 'claude-haiku-4-5-20251001', 1.000000, 5.000000)
ON CONFLICT (model) DO UPDATE
SET
  provider = EXCLUDED.provider,
  input_cost_per_million_usd = EXCLUDED.input_cost_per_million_usd,
  output_cost_per_million_usd = EXCLUDED.output_cost_per_million_usd,
  updated_at = now();

CREATE TABLE IF NOT EXISTS public.exchange_table_registry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  logical_key TEXT NOT NULL,
  table_name TEXT NOT NULL,
  occurred_at_column TEXT NOT NULL DEFAULT 'created_at',
  input_tokens_column TEXT NOT NULL DEFAULT 'input_tokens',
  output_tokens_column TEXT NOT NULL DEFAULT 'output_tokens',
  model_column TEXT DEFAULT 'model_used',
  enabled BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_exchange_table_registry_logical_key
  ON public.exchange_table_registry (logical_key);

CREATE INDEX IF NOT EXISTS idx_exchange_table_registry_enabled
  ON public.exchange_table_registry (enabled, sort_order);

INSERT INTO public.exchange_table_registry (logical_key, table_name, sort_order, notes)
SELECT
  'therapy_exercise_import',
  'therapy_exercise_import_ai_exchanges',
  10,
  'Speech therapy homework photo import'
WHERE NOT EXISTS (
  SELECT 1 FROM public.exchange_table_registry WHERE logical_key = 'therapy_exercise_import'
);

CREATE TABLE IF NOT EXISTS public.therapy_exercise_import_ai_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  import_id UUID REFERENCES public.therapy_exercise_imports(id) ON DELETE SET NULL,
  provider TEXT NOT NULL DEFAULT 'anthropic',
  model TEXT NOT NULL,
  mime_type TEXT,
  filename TEXT,
  system_prompt TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'completed', 'failed')),
  exchange_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.therapy_exercise_import_ai_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES public.therapy_exercise_import_ai_requests(id) ON DELETE CASCADE,
  model TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('success', 'error')),
  raw_response TEXT,
  parsed_response_json JSONB,
  error_message TEXT,
  usage_input_tokens INTEGER,
  usage_output_tokens INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.therapy_exercise_import_ai_exchanges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES public.therapy_exercise_import_ai_requests(id) ON DELETE CASCADE,
  response_id UUID REFERENCES public.therapy_exercise_import_ai_responses(id) ON DELETE SET NULL,
  import_id UUID REFERENCES public.therapy_exercise_imports(id) ON DELETE SET NULL,
  input_tokens INTEGER,
  output_tokens INTEGER,
  total_tokens INTEGER,
  model_used TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'completed', 'failed')),
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.therapy_exercise_import_ai_requests
  DROP CONSTRAINT IF EXISTS fk_teiar_exchange;
ALTER TABLE public.therapy_exercise_import_ai_requests
  ADD CONSTRAINT fk_teiar_exchange
  FOREIGN KEY (exchange_id) REFERENCES public.therapy_exercise_import_ai_exchanges(id) ON DELETE SET NULL;

ALTER TABLE public.therapy_exercise_imports
  ADD COLUMN IF NOT EXISTS exchange_id UUID;

ALTER TABLE public.therapy_exercise_imports
  DROP CONSTRAINT IF EXISTS fk_tei_exchange;
ALTER TABLE public.therapy_exercise_imports
  ADD CONSTRAINT fk_tei_exchange
  FOREIGN KEY (exchange_id) REFERENCES public.therapy_exercise_import_ai_exchanges(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_teiae_created
  ON public.therapy_exercise_import_ai_exchanges (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_teiae_status
  ON public.therapy_exercise_import_ai_exchanges (status);

CREATE INDEX IF NOT EXISTS idx_teiar_exchange_id
  ON public.therapy_exercise_import_ai_requests (exchange_id);

CREATE TABLE IF NOT EXISTS public.feed_formulas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand TEXT NOT NULL,
  name TEXT NOT NULL,
  calories_per_1000_ml NUMERIC NOT NULL CHECK (calories_per_1000_ml > 0),
  container_volume_ml NUMERIC NOT NULL DEFAULT 1000 CHECK (container_volume_ml > 0),
  volume_fl_oz NUMERIC CHECK (volume_fl_oz IS NULL OR volume_fl_oz > 0),
  volume_qt NUMERIC CHECK (volume_qt IS NULL OR volume_qt > 0),
  volume_l NUMERIC CHECK (volume_l IS NULL OR volume_l > 0),
  is_active BOOLEAN NOT NULL DEFAULT true,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_feed_formulas_active_name
  ON public.feed_formulas (is_active, lower(brand), lower(name));

CREATE TABLE IF NOT EXISTS public.feed_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  log_date DATE NOT NULL,
  formula_id UUID NOT NULL REFERENCES public.feed_formulas(id) ON DELETE RESTRICT,
  intermittent_rate_ml_per_hr NUMERIC NOT NULL DEFAULT 50
    CHECK (intermittent_rate_ml_per_hr > 0),
  feed_left_ml NUMERIC NOT NULL CHECK (feed_left_ml >= 0),
  total_fed_ml NUMERIC NOT NULL CHECK (total_fed_ml >= 0),
  pump_reset BOOLEAN NOT NULL DEFAULT false,
  is_start BOOLEAN NOT NULL DEFAULT false,
  calories_per_1000_ml NUMERIC NOT NULL CHECK (calories_per_1000_ml > 0),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_feed_logs_log_date
  ON public.feed_logs (log_date);

CREATE INDEX IF NOT EXISTS idx_feed_logs_formula_id
  ON public.feed_logs (formula_id);

CREATE TABLE IF NOT EXISTS public.speech_therapy_consumption (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  consumption_type TEXT NOT NULL
    CHECK (consumption_type IN ('ice_cube')),
  log_date DATE NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_speech_therapy_consumption_type_date
  ON public.speech_therapy_consumption (consumption_type, log_date);

CREATE INDEX IF NOT EXISTS idx_speech_therapy_consumption_log_date
  ON public.speech_therapy_consumption (log_date DESC);
