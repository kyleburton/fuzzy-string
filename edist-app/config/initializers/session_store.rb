# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_edist-app_session',
  :secret      => '4885fb9794cf00d0f93a7729b9deccc908ecb195841ffff78aaa3196ee53a68c14b1ee0ee4c3c2b27ef93505388d928f3848cbbd0facbaffa1d7c7308ce613c4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
