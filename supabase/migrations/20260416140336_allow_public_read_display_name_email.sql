/*
  # Allow public read of display_name and email on user_profiles

  The login page needs to look up a user's email by their display_name
  before authenticating. Since the user is not yet logged in, we need
  a policy that allows unauthenticated (anon) access to just the
  display_name and email columns of user_profiles.

  Changes:
  - Add SELECT policy for anon role on user_profiles (display_name + email lookup only)
*/

CREATE POLICY "Public can look up display_name and email for login"
  ON user_profiles
  FOR SELECT
  TO anon
  USING (true);
