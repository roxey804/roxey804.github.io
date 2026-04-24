ALTER TABLE public.profiles ADD COLUMN completed_tasks JSONB DEFAULT '{}'::jsonb;
