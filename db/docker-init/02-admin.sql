-- Compte admin de première connexion (cf. README).
-- Mot de passe stocké en clair : c'est le comportement actuel de l'application legacy.
USE livrai;

INSERT INTO user (email, name, password, admin) VALUES
  ('admin@livrai.fr', 'Livrai', 'admin', TRUE);
