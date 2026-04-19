/*
  # Add username column to user_profiles

  ## Summary
  Adds a `username` column to `user_profiles` for clean username-based login.
  Backfills existing users with lowercase versions of their display_name.

  ## Changes
  - New column: `username` (text, unique, lowercase) on `user_profiles`
  - Backfill: kunal, prachi, nikhil from existing display_names
  - Unique constraint enforced on username
*/

ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS username text;

UPDATE user_profiles
  SET username = lower(display_name)
  WHERE username IS NULL AND display_name IS NOT NULL;

UPDATE user_profiles
  SET username = lower(split_part(email, '@', 1))
  WHERE username IS NULL AND email IS NOT NULL;

ALTER TABLE user_profiles
  ADD CONSTRAINT user_profiles_username_unique UNIQUE (username);

ALTER TABLE user_profiles
  ALTER COLUMN username SET NOT NULL;
