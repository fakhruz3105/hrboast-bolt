/*
  # Create admin user safely
  
  1. Changes
    - Create admin user in auth.users table
    - Use DO block for safe insertion
    - Add proper metadata
*/

DO $$
DECLARE
  new_user_id uuid := gen_random_uuid();
  encrypted_pass text;
BEGIN
  -- Only proceed if admin user doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM auth.users WHERE email = 'admin@example.com'
  ) THEN
    -- Generate encrypted password
    encrypted_pass := crypt('admin123', gen_salt('bf'));

    -- Insert into auth.users
    INSERT INTO auth.identities (
      id,
      user_id,
      identity_data,
      provider,
      last_sign_in_at,
      created_at,
      updated_at
    ) VALUES (
      gen_random_uuid(),
      new_user_id,
      jsonb_build_object(
        'sub', new_user_id::text,
        'email', 'admin@example.com'
      ),
      'email',
      now(),
      now(),
      now()
    );

    INSERT INTO auth.users (
      id,
      email,
      raw_app_meta_data,
      raw_user_meta_data,
      is_super_admin,
      encrypted_password,
      email_confirmed_at,
      created_at,
      updated_at,
      confirmation_token,
      recovery_token
    ) VALUES (
      new_user_id,
      'admin@example.com',
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      '{"role": "admin"}'::jsonb,
      false,
      encrypted_pass,
      now(),
      now(),
      now(),
      '',
      ''
    );
  END IF;
END $$;