CREATE TABLE IF NOT EXISTS admin_whitelist (
  discord_id VARCHAR(50) PRIMARY KEY,
  rank       VARCHAR(20) NOT NULL DEFAULT 'admin'
);