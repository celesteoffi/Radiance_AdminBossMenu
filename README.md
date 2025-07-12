AdminBossMenu Discord Whitlist

Bossmenu Dependence : [Radiance BossMenu](https://github.com/celesteoffi/Radiance_BossMenu)

Configuration Facile et simple

- F7 
- Whitlist Admin Discord

## Config.lua :
```
Config = {
    OpenKey = 'F7',
    Command = 'adminmenu'
}
```
## sqladminmenu.sql :
```
/* -----------------------------------------------------------------
   1) Table whitelist des admins Discord
   ----------------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS admin_whitelist (
  discord_id VARCHAR(50) PRIMARY KEY,
  rank       VARCHAR(20) NOT NULL DEFAULT 'admin'
);

/* -----------------------------------------------------------------
   2) Ajouter vos administrateurs
   -----------------------------------------------------------------
   Remplacez le long nombre par votre vrai ID Discord (avec le préfixe
   "discord:" que vous voyez dans F8 ou dans la console).  */
INSERT IGNORE INTO admin_whitelist (discord_id, rank) VALUES
  ('discord:123456789012345678', 'superadmin'),
  ('discord:987654321098765432', 'admin');

/* -----------------------------------------------------------------
   3) (Facultatif) Voir la liste des admins whitelists
   ----------------------------------------------------------------- */
SELECT * FROM admin_whitelist;
```
