/*
  # Create initial admin user

  1. Changes
    - Creates initial admin user with email/password authentication
    - Sets up user metadata and role
*/

-- Create admin user using Supabase's auth.users table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM auth.users WHERE email = 'admin@example.com'
  ) THEN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      'admin@example.com',
      crypt('admin123', gen_salt('bf')),
      now(),
      '{"provider": "email", "providers": ["email"]}',
      '{"role": "admin"}',
      now(),
      now(),
      '',
      '',
      '',
      ''
    );
  END IF;
END $$;